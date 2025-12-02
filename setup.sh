#!/usr/bin/env bash
set -e

PROJECT_NAME=$(basename "$PWD")
if [ -z "$GIT_PERSONAL_TOKEN" ]; then
  echo -e "\033[31m❌ GIT_PERSONAL_TOKEN is not set. Please set it and rerun the script.\033[0m"
  exit 1
fi

rm -rf .git
git init > /dev/null 2>&1
git add . > /dev/null 2>&1
git commit -m "Initial commit" > /dev/null 2>&1
git branch -M main > /dev/null 2>&1
git remote add origin "https://$GIT_PERSONAL_TOKEN@github.com/20tyamato/$PROJECT_NAME.git"
git push -u origin main > /dev/null 2>&1
echo -e "\033[32m✅ Initialized new Git repository and pushed to remote.\033[0m"

uv sync > /dev/null 2>&1
source .venv/bin/activate > /dev/null 2>&1
echo -e "\033[32m✅ Set up Python virtual environment using uv.\033[0m"

mkdir data > /dev/null 2>&1
pre-commit install > /dev/null 2>&1

# README.mdの編集
rm -f README.md
cat << 'EOF' > README.md
# $PROJECT_NAME

## Python バージョン
このプロジェクトは **Python 3.11 以上** を推奨します。
依存関係の管理には **uv** を利用しています。

## プロジェクト構成

$PROJECT_NAME/
├── src/            # アプリケーションコード
├── tests/          # テストコード
├── pyproject.toml  # パッケージ設定
├── uv.lock         # 依存ロックファイル
└── README.md

## セットアップ
uv sync

## 実行方法
uv run python src/main.py

## テスト
uv run pytest
EOF
echo -e "\033[32m✅ Updated README.md with project information.\033[0m"

SCRIPT_NAME=$(basename "$0")
rm -f "$SCRIPT_NAME"
echo -e "\033[32m✅ Setup completed and $SCRIPT_NAME removed.\033[0m"
