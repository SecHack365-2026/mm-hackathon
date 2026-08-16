FROM mattermost/mattermost-preview:latest

# rootユーザーで作業
USER root

# 必要なパッケージをインストール
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        cron \
        jq \
        curl \
        python3 && \
    rm -rf /var/lib/apt/lists/*

# ワークディレクトリを作成
WORKDIR /work

# 処理用スクリプト群をコピー
COPY src/ /work/

# エントリーポイントスクリプトの設定
WORKDIR /mm
COPY docker-entry-custom.sh /mm/docker-entry.sh
RUN chmod +x /mm/docker-entry.sh /work/*.sh
