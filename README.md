# 夏祭りハッカソン環境 (mm-hackathon)

このリポジトリは、Mattermostのハッカソン環境を自動構築・運用するためのセットアップスクリプト群です。

## ディレクトリ構造

```text
mm-hackathon/
├── README.md
├── .gitignore
├── Dockerfile
├── docker-entry-custom.sh
└── script/
    ├── conversation_seeds/
    │   ├── business.sql
    │   ├── business_thread_replies.sql
    │   ├── social.sql
    │   ├── social_thread_replies.sql
    │   ├── technical.sql
    │   └── technical_thread_replies.sql
    ├── generate_mm_import.py
    ├── refresh_dummy_data.sh
    ├── refresh_dummy_data.sql
    └── mm_data.db
```

## Mattermostインポート元データ

- Mattermostインポート元データは `script/mm_data.db` に格納します。
- `script/generate_mm_import.py` は、既存の `script/mm_data.db` をそのまま読み込んでインポートZIPを作成します。
- 投稿は2026年8月28日18時（JST）を基準に直近3週間へ分散し、業務系チャンネルは主に平日日中、深夜雑談は深夜帯に配置されます。
- 全体で1,044件のルート投稿と1,228件の返信を収録しています。
- 130本の会話に、通常のチャンネル投稿766件と文脈付きスレッド返信1,080件を組み合わせています。技術・運営・雑談の追加分は、それぞれ40会話・240ルート・360返信です。
- 会話途中の投稿にもスレッドが付く構成を混ぜ、ルート投稿とスレッドをまだ厳密に使い分けていないチームの履歴にしています。
- 180文字以上の長文ルートを30件収録し、短い投稿にも背景・判断理由・気遣いが伝わる文面を混ぜています。
- リアクション付きルートは687件、リアクション総数は1,912件です。
- メンションを含むルート投稿は201件です。管理者だけでなく、ダミーユーザー同士の直接メンションも含みます。
- メンションはBotの入力や通知一覧を試すためのインポート済み履歴です。インポート時にメールやPush通知を送信するものではありません。
- `script/refresh_dummy_data.sh` は、基礎データと分割された会話seedを順番に適用し、現在のデモ向け状態へ戻す再実行可能な更新処理です。

## 使い方

### 1. リポジトリ取得

```bash
git clone https://github.com/SecHack365-2026/mm-hackathon
cd mm-hackathon
```

### 2. イメージのビルド

```bash
docker build --platform linux/amd64 -t mm-sh365fes:latest .
```

`mattermost-preview` は現在 `linux/amd64` イメージのみ配布されているため、Apple Siliconを含めプラットフォーム指定が必要です。

### 3. コンテナの起動

```bash
docker run -d \
  --platform linux/amd64 \
  --name mm-sh365fes \
  -p 8065:8065 \
  mm-sh365fes:latest
```

### 4. 環境へのアクセス

ログで緑色の `INITIAL SETUP FINISHED` が表示されたらブラウザからアクセスしてください。

```bash
docker logs -f mm-sh365fes
```

- URL: http://localhost:8065
- ユーザー名: admin01
- パスワード: SH365Fes

`admin01` は初期化時に全デモチャンネルへ参加します。
画面上の投稿者名には `user01` ではなく、DBの日本語ニックネームが表示されます。

## Botを作成して投稿APIを試す

Mattermostへ`admin01`でログインし、メインメニューの「統合機能」→「Botアカウント」→「Botアカウントを追加する」から、ユーザー名`hackathon-bot`のBotを作成します。
作成時にアクセストークンが一度だけ表示されます。トークンはGitへ記録せず、手元だけで扱ってください。

作成したBotをデモチームと`Bot実験場`へ追加します。

```bash
docker exec mm-sh365fes mmctl team users add sh365-fes hackathon-bot --local
docker exec mm-sh365fes mmctl channel users add \
  sh365-fes:bot-playground hackathon-bot --local
```

作成時に表示されたトークンを設定し、`Bot実験場`のチャンネルIDを取得して投稿します。

```bash
BOT_TOKEN='ここに表示されたトークンを設定'
CHANNEL_ID=$(docker exec mm-sh365fes bash -lc \
  '/mm/mattermost/bin/mmctl channel list sh365-fes --local --json | jq -r ".[] | select(.name == \"bot-playground\") | .id"')

curl -sS -X POST http://localhost:8065/api/v4/posts \
  -H "Authorization: Bearer ${BOT_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d "{\"channel_id\":\"${CHANNEL_ID}\",\"message\":\"Bot APIから投稿できました :tada:\"}"
```

## ダミーデータの確認と更新

```bash
# DBの整合性確認
sqlite3 script/mm_data.db 'PRAGMA integrity_check; PRAGMA foreign_key_check;'

# 文面・会話・スレッド返信を標準状態へ戻す
./script/refresh_dummy_data.sh

# インポートZIPを生成し、件数・重複数も確認する
python3 script/generate_mm_import.py
```

生成される `script/mattermost_import.zip` はビルド時にも作られる一時成果物で、Git管理には含めません。

## メンテナンス

### コンテナの停止・削除

```bash
docker rm -vf mm-sh365fes
```

### イメージ削除

```bash
docker rmi mm-sh365fes:latest
```
