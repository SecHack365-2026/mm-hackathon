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
    
    # 1. Configファイルをjqで書き換え（LocalMode, PAT, Bot, Team削除を事前に有効化）
    echo "Enabling LocalMode and API features in config..."
    jq '.ServiceSettings.EnableLocalMode = true | .ServiceSettings.EnableUserAccessTokens = true | .ServiceSettings.EnableBotAccountCreation = true | .ServiceSettings.EnableAPITeamDeletion = true' /mm/mattermost/config/config_docker.json > /tmp/config_tmp.json
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
    echo "Creating admin user (user01) and default team..."
    mmctl user create --local --email user01@sh365.fes --username user01 --password SH365Fes
    mmctl user make_admin --local user01
    
    # 元の手順に合わせてdefaultチームも一応作っておく（後でStep6で削除される）
    mmctl team create --local --name default --display-name "default"

    # 4. ダミーデータの生成とインポート
    # ※ --local フラグを使うことでパスワード認証なしで実行可能
    echo "Generating and importing dummy data..."
    python3 /work/generate_mm_import.py
    mmctl import process --local --bypass-upload /work/mattermost_import.zip
    
    echo "Waiting 30 seconds for import to finish..."
    sleep 30
    
    # 5. PATの発行
    echo "Generating PATs..."
    bash /work/get_token.sh

    # 6. Default Teamの削除
    echo "Deleting default team..."
    mmctl team delete default --local --confirm || true

    # 7. cronの設定
    echo "Configuring cron jobs..."
    echo "* * * * * bash /work/stream_post.sh >> /work/stream.log 2>&1" | crontab -

    # 8. 不要ファイルの削除 (コンテナサイズ軽減にはならないが、コンテナ内をクリーンにするため)
    rm -f /work/generate_mm_import.py /work/get_token.sh /work/mattermost_import.zip /work/import.jsonl
    
    # 9. 初期化フラグの作成
    echo "Initial setup completed. Creating flag."
    touch "$INIT_FLAG"

    # 10. 一時起動したMattermostを安全にシャットダウン
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

# cronの起動
echo "Starting cron service..."
service cron start

# 通常のMattermost起動（フォアグラウンド）
echo "Starting Mattermost (Foreground)..."
cd /mm/mattermost
exec ./bin/mattermost --config=config/config_docker.json
