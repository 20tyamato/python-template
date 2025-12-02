#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------
# Logging helpers
# ----------------------------------------
ok()   { echo -e "\033[32m✅ $1\033[0m"; }
err()  { echo -e "\033[31m❌ $1\033[0m"; }
warn() { echo -e "\033[33m⚠️  $1\033[0m"; }

# ----------------------------------------
# Preconditions
# ----------------------------------------
# TODO: Check if macOS
# TODO: Check for brew
# TODO: Prompt to install git and uv if not present
# TODO: add direnv setup

if ! command -v git > /dev/null 2>&1; then
    err "git is not installed."
    exit 1
fi

if ! command -v uv > /dev/null 2>&1; then
    err "uv is not installed."
    exit 1
fi

if [[ -z "${GIT_PERSONAL_TOKEN:-}" ]]; then
    err "Environment variable GIT_PERSONAL_TOKEN is not set."
    exit 1
fi

# ----------------------------------------
# Variables
# ----------------------------------------
PROJECT_NAME=$(basename "$PWD")
GITHUB_URL="https://20tyamato:${GIT_PERSONAL_TOKEN}@github.com/20tyamato/${PROJECT_NAME}.git"

# ----------------------------------------
# Git initialization
# ----------------------------------------
rm -rf .git
git init > /dev/null
git add .  > /dev/null
git commit -m "Initial commit" > /dev/null
git branch -M main > /dev/null
git remote add origin "$GITHUB_URL"
git push -u origin main > /dev/null
ok "Initialized Git repository and pushed to remote"

# ----------------------------------------
# Python environment setup
# ----------------------------------------
uv sync > /dev/null
source .venv/bin/activate > /dev/null
ok "Set up Python virtual environment with uv"

# ----------------------------------------
# Directory creation
# ----------------------------------------
mkdir -p data
ok "Created data directory"

# ----------------------------------------
# pre-commit
# ----------------------------------------
if command -v pre-commit > /dev/null 2>&1; then
    pre-commit install > /dev/null
    ok "Set up pre-commit"
else
    warn "Skipped pre-commit setup (not installed)"
fi

# ----------------------------------------
# README.md update
# ----------------------------------------
cat << EOF > README.md
# ${PROJECT_NAME}

## Python バージョン
このプロジェクトは **Python 3.11 以上** を推奨します。
依存関係の管理には **uv** を利用しています。

## プロジェクト構成

${PROJECT_NAME}/
├── src/            # アプリケーションコード
├── tests/          # テストコード
├── pyproject.toml  # パッケージ設定
├── uv.lock         # 依存ロックファイル
└── README.md

## セットアップ
\`\`\`
uv sync
\`\`\`

## 実行方法
\`\`\`
uv run python src/main.py
\`\`\`

## テスト
\`\`\`
uv run pytest
\`\`\`
EOF

ok "Updated README.md"

# ----------------------------------------
# Remove self
# ----------------------------------------
SCRIPT_NAME=$(basename "$0")
rm -f "$SCRIPT_NAME"
ok "Deleted $SCRIPT_NAME"

ok "Setup complete!"
