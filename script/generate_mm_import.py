# -*- coding: utf-8 -*-

"""Generate Mattermost import ZIP from SQLite source data."""

import json
import os
import random
import sqlite3
import zipfile
from collections import defaultdict


OUT_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(OUT_DIR, "mm_data.db")
ZIP_PATH = os.path.join(OUT_DIR, "mattermost_import.zip")
TEMP_JSONL_PATH = os.path.join(OUT_DIR, "import.jsonl")

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

GENERIC_FOLLOWUPS = [
    "続きが気になります。",
    "状況共有ありがとうございます。",
    "その視点は大事ですね。",
    "了解です。こちらでも確認します。",
    "明日の定例でも確認しましょう。",
]


def ensure_db_ready(conn):
    required_tables = [
        "team",
        "channels",
        "users",
        "persona_categories",
        "always_on_channels",
        "messages",
        "channel_weights",
        "story_steps",
        "settings",
        "personas",
    ]
    rows = fetchall_dict(conn, "SELECT name FROM sqlite_master WHERE type = 'table'")
    existing = {r["name"] for r in rows}
    missing = [table for table in required_tables if table not in existing]
    if missing:
        raise RuntimeError(f"mm_data.db is missing required tables: {', '.join(missing)}")


def fetchall_dict(conn, query, params=()):
    cur = conn.execute(query, params)
    cols = [c[0] for c in cur.description]
    return [dict(zip(cols, row)) for row in cur.fetchall()]


def load_settings(conn):
    rows = fetchall_dict(conn, "SELECT key, value_int FROM settings")
    return {r["key"]: int(r["value_int"]) for r in rows}


def load_core_data(conn):
    team = fetchall_dict(conn, "SELECT * FROM team LIMIT 1")
    if not team:
        raise RuntimeError("team table is empty")

    channels = fetchall_dict(conn, "SELECT * FROM channels ORDER BY name")
    users = fetchall_dict(conn, "SELECT * FROM users ORDER BY username")

    persona_cats = defaultdict(list)
    for row in fetchall_dict(conn, "SELECT persona_key, category FROM persona_categories"):
        persona_cats[row["persona_key"]].append(row["category"])

    always_on = [
        r["channel_name"]
        for r in fetchall_dict(conn, "SELECT channel_name FROM always_on_channels")
    ]

    message_bank = defaultdict(lambda: {"single": [], "reply": []})
    for row in fetchall_dict(conn, "SELECT category, kind, text FROM messages"):
        message_bank[row["category"]][row["kind"]].append(row["text"])

    weights = {
        r["category"]: int(r["weight"])
        for r in fetchall_dict(conn, "SELECT category, weight FROM channel_weights")
    }

    story_steps = fetchall_dict(
        conn,
        """
        SELECT arc_id, step_order, channel_name, category, persona_key, message
        FROM story_steps
        ORDER BY arc_id, step_order
        """,
    )

    return team[0], channels, users, persona_cats, always_on, message_bank, weights, story_steps


def next_ts_factory(base_ts):
    cursor = {"v": base_ts}

    def _next(min_gap=1000, max_gap=1800000):
        cursor["v"] += random.randint(min_gap, max_gap)
        return cursor["v"]

    return _next


def assign_user_channels(users, channels, persona_cats, always_on, min_members):
    category_to_channels = defaultdict(list)
    all_channel_names = []
    for ch in channels:
        category_to_channels[ch["category"]].append(ch["name"])
        all_channel_names.append(ch["name"])

    memberships = {}
    for user in users:
        member_channels = set(always_on)
        for category in persona_cats.get(user["persona_key"], []):
            member_channels.update(category_to_channels.get(category, []))

        extra_count = random.randint(3, 7)
        member_channels.update(random.sample(all_channel_names, min(extra_count, len(all_channel_names))))
        memberships[user["username"]] = set(member_channels)

    channel_members = {name: set() for name in all_channel_names}
    for username, chs in memberships.items():
        for ch in chs:
            channel_members[ch].add(username)

    all_usernames = [u["username"] for u in users]
    for channel_name, members in channel_members.items():
        if len(members) >= min_members:
            continue

        need = min_members - len(members)
        candidates = [u for u in all_usernames if u not in members]
        random.shuffle(candidates)
        for username in candidates[:need]:
            memberships[username].add(channel_name)
            members.add(username)

    return memberships, channel_members


def build_post(team_name, channel_name, category, user_pool, bank, next_ts):
    singles = bank.get(category, {}).get("single", [])
    replies_bank = bank.get(category, {}).get("reply", [])

    if not singles:
        singles = ["(empty message bank)"]

    post = {
        "team": team_name,
        "channel": channel_name,
        "user": random.choice(user_pool),
        "message": random.choice(singles),
        "create_at": next_ts(),
    }

    if random.random() < 0.55 and len(user_pool) > 1:
        reactors = random.sample(user_pool, min(random.randint(1, 3), len(user_pool)))
        post["reactions"] = [
            {
                "user": reactor,
                "emoji_name": random.choice(EMOJI_POOL),
                "create_at": next_ts(500, 5000),
            }
            for reactor in reactors
        ]

    if random.random() < 0.35 and len(user_pool) > 1:
        reply_pool = replies_bank + GENERIC_FOLLOWUPS
        post["replies"] = [
            {
                "user": random.choice(user_pool),
                "message": random.choice(reply_pool),
                "create_at": next_ts(2000, 600000),
            }
            for _ in range(random.randint(1, 4))
        ]

    return post


def build_story_posts(team_name, users, channel_members, steps, next_ts):
    persona_to_users = defaultdict(list)
    for user in users:
        persona_to_users[user["persona_key"]].append(user["username"])

    posts = []
    for step in steps:
        pool = list(channel_members.get(step["channel_name"], []))
        if not pool:
            continue

        persona_candidates = [u for u in persona_to_users[step["persona_key"]] if u in pool]
        author = random.choice(persona_candidates or pool)
        post = {
            "team": team_name,
            "channel": step["channel_name"],
            "user": author,
            "message": step["message"],
            "create_at": next_ts(15000, 1800000),
        }

        if random.random() < 0.7 and len(pool) > 1:
            post["replies"] = [
                {
                    "user": random.choice(pool),
                    "message": random.choice(GENERIC_FOLLOWUPS),
                    "create_at": next_ts(2000, 180000),
                }
                for _ in range(random.randint(1, 2))
            ]

        posts.append(post)

    return posts


def generate_lines(team, channels, users, memberships, channel_members, message_bank, weights, story_steps, next_ts):
    team_name = team["name"]

    lines = [{"type": "version", "version": 1}]
    lines.append(
        {
            "type": "team",
            "team": {
                "name": team["name"],
                "display_name": team["display_name"],
                "type": team["team_type"],
                "description": team["description"],
                "allow_open_invite": bool(team["allow_open_invite"]),
            },
        }
    )

    for ch in channels:
        lines.append(
            {
                "type": "channel",
                "channel": {
                    "team": team_name,
                    "name": ch["name"],
                    "display_name": ch["display_name"],
                    "type": ch["channel_type"],
                    "purpose": ch["purpose"],
                    "header": ch["header"],
                },
            }
        )

    for user in users:
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

    post_objects = []
    post_objects.extend(build_story_posts(team_name, users, channel_members, story_steps, next_ts))

    for ch in channels:
        user_pool = list(channel_members[ch["name"]])
        if not user_pool:
            continue

        post_count = weights.get(ch["category"], 40)
        for _ in range(post_count):
            post_objects.append(
                build_post(team_name, ch["name"], ch["category"], user_pool, message_bank, next_ts)
            )

    post_objects.sort(key=lambda post: post["create_at"])
    for post in post_objects:
        lines.append({"type": "post", "post": post})

    return lines


def write_zip_only(lines):
    with open(TEMP_JSONL_PATH, "w", encoding="utf-8") as file:
        for obj in lines:
            file.write(json.dumps(obj, ensure_ascii=False, separators=(", ", ": ")))
            file.write("\n")

    with zipfile.ZipFile(ZIP_PATH, "w", zipfile.ZIP_DEFLATED) as zip_file:
        zip_file.write(TEMP_JSONL_PATH, arcname="import.jsonl")

    if os.path.exists(TEMP_JSONL_PATH):
        os.remove(TEMP_JSONL_PATH)


def main():
    if not os.path.exists(DB_PATH):
        raise FileNotFoundError(
            "mm_data.db not found. Prepare script/mm_data.db externally, then rerun generate_mm_import.py"
        )

    with sqlite3.connect(DB_PATH) as conn:
        ensure_db_ready(conn)
        settings = load_settings(conn)
        random.seed(settings.get("seed", 42))
        next_ts = next_ts_factory(settings.get("base_ts", 1783000000000))

        team, channels, users, persona_cats, always_on, message_bank, weights, story_steps = load_core_data(conn)

        memberships, channel_members = assign_user_channels(
            users,
            channels,
            persona_cats,
            always_on,
            settings.get("min_channel_members", 5),
        )

        lines = generate_lines(
            team,
            channels,
            users,
            memberships,
            channel_members,
            message_bank,
            weights,
            story_steps,
            next_ts,
        )

    write_zip_only(lines)

    print("=" * 60)
    print("Mattermost dummy data generated from SQLite")
    print("=" * 60)
    print(f"DB            : {DB_PATH}")
    print(f"Users         : {len([l for l in lines if l['type'] == 'user'])}")
    print(f"Channels      : {len([l for l in lines if l['type'] == 'channel'])}")
    print(f"Posts         : {len([l for l in lines if l['type'] == 'post'])}")
    print(f"Import ZIP    : {ZIP_PATH}")
    print("=" * 60)


if __name__ == "__main__":
    main()
