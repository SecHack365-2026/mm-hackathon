#!/bin/bash

# --- 設定項目 ---
MM_URL="http://localhost:8065"             # MattermostのURL
DATA_FILE="/work/stream_posts.json"     # Pythonが出力した1割データ
TOKENS_FILE="/work/tokens.json"         # トークンマップ
TEAM_NAME="sh365-fes"
# ----------------

# 必須ツールの確認
if ! command -v jq &> /dev/null || ! command -v curl &> /dev/null; then
    echo "curl and jq are required."
    exit 1
fi

# 1回あたりの投稿数をランダム（2〜3件）に設定
POST_COUNT=$((RANDOM % 2 + 2))

# ユーザーのトークンを取得する関数
get_user_token() {
    local username=$1
    jq -r ".\"${username}\" // empty" "$TOKENS_FILE"
}

# チャンネルIDを取得する関数
get_channel_id() {
    local channel_name=$1
    local user_token=$2
    curl -s -H "Authorization: Bearer ${user_token}" \
         "${MM_URL}/api/v4/teams/name/${TEAM_NAME}/channels/name/${channel_name}" \
         | jq -r '.id'
}

# 投稿メイン処理
for (( i=1; i<=$POST_COUNT; i++ )); do
    TOTAL_ITEMS=$(jq '. | length' "$DATA_FILE")
    if [ "$TOTAL_ITEMS" -eq 0 ]; then
        echo "No more posts left."
        exit 0
    fi
    
    # ランダムに1件選択
    RAND_IDX=$((RANDOM % TOTAL_ITEMS))
    TARGET_POST=$(jq -r ".[$RAND_IDX]" "$DATA_FILE")
    
    CHANNEL_NAME=$(echo "$TARGET_POST" | jq -r '.channel_name')
    USERNAME=$(echo "$TARGET_POST" | jq -r '.username')
    MESSAGE=$(echo "$TARGET_POST" | jq -r '.message')
    
    # ユーザーのアクセストークンを取得
    USER_TOKEN=$(get_user_token "$USERNAME")
    
    if [ -z "$USER_TOKEN" ]; then
        echo "Skip: Token for user '${USERNAME}' not found."
        continue
    fi

    # Channel ID の取得
    CHANNEL_ID=$(get_channel_id "$CHANNEL_NAME" "$USER_TOKEN")

    if [ "$CHANNEL_ID" != "null" ] && [ -n "$CHANNEL_ID" ]; then
        # ペイロード作成
        PAYLOAD=$(jq -n \
            --arg cid "$CHANNEL_ID" \
            --arg msg "$MESSAGE" \
            '{
                channel_id: $cid,
                message: $msg
            }')

        # 該当ユーザー本人のPATで投稿実行
        curl -s -X POST \
             -H "Authorization: Bearer ${USER_TOKEN}" \
             -H "Content-Type: application/json" \
             -d "$PAYLOAD" \
             "${MM_URL}/api/v4/posts" > /dev/null

        # 投稿済みデータを JSON から削除
        TMP_JSON=$(mktemp)
        jq "del(.[$RAND_IDX])" "$DATA_FILE" > "$TMP_JSON" && mv "$TMP_JSON" "$DATA_FILE"
    fi
    
    # 連投感を減らすためにランダムな待機時間（5〜15秒）を入れる
    sleep $((RANDOM % 11 + 5))
done
