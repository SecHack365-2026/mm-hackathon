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
    ├── generate_mm_import.py
    ├── refresh_dummy_data.sql
    └── mm_data.db
```

## Mattermostインポート元データ

- Mattermostインポート元データは `script/mm_data.db` に格納します。
- `script/generate_mm_import.py` は、既存の `script/mm_data.db` をそのまま読み込んでインポートZIPを作成します。
- 投稿はビルド時点から直近3週間へ分散し、業務系チャンネルは主に平日日中、深夜雑談は深夜帯に配置されます。
- `script/refresh_dummy_data.sql` は文面・投稿量・ペルソナ対応を現在のデモ向け状態へ戻す、再実行可能な更新SQLです。

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

## ダミーデータの確認と更新

```bash
# DBの整合性確認
sqlite3 script/mm_data.db 'PRAGMA integrity_check; PRAGMA foreign_key_check;'

# 文面や重みを標準状態へ戻す
sqlite3 script/mm_data.db < script/refresh_dummy_data.sql

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
