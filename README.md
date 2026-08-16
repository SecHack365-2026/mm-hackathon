# 夏祭りハッカソン環境 (mm-hackathon)

このリポジトリは、Mattermostのハッカソン環境を自動構築・運用するためのセットアップスクリプト群です。

## ディレクトリ構造

```text
mm-hackathon/
├── README.md                   # リポジトリ全体ガイド
├── .gitignore                  # Git管理除外設定
└── docker/                     # Docker環境構築ディレクトリ
    ├── Dockerfile              # Dockerビルド定義
    ├── docker-entry-custom.sh  # セットアップスクリプト
    └── src/                    # 処理用スクリプト群
        ├── generate_mm_import.py  # ダミーデータ生成スクリプト
        ├── get_token.sh           # 初期ユーザーのトークン取得スクリプト
        └── stream_post.sh         # リアルタイム投稿用スクリプト
```

## 使い方

### 1. イメージのビルド

リポジトリのルートディレクトリ (`mm-hackathon/`) から以下を実行します。

```bash
docker build -t mm-sh365fes:latest ./docker
```

※ `docker/` ディレクトリ内に移動してビルドする場合:
```bash
cd docker
docker build -t mm-sh365fes:latest .
```

### 2. コンテナの起動

```bash
docker run -d \
  --name mm-sh365fes \
  -p 8065:8065 \
  mm-sh365fes:latest
```

### 3. 環境へのアクセス

コンテナのログで緑色の `INITIAL SETUP FINISHED` が確認できたら、ブラウザからアクセスしてください。

```bash
docker logs -f mm-sh365fes
```

- **URL:** http://localhost:8065
- **ユーザー名:** `user01`
- **パスワード:** `SH365Fes`

## メンテナンス・削除

### コンテナの停止・削除（匿名ボリューム含む）

```bash
docker rm -vf mm-sh365fes
```

### イメージの削除

```bash
docker rmi mm-sh365fes:latest
```

## 開発メモ

- 起動時の自動セットアップロジックは `docker/docker-entrypoint.sh` に記述します。
- 処理用スクリプトの追加・修正は `docker/src/` 配下で行います。
