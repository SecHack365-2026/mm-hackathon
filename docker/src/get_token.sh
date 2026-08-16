#!/bin/bash

INPUT="/work/stream_posts.json"
OUTPUT="/work/tokens.json"

# 必ず空のJSONオブジェクトを作成
echo '{}' > "$OUTPUT"

for user in $(jq -r '.[].username' "$INPUT" | sort -u); do
    echo "トークン発行中: $user" >&2

    TOKEN=$(mmctl token generate "$user" "Stream-Bot-Token" --json 2>/dev/null \
        | jq -r '.[0].token')

    if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
        echo "ERROR: $user のトークン発行に失敗しました" >&2
        continue
    fi

    jq --arg user "$user" --arg token "$TOKEN" \
        '. + {($user): $token}' \
        "$OUTPUT" > "${OUTPUT}.tmp" && mv "${OUTPUT}.tmp" "$OUTPUT"
done