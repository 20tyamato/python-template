#!/usr/bin/env bash
set -euo pipefail

# ----------------------------------------
# Logging helpers
# ----------------------------------------
ok()   { echo -e "\033[32m✅ $1\033[0m"; }
err()  { echo -e "\033[31m❌ $1\033[0m"; }
warn() { echo -e "\033[33m⚠️  $1\033[0m"; }

# ----------------------------------------
# PC Information（macOS / CPU / GPU / Memory）
# ----------------------------------------
OS_NAME=$(uname -s 2>/dev/null || echo "unknown")

if [[ "$OS_NAME" != "Darwin" ]]; then
    err "This script currently supports only macOS (Darwin). Detected: ${OS_NAME}"
    exit 1
fi

MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
CPU_BRAND=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "unknown CPU")
MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
MEM_GB=$(( MEM_BYTES / 1024 / 1024 / 1024 ))

# CPU コア数（物理 & 論理）
CPU_PHYSICAL=$(sysctl -n hw.physicalcpu)
CPU_LOGICAL=$(sysctl -n hw.logicalcpu)

# GPU コア数（Apple Silicon のみ）
GPU_CORES=$(system_profiler SPDisplaysDataType | awk -F': ' '/Total Number of Cores/ {print $2; exit}')
if [[ -z "${GPU_CORES:-}" ]]; then
    GPU_CORES="N/A"
fi

ok "OS: macOS ${MACOS_VERSION}"
ok "CPU: ${CPU_BRAND} (physical cores: ${CPU_PHYSICAL}, logical cores: ${CPU_LOGICAL})"
ok "Memory: ${MEM_GB} GB"
ok "GPU cores: ${GPU_CORES}"


# ----------------------------------------
# Preconditions
# ----------------------------------------

# Homebrew チェック
if ! command -v brew > /dev/null 2>&1; then
    warn "Homebrew is not installed. Install from https://brew.sh/ ."
    HAS_BREW=false
else
    HAS_BREW=true
fi

# git チェック & インストール提案
if ! command -v git > /dev/null 2>&1; then
    err "git is not installed."
    if [[ "${HAS_BREW}" == true ]]; then
        read -r -p "Install git via Homebrew? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            brew install git
        else
            err "git is required. Aborting."
            exit 1
        fi
    else
        err "Please install git manually."
        exit 1
    fi
fi

# uv チェック & インストール提案
if ! command -v uv > /dev/null 2>&1; then
    err "uv is not installed."
    if [[ "${HAS_BREW}" == true ]]; then
        read -r -p "Install uv via Homebrew? [y/N]: " ans
        if [[ "$ans" =~ ^[Yy]$ ]]; then
            brew install uv
        else
            err "uv is required. Aborting."
            exit 1
        fi
    else
        err "Install uv manually: https://github.com/astral-sh/uv"
        exit 1
    fi
fi

# GIT_PERSONAL_TOKEN チェック
if [[ -z "${GIT_PERSONAL_TOKEN:-}" ]]; then
    err "Environment variable GIT_PERSONAL_TOKEN is not set."
    exit 1
fi

# direnv セットアップ
if command -v direnv > /dev/null 2>&1; then
    if [[ ! -f .envrc ]]; then
        cat << EOF > .envrc
# Automatically activate uv virtualenv
if [ -d ".venv" ]; then
  source .venv/bin/activate
fi

# Add project root to PYTHONPATH
export PYTHONPATH=$(pwd)
EOF

        if direnv allow . > /dev/null 2>&1; then
            ok "Configured direnv (.envrc created and allowed)"
        else
            warn "direnv allow . failed. Run 'direnv allow .' manually."
        fi
    else
        ok ".envrc already exists. Skipping creation."
    fi
else
    warn "direnv not installed. Install with 'brew install direnv'."
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
    warn "pre-commit not installed. Skipped setup."
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
