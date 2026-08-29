# -*- coding: utf-8 -*-

"""Generate a natural-looking Mattermost bulk-import ZIP from SQLite data."""

import hashlib
import json
import os
import random
import re
import sqlite3
import time
import zipfile
from collections import Counter, defaultdict
from datetime import datetime, time as dt_time, timedelta, timezone


OUT_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(OUT_DIR, "mm_data.db")
ZIP_PATH = os.path.join(OUT_DIR, "mattermost_import.zip")
PROFILE_IMAGE_DIR = os.path.join(OUT_DIR, "profile_images")
JST = timezone(timedelta(hours=9))
MENTION_PATTERN = re.compile(r"(?<![\w@])@([A-Za-z0-9_-]+)")
SPECIAL_MENTIONS = {"all", "channel", "here"}

EMOJI_POOL = [
    "+1",
    "heart",
    "laughing",
    "joy",
    "thinking_face",
    "eyes",
    "fire",
    "tada",
    "clap",
    "raised_hands",
    "rocket",
]

CURATED_REACTION_EMOJIS = [
    "+1",
    "eyes",
    "thinking_face",
    "heart",
    "clap",
    "tada",
    "raised_hands",
]


def fetchall_dict(conn, query, params=()):
    cur = conn.execute(query, params)
    cols = [column[0] for column in cur.description]
    return [dict(zip(cols, row)) for row in cur.fetchall()]


def ensure_db_ready(conn):
    required_tables = {
        "team",
        "channels",
        "users",
        "persona_categories",
        "always_on_channels",
        "messages",
        "channel_weights",
        "story_steps",
        "channel_conversation_steps",
        "channel_conversation_thread_replies",
        "settings",
        "personas",
    }
    rows = fetchall_dict(conn, "SELECT name FROM sqlite_master WHERE type = 'table'")
    existing = {row["name"] for row in rows}
    missing = sorted(required_tables - existing)
    if missing:
        raise RuntimeError(f"mm_data.db is missing required tables: {', '.join(missing)}")

    integrity = conn.execute("PRAGMA integrity_check").fetchone()[0]
    if integrity != "ok":
        raise RuntimeError(f"mm_data.db integrity check failed: {integrity}")

    foreign_key_errors = conn.execute("PRAGMA foreign_key_check").fetchall()
    if foreign_key_errors:
        raise RuntimeError(f"mm_data.db has foreign-key errors: {foreign_key_errors}")


def load_settings(conn):
    rows = fetchall_dict(conn, "SELECT key, value_int FROM settings")
    return {row["key"]: int(row["value_int"]) for row in rows}


def load_core_data(conn):
    team = fetchall_dict(conn, "SELECT * FROM team LIMIT 1")
    if not team:
        raise RuntimeError("team table is empty")

    channels = fetchall_dict(conn, "SELECT * FROM channels ORDER BY name")
    users = fetchall_dict(conn, "SELECT * FROM users ORDER BY username")

    persona_categories = defaultdict(list)
    for row in fetchall_dict(conn, "SELECT persona_key, category FROM persona_categories"):
        persona_categories[row["persona_key"]].append(row["category"])

    always_on = [
        row["channel_name"]
        for row in fetchall_dict(conn, "SELECT channel_name FROM always_on_channels")
    ]

    message_bank = defaultdict(lambda: {"single": [], "reply": []})
    for row in fetchall_dict(conn, "SELECT category, kind, text FROM messages ORDER BY id"):
        if row["kind"] not in {"single", "reply"}:
            raise RuntimeError(f"unsupported message kind: {row['kind']}")
        message_bank[row["category"]][row["kind"]].append(row["text"])

    weights = {
        row["category"]: int(row["weight"])
        for row in fetchall_dict(conn, "SELECT category, weight FROM channel_weights")
    }

    story_steps = fetchall_dict(
        conn,
        """
        SELECT arc_id, step_order, channel_name, category, persona_key, message
        FROM story_steps
        ORDER BY arc_id, step_order
        """,
    )

    conversation_steps = fetchall_dict(
        conn,
        """
        SELECT conversation_id, step_order, channel_name, username,
               day_offset, minute_of_day, message
        FROM channel_conversation_steps
        ORDER BY conversation_id, step_order
        """,
    )

    conversations = defaultdict(list)
    usernames = {user["username"] for user in users}
    for step in conversation_steps:
        conversations[step["conversation_id"]].append(step)
        for mention in MENTION_PATTERN.findall(step["message"]):
            if mention not in usernames | SPECIAL_MENTIONS | {"admin01"}:
                raise RuntimeError(f"conversation mentions unknown user: @{mention}")
    for conversation_id, steps in conversations.items():
        expected_orders = list(range(1, len(steps) + 1))
        actual_orders = [step["step_order"] for step in steps]
        if actual_orders != expected_orders:
            raise RuntimeError(
                f"conversation has non-contiguous steps: {conversation_id} {actual_orders}"
            )
        if len({step["channel_name"] for step in steps}) != 1:
            raise RuntimeError(f"conversation spans multiple channels: {conversation_id}")
        if len({step["username"] for step in steps}) < 2:
            raise RuntimeError(f"conversation has fewer than two authors: {conversation_id}")
        timeline = [(step["day_offset"], step["minute_of_day"]) for step in steps]
        if any(
            current_day != next_day or current_minute >= next_minute
            for (current_day, current_minute), (next_day, next_minute)
            in zip(timeline, timeline[1:])
        ):
            raise RuntimeError(f"conversation timestamps are not increasing: {conversation_id}")

    conversation_thread_replies = fetchall_dict(
        conn,
        """
        SELECT conversation_id, root_step_order, reply_order, username,
               offset_minutes, message
        FROM channel_conversation_thread_replies
        ORDER BY conversation_id, root_step_order, reply_order
        """,
    )
    conversation_roots = {
        (step["conversation_id"], step["step_order"]): step
        for step in conversation_steps
    }
    replies_by_root = defaultdict(list)
    for reply in conversation_thread_replies:
        root_key = (reply["conversation_id"], reply["root_step_order"])
        if root_key not in conversation_roots:
            raise RuntimeError(f"thread reply references unknown root: {root_key}")
        if reply["username"] not in usernames:
            raise RuntimeError(f"thread reply author does not exist: {reply['username']}")
        for mention in MENTION_PATTERN.findall(reply["message"]):
            if mention not in usernames | SPECIAL_MENTIONS | {"admin01"}:
                raise RuntimeError(f"thread reply mentions unknown user: @{mention}")
        replies_by_root[root_key].append(reply)

    for root_key, replies in replies_by_root.items():
        expected_orders = list(range(1, len(replies) + 1))
        actual_orders = [reply["reply_order"] for reply in replies]
        if actual_orders != expected_orders:
            raise RuntimeError(f"thread replies are not contiguous: {root_key} {actual_orders}")
        offsets = [reply["offset_minutes"] for reply in replies]
        if any(current >= following for current, following in zip(offsets, offsets[1:])):
            raise RuntimeError(f"thread reply offsets are not increasing: {root_key}")
        participants = {conversation_roots[root_key]["username"]}
        participants.update(reply["username"] for reply in replies)
        if len(participants) < 2:
            raise RuntimeError(f"thread has fewer than two participants: {root_key}")

    for channel in channels:
        category = channel["category"]
        if not message_bank[category]["single"]:
            raise RuntimeError(f"category has no root messages: {category}")
        if not message_bank[category]["reply"]:
            raise RuntimeError(f"category has no reply messages: {category}")

    return (
        team[0],
        channels,
        users,
        persona_categories,
        always_on,
        message_bank,
        weights,
        story_steps,
        conversation_steps,
        conversation_thread_replies,
    )


def assign_user_channels(
    users,
    channels,
    persona_categories,
    always_on,
    min_members,
    story_steps,
    conversation_steps,
    conversation_thread_replies,
):
    category_to_channels = defaultdict(list)
    all_channel_names = []
    for channel in channels:
        category_to_channels[channel["category"]].append(channel["name"])
        all_channel_names.append(channel["name"])

    memberships = {}
    for user in users:
        member_channels = set(always_on)
        for category in persona_categories.get(user["persona_key"], []):
            member_channels.update(category_to_channels.get(category, []))

        extra_count = random.randint(1, 3)
        member_channels.update(random.sample(all_channel_names, min(extra_count, len(all_channel_names))))
        memberships[user["username"]] = member_channels

    persona_to_users = defaultdict(list)
    for user in users:
        persona_to_users[user["persona_key"]].append(user["username"])
    for step in story_steps:
        candidates = sorted(persona_to_users.get(step["persona_key"], []))
        if not candidates:
            raise RuntimeError(f"story persona has no users: {step['persona_key']}")
        memberships[candidates[0]].add(step["channel_name"])

    for step in conversation_steps:
        username = step["username"]
        if username not in memberships:
            raise RuntimeError(f"conversation author does not exist: {username}")
        memberships[username].add(step["channel_name"])
        for mention in MENTION_PATTERN.findall(step["message"]):
            if mention in memberships:
                memberships[mention].add(step["channel_name"])

    conversation_channels = {
        (step["conversation_id"], step["step_order"]): step["channel_name"]
        for step in conversation_steps
    }
    for reply in conversation_thread_replies:
        root_key = (reply["conversation_id"], reply["root_step_order"])
        channel_name = conversation_channels[root_key]
        memberships[reply["username"]].add(channel_name)
        for mention in MENTION_PATTERN.findall(reply["message"]):
            if mention in memberships:
                memberships[mention].add(channel_name)

    channel_members = {name: set() for name in all_channel_names}
    for username, channel_names in memberships.items():
        for channel_name in channel_names:
            channel_members[channel_name].add(username)

    all_usernames = sorted(user["username"] for user in users)
    for channel_name, members in channel_members.items():
        candidates = [username for username in all_usernames if username not in members]
        random.shuffle(candidates)
        for username in candidates[: max(0, min_members - len(members))]:
            memberships[username].add(channel_name)
            members.add(username)

    return memberships, channel_members


def sample_recent_timestamp(category, settings, now):
    history_days = settings.get("history_days", 21)
    start_hour = settings.get("active_hour_start", 8)
    end_hour = settings.get("active_hour_end", 22)
    business_categories = {
        "admin",
        "announce",
        "aurora",
        "bug",
        "business",
        "customer",
        "design",
        "dev",
        "devtips",
        "incident",
        "project",
        "release",
        "security",
        "weekly",
    }

    while True:
        day_offset = random.randint(1, history_days)
        target_date = now.astimezone(JST).date() - timedelta(days=day_offset)
        if target_date.weekday() >= 5 and category in business_categories and random.random() < 0.8:
            continue

        if category == "latenight":
            hour = random.choice([0, 1, 22, 23])
        elif category in business_categories:
            hour = random.randint(max(start_hour, 9), min(end_hour - 1, 19))
        else:
            hour = random.randint(start_hour, end_hour - 1)

        local_datetime = datetime.combine(
            target_date,
            dt_time(hour, random.randint(0, 59), random.randint(0, 59)),
            tzinfo=JST,
        )
        return int(local_datetime.timestamp() * 1000)


def cycle_messages(messages, count):
    selected = []
    while len(selected) < count:
        batch = list(messages)
        random.shuffle(batch)
        selected.extend(batch)
    return selected[:count]


def add_engagement(post, author, user_pool, replies_bank, now_ms):
    other_users = [username for username in sorted(user_pool) if username != author]
    if not other_users:
        return

    if random.random() < 0.45:
        reactors = random.sample(other_users, min(random.randint(1, 3), len(other_users)))
        post["reactions"] = [
            {
                "user": reactor,
                "emoji_name": random.choice(EMOJI_POOL),
                "create_at": min(now_ms, post["create_at"] + random.randint(60_000, 5_400_000)),
            }
            for reactor in reactors
        ]

    if random.random() < 0.28:
        reply_count = min(random.randint(1, 3), len(other_users))
        reply_authors = random.sample(other_users, reply_count)
        reply_messages = cycle_messages(replies_bank, reply_count)
        post["replies"] = []
        reply_time = post["create_at"]
        for reply_author, message in zip(reply_authors, reply_messages):
            reply_time = min(now_ms, reply_time + random.randint(180_000, 7_200_000))
            post["replies"].append(
                {
                    "user": reply_author,
                    "message": message,
                    "create_at": reply_time,
                    "props": {},
                }
            )


def build_regular_posts(
    team_name,
    channels,
    users,
    persona_categories,
    channel_members,
    message_bank,
    weights,
    settings,
    conversation_steps,
    now,
):
    user_personas = {user["username"]: user["persona_key"] for user in users}
    now_ms = int(now.timestamp() * 1000) - 60_000
    posts = []
    local_today = now.astimezone(JST).date()
    conversation_windows = defaultdict(list)
    conversations = defaultdict(list)
    for step in conversation_steps:
        conversations[step["conversation_id"]].append(step)
    for steps in conversations.values():
        first = steps[0]
        last = steps[-1]
        first_hour, first_minute = divmod(first["minute_of_day"], 60)
        last_hour, last_minute = divmod(last["minute_of_day"], 60)
        start = datetime.combine(
            local_today - timedelta(days=first["day_offset"]),
            dt_time(first_hour, first_minute),
            tzinfo=JST,
        )
        end = datetime.combine(
            local_today - timedelta(days=last["day_offset"]),
            dt_time(last_hour, last_minute),
            tzinfo=JST,
        )
        conversation_windows[first["channel_name"]].append(
            (int(start.timestamp() * 1000), int(end.timestamp() * 1000))
        )

    for channel in channels:
        category = channel["category"]
        user_pool = sorted(channel_members[channel["name"]])
        preferred_authors = [
            username
            for username in user_pool
            if category in persona_categories.get(user_personas[username], [])
        ]
        author_pool = preferred_authors or user_pool
        post_count = weights.get(category, 8)
        root_messages = cycle_messages(message_bank[category]["single"], post_count)

        previous_author = None
        message_dates = defaultdict(set)
        for message in root_messages:
            available_authors = [username for username in author_pool if username != previous_author]
            author = random.choice(available_authors or author_pool)
            previous_author = author
            for _ in range(100):
                create_at = sample_recent_timestamp(category, settings, now)
                local_date = datetime.fromtimestamp(create_at / 1000, JST).date()
                inside_conversation = any(
                    start <= create_at <= end
                    for start, end in conversation_windows[channel["name"]]
                )
                if not inside_conversation and local_date not in message_dates[message]:
                    break
            else:
                raise RuntimeError(
                    f"could not place a regular post outside conversation windows: {channel['name']}"
                )
            message_dates[message].add(datetime.fromtimestamp(create_at / 1000, JST).date())

            post = {
                "team": team_name,
                "channel": channel["name"],
                "user": author,
                "message": message,
                "create_at": create_at,
                "props": {},
            }
            add_engagement(
                post,
                author,
                user_pool,
                message_bank[category]["reply"],
                now_ms,
            )
            posts.append(post)

    return posts


def build_story_posts(team_name, users, channel_members, message_bank, steps, settings, now):
    persona_to_users = defaultdict(list)
    for user in users:
        persona_to_users[user["persona_key"]].append(user["username"])

    arcs = defaultdict(list)
    for step in steps:
        arcs[step["arc_id"]].append(step)

    now_ms = int(now.timestamp() * 1000) - 60_000
    posts = []
    for arc_steps in arcs.values():
        first = arc_steps[0]
        story_time = sample_recent_timestamp(first["category"], settings, now)
        for index, step in enumerate(arc_steps):
            if index:
                story_time = min(now_ms, story_time + random.randint(10_800_000, 86_400_000))

            pool = sorted(channel_members[step["channel_name"]])
            persona_candidates = sorted(
                username
                for username in persona_to_users[step["persona_key"]]
                if username in pool
            )
            if not persona_candidates:
                raise RuntimeError(
                    f"story step has no matching member: {step['arc_id']}#{step['step_order']}"
                )

            author = random.choice(persona_candidates)
            post = {
                "team": team_name,
                "channel": step["channel_name"],
                "user": author,
                "message": step["message"],
                "create_at": story_time,
                "props": {"demo_story": step["arc_id"]},
            }
            add_engagement(
                post,
                author,
                pool,
                message_bank[step["category"]]["reply"],
                now_ms,
            )
            posts.append(post)

    return posts


def add_curated_reactions(post, user_pool, now_ms):
    digest = hashlib.sha256(
        f"{post['props']['demo_conversation']}:{post['props']['demo_conversation_step']}".encode()
    ).digest()
    if digest[0] >= 192:  # Deterministically react to about 75% of curated roots.
        return

    candidates = [username for username in sorted(user_pool) if username != post["user"]]
    if not candidates:
        return

    reaction_count = min(2 + digest[1] % 3, len(candidates))
    chooser = random.Random(int.from_bytes(digest[:8], "big"))
    reactors = chooser.sample(candidates, reaction_count)
    post["reactions"] = [
        {
            "user": reactor,
            "emoji_name": CURATED_REACTION_EMOJIS[
                (digest[2 + index] + index) % len(CURATED_REACTION_EMOJIS)
            ],
            "create_at": min(now_ms, post["create_at"] + (index + 1) * 180_000),
        }
        for index, reactor in enumerate(reactors)
    ]


def build_channel_conversation_posts(
    team_name,
    steps,
    thread_replies,
    channel_members,
    now,
):
    posts = []
    local_today = now.astimezone(JST).date()
    now_ms = int(now.timestamp() * 1000) - 60_000
    replies_by_root = defaultdict(list)
    for reply in thread_replies:
        replies_by_root[(reply["conversation_id"], reply["root_step_order"])].append(reply)

    for step in steps:
        hour, minute = divmod(step["minute_of_day"], 60)
        create_at = datetime.combine(
            local_today - timedelta(days=step["day_offset"]),
            dt_time(hour, minute),
            tzinfo=JST,
        )
        create_at_ms = int(create_at.timestamp() * 1000)
        post = {
            "team": team_name,
            "channel": step["channel_name"],
            "user": step["username"],
            "message": step["message"],
            "create_at": create_at_ms,
            "props": {
                "demo_conversation": step["conversation_id"],
                "demo_conversation_step": step["step_order"],
            },
        }
        root_key = (step["conversation_id"], step["step_order"])
        if root_key in replies_by_root:
            post["replies"] = [
                {
                    "user": reply["username"],
                    "message": reply["message"],
                    "create_at": create_at_ms + reply["offset_minutes"] * 60_000,
                    "props": {
                        "demo_conversation": reply["conversation_id"],
                        "demo_thread_reply_order": reply["reply_order"],
                    },
                }
                for reply in replies_by_root[root_key]
            ]
        add_curated_reactions(post, channel_members[step["channel_name"]], now_ms)
        posts.append(post)
    return posts


def generate_lines(
    team,
    channels,
    users,
    persona_categories,
    memberships,
    channel_members,
    message_bank,
    weights,
    story_steps,
    conversation_steps,
    conversation_thread_replies,
    settings,
):
    team_name = team["name"]
    lines = [{"type": "version", "version": 1}]
    lines.append(
        {
            "type": "team",
            "team": {
                "name": team_name,
                "display_name": team["display_name"],
                "type": team["team_type"],
                "description": team["description"],
                "allow_open_invite": bool(team["allow_open_invite"]),
            },
        }
    )

    for channel in channels:
        lines.append(
            {
                "type": "channel",
                "channel": {
                    "team": team_name,
                    "name": channel["name"],
                    "display_name": channel["display_name"],
                    "type": channel["channel_type"],
                    "purpose": channel["purpose"],
                    "header": channel["header"],
                },
            }
        )

    for user in users:
        profile_image_name = f"profile-{user['username']}.png"
        profile_image_path = os.path.join(PROFILE_IMAGE_DIR, profile_image_name)
        if not os.path.exists(profile_image_path):
            raise RuntimeError(f"profile image is missing: {profile_image_path}")
        team_roles = "team_admin team_user" if user["roles"].startswith("system_admin") else "team_user"
        lines.append(
            {
                "type": "user",
                "user": {
                    "username": user["username"],
                    "email": user["email"],
                    "nickname": user["nickname"],
                    "first_name": user["first_name"],
                    "last_name": user["last_name"],
                    "profile_image": profile_image_name,
                    "roles": user["roles"],
                    "teams": [
                        {
                            "name": team_name,
                            "roles": team_roles,
                            "channels": [
                                {"name": name, "roles": "channel_user"}
                                for name in sorted(memberships[user["username"]])
                            ],
                        }
                    ],
                },
            }
        )

    anchor_ts = settings.get("anchor_ts")
    if anchor_ts is None:
        raise RuntimeError("settings.anchor_ts is required for reproducible imports")
    now = datetime.fromtimestamp(anchor_ts / 1000, JST)
    posts = build_regular_posts(
        team_name,
        channels,
        users,
        persona_categories,
        channel_members,
        message_bank,
        weights,
        settings,
        conversation_steps,
        now,
    )
    posts.extend(
        build_story_posts(
            team_name,
            users,
            channel_members,
            message_bank,
            story_steps,
            settings,
            now,
        )
    )
    posts.extend(
        build_channel_conversation_posts(
            team_name,
            conversation_steps,
            conversation_thread_replies,
            channel_members,
            now,
        )
    )

    for post in sorted(posts, key=lambda item: item["create_at"]):
        lines.append({"type": "post", "post": post})

    return lines


def validate_lines(lines):
    posts = [line["post"] for line in lines if line["type"] == "post"]
    if not posts:
        raise RuntimeError("no posts were generated")

    now_ms = int(time.time() * 1000)
    post_keys = set()
    conversation_positions = defaultdict(lambda: defaultdict(list))
    for index, post in enumerate(sorted(posts, key=lambda item: (item["channel"], item["create_at"]))):
        required = {"team", "channel", "user", "message", "create_at", "props"}
        missing = sorted(required - post.keys())
        if missing:
            raise RuntimeError(f"generated post is missing fields: {missing}")
        if post["create_at"] > now_ms:
            raise RuntimeError("generated post has a future timestamp")

        post_key = (post["channel"], post["create_at"])
        if post_key in post_keys:
            raise RuntimeError(f"generated posts share a channel timestamp: {post_key}")
        post_keys.add(post_key)

        conversation_id = post["props"].get("demo_conversation")
        if conversation_id:
            conversation_positions[post["channel"]][conversation_id].append(index)

        reaction_users = set()
        for reaction in post.get("reactions", []):
            if reaction["user"] == post["user"]:
                raise RuntimeError("generated post has a self-reaction")
            if reaction["user"] in reaction_users:
                raise RuntimeError("generated post repeats a reaction user")
            reaction_users.add(reaction["user"])
            if reaction["create_at"] <= post["create_at"]:
                raise RuntimeError("generated reaction does not follow its post")
            if reaction["create_at"] > now_ms:
                raise RuntimeError("generated reaction has a future timestamp")
        for reply in post.get("replies", []):
            if reply["user"] == post["user"] and "demo_conversation" not in reply["props"]:
                raise RuntimeError("generated post has a self-reply")
            if reply["create_at"] <= post["create_at"]:
                raise RuntimeError("generated reply does not follow its root post")
            if reply["create_at"] > now_ms:
                raise RuntimeError("generated reply has a future timestamp")

    for channel_name, conversations in conversation_positions.items():
        for conversation_id, positions in conversations.items():
            expected = list(range(positions[0], positions[0] + len(positions)))
            if positions != expected:
                raise RuntimeError(
                    f"conversation is interrupted in {channel_name}: {conversation_id}"
                )

    return posts


def write_zip_only(lines, users):
    payload = "".join(
        json.dumps(obj, ensure_ascii=False, separators=(", ", ": ")) + "\n"
        for obj in lines
    ).encode("utf-8")
    zip_info = zipfile.ZipInfo("import.jsonl", date_time=(2026, 1, 1, 0, 0, 0))
    zip_info.compress_type = zipfile.ZIP_DEFLATED
    zip_info.external_attr = 0o644 << 16
    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as zip_file:
        zip_file.writestr(zip_info, payload)
        for user in users:
            profile_image_name = f"profile-{user['username']}.png"
            profile_image_path = os.path.join(PROFILE_IMAGE_DIR, profile_image_name)
            image_info = zipfile.ZipInfo(
                f"data/{profile_image_name}",
                date_time=(2026, 1, 1, 0, 0, 0),
            )
            image_info.compress_type = zipfile.ZIP_DEFLATED
            image_info.external_attr = 0o644 << 16
            with open(profile_image_path, "rb") as profile_image:
                zip_file.writestr(image_info, profile_image.read())


def main():
    if not os.path.exists(DB_PATH):
        raise FileNotFoundError(
            "mm_data.db not found. Prepare script/mm_data.db externally, then rerun generate_mm_import.py"
        )

    with sqlite3.connect(DB_PATH) as conn:
        conn.execute("PRAGMA foreign_keys = ON")
        ensure_db_ready(conn)
        settings = load_settings(conn)
        random.seed(settings.get("seed", 42))
        (
            team,
            channels,
            users,
            persona_categories,
            always_on,
            message_bank,
            weights,
            story_steps,
            conversation_steps,
            conversation_thread_replies,
        ) = load_core_data(conn)

        memberships, channel_members = assign_user_channels(
            users,
            channels,
            persona_categories,
            always_on,
            settings.get("min_channel_members", 5),
            story_steps,
            conversation_steps,
            conversation_thread_replies,
        )
        lines = generate_lines(
            team,
            channels,
            users,
            persona_categories,
            memberships,
            channel_members,
            message_bank,
            weights,
            story_steps,
            conversation_steps,
            conversation_thread_replies,
            settings,
        )

    posts = validate_lines(lines)
    write_zip_only(lines, users)

    message_counts = Counter(post["message"] for post in posts)
    replies = sum(len(post.get("replies", [])) for post in posts)
    reacting_roots = sum(bool(post.get("reactions")) for post in posts)
    reactions = sum(len(post.get("reactions", [])) for post in posts)
    long_roots = sum(len(post["message"]) >= 180 for post in posts)
    conversations = {
        post["props"]["demo_conversation"]
        for post in posts
        if "demo_conversation" in post["props"]
    }
    mention_posts = sum("@" in post["message"] for post in posts)
    print("=" * 60)
    print("Mattermost dummy data generated from SQLite")
    print("=" * 60)
    print(f"DB            : {DB_PATH}")
    print(f"Users         : {len(users)}")
    print(f"Channels      : {len(channels)}")
    print(f"Posts         : {len(posts)}")
    print(f"Replies       : {replies}")
    print(f"Reacting roots: {reacting_roots}")
    print(f"Reactions     : {reactions}")
    print(f"Long roots    : {long_roots}")
    print(f"Conversations : {len(conversations)}")
    print(f"Mention roots : {mention_posts}")
    print(f"Unique roots  : {len(message_counts)}")
    print(f"Max duplicate : {max(message_counts.values())}")
    print(f"Import ZIP    : {ZIP_PATH}")
    print("=" * 60)


if __name__ == "__main__":
    main()
