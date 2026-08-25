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
    └── mm_data.db
```

## Mattermostインポート元データ

- Mattermostインポート元データは `script/mm_data.db` に格納します。
- `script/generate_mm_import.py` は、既存の `script/mm_data.db` をそのまま読み込んでインポートZIPを作成します。

## 使い方

### 1. リポジトリ取得

```bash
git clone <YOUR_REPOSITORY_URL>
cd mm-hackathon
```

### 2. イメージのビルド

リポジトリのルートディレクトリから実行:

```bash
docker build -t mm-sh365fes:latest .
```

### 3. コンテナの起動

```bash
docker run -d \
  --name mm-sh365fes \
  -p 8065:8065 \
  mm-sh365fes:latest
```

### 4. 環境へのアクセス

ログで `INITIAL SETUP FINISHED` が表示されたらブラウザからアクセスしてください。

```bash
docker logs -f mm-sh365fes
```

- URL: http://localhost:8065
- ユーザー名: admin01
- パスワード: SH365Fes

## メンテナンス

### コンテナの停止・削除

```bash
docker rm -vf mm-sh365fes
```

### イメージ削除

```bash
docker rmi mm-sh365fes:latest
```
