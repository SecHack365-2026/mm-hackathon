#!/bin/bash

echo "Starting PostgreSQL"
docker-entrypoint.sh -c 'shared_buffers=256MB' -c 'max_connections=300' &

until pg_isready -hlocalhost -p 5432 -U "$POSTGRES_USER" &> /dev/null; do
    echo "postgres still not ready, sleeping"
    sleep 5
done

echo "Updating CA certificates"
update-ca-certificates --fresh >/dev/null

INIT_FLAG="/mm/mattermost-data/.sh365-initialized"

if [ ! -f "$INIT_FLAG" ]; then
    echo "========== STARTING INITIAL SETUP =========="
    
    # 1. ローカルデモ向けの設定を有効化
    echo "Configuring local demo settings..."
    jq '.ServiceSettings.EnableLocalMode = true
        | .ServiceSettings.EnableUserAccessTokens = true
        | .ServiceSettings.EnableBotAccountCreation = true
        | .ServiceSettings.EnableAPITeamDeletion = true
        | .ServiceSettings.SiteURL = "http://localhost:8065"
        | .TeamSettings.TeammateNameDisplay = "nickname_full_name"' \
        /mm/mattermost/config/config_docker.json > /tmp/config_tmp.json
    mv /tmp/config_tmp.json /mm/mattermost/config/config_docker.json

    # 2. Mattermostをバックグラウンドで一時起動
    echo "Starting Mattermost temporarily for setup..."
    cd /mm/mattermost
    ./bin/mattermost --config=config/config_docker.json &
    MM_PID=$!
    cd /mm

    # 3. 起動完了を待機
    echo "Waiting for Mattermost API to be ready..."
    until curl -s http://localhost:8065 > /dev/null; do
        sleep 3
    done
    sleep 5 # 完全に立ち上がるまで少し余裕を見る

    # 3.5 ユーザーと初期チームの作成（ローカル利用のみ想定）
    echo "Creating admin user (admin01) and default team..."
    mmctl user create --local --email admin01@sh365.fes --username admin01 --password SH365Fes
    mmctl user make_admin --local admin01
    mmctl team create --local --name default --display-name "default"

    # previewイメージ同梱のAIプラグインは設定済みのAIユーザーを要求するため、
    # 汎用Botデモでは無効化して不要な404とUI項目を出さない。
    echo "Disabling the unconfigured Mattermost AI plugin..."
    mmctl plugin disable mattermost-ai --local || true

    # 4. ダミーデータの生成とインポート
    # ※ --local フラグを使うことでパスワード認証なしで実行可能
    echo "Generating and importing dummy data..."
    python3 /work/generate_mm_import.py
    IMPORT_OUTPUT="$(mmctl import process --local --bypass-upload /work/mattermost_import.zip)"
    echo "$IMPORT_OUTPUT"
    IMPORT_JOB_ID="${IMPORT_OUTPUT##*ID: }"

    echo "Waiting for import job $IMPORT_JOB_ID..."
    for _ in $(seq 1 90); do
        IMPORT_STATUS="$(mmctl import job show "$IMPORT_JOB_ID" --local --json | jq -r '.[0].status')"
        case "$IMPORT_STATUS" in
            success)
                echo "Import completed successfully."
                break
                ;;
            error|canceled)
                echo "Import failed with status: $IMPORT_STATUS" >&2
                exit 1
                ;;
        esac
        sleep 2
    done

    if [ "$IMPORT_STATUS" != "success" ]; then
        echo "Import did not finish within 180 seconds." >&2
        exit 1
    fi
    
    # 5. 初期チームと自動生成チャンネルを整理
    echo "Deleting default team..."
    mmctl team delete default --local --confirm || true

    echo "Removing the unused Off-Topic channel..."
    mmctl channel delete sh365-fes:off-topic --local --confirm || true

    # README記載の管理者アカウントから全デモチャンネルを確認できるようにする
    echo "Adding admin01 to all demo channels..."
    mmctl team users add sh365-fes admin01 --local
    while IFS= read -r channel_name; do
        mmctl channel users add "sh365-fes:$channel_name" admin01 --local
    done < <(mmctl channel list sh365-fes --local --json | jq -r '.[].name')

    # 6. 不要ファイルの削除 (コンテナ内をクリーンにするため)
    rm -f /work/generate_mm_import.py /work/mattermost_import.zip /work/import.jsonl
    
    # 7. 初期化フラグの作成
    echo "Initial setup completed. Creating flag."
    touch "$INIT_FLAG"

    # 8. 一時起動したMattermostを安全にシャットダウン
    echo "Stopping temporary Mattermost..."
    kill $MM_PID
    wait $MM_PID

    GREEN='\033[0;32m'
    NC='\033[0m'

    echo
    echo -e "${GREEN}################################################################${NC}"
    echo -e "${GREEN}#                                                              #${NC}"
    echo -e "${GREEN}#              INITIAL SETUP FINISHED                         #${NC}"
    echo -e "${GREEN}#                                                              #${NC}"
    echo -e "${GREEN}#       Open Mattermost in your browser:                      #${NC}"
    echo -e "${GREEN}#                                                              #${NC}"
    echo -e "${GREEN}#                  http://localhost:8065                       #${NC}"
    echo -e "${GREEN}#                                                              #${NC}"
    echo -e "${GREEN}################################################################${NC}"
    echo
fi

# 通常のMattermost起動（フォアグラウンド）
echo "Starting Mattermost (Foreground)..."
cd /mm/mattermost
exec ./bin/mattermost --config=config/config_docker.json
