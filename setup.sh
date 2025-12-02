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
# Prerequisite Checks
# ----------------------------------------
REPO_CHECK_URL="https://api.github.com/repos/20tyamato/${PROJECT_NAME}"

GITHUB_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token ${GIT_PERSONAL_TOKEN}" \
    "$REPO_CHECK_URL")

if [[ "$GITHUB_STATUS" == "200" ]]; then
    ok "GitHub repository exists: 20tyamato/${PROJECT_NAME}"
elif [[ "$GITHUB_STATUS" == "404" ]]; then
    err "GitHub repository does NOT exist: 20tyamato/${PROJECT_NAME}"
    echo "Create it first:"
    echo "👉 https://github.com/new"
    exit 1
else
    err "Unexpected response from GitHub API (HTTP $GITHUB_STATUS)"
    exit 1
fi

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

## Python Version
This project recommends **Python 3.11 or higher**.
Dependency management uses **uv**.

## Project Structure

${PROJECT_NAME}/
├── src/            # Application code
├── tests/          # Test code
├── config/         # Configuration files
├── .gitignore      # Git ignore rules
├── pyproject.toml  # Package configuration
├── uv.lock         # Dependency lock file
└── README.md

## Setup
\`\`\`
uv sync
\`\`\`

## How to Run
\`\`\`
uv run python src/main.py
\`\`\`

## Testing
\`\`\`
uv run pytest
\`\`\`

## Version Control

This project uses Git for version control.
The remote repository is hosted on GitHub.

## Virtual Environment Management

This project uses **uv** to manage virtual environments.

- Using [uv](https://uv.dev/)
    - [Useful guide](https://speakerdeck.com/mickey_kubo/pythonpatukeziguan-li-uv-wan-quan-ru-men)
    - Useful commands:
        - `source .venv/bin/activate` to activate the virtual environment
        - `deactivate` to deactivate the virtual environment
        - `uv add package_name` to add a package
        - `uv pip check` to check dependency consistency
        - `uv remove package_name` to remove a package
        - `uv sync` to synchronize dependencies
        - `uv tool list` to display available tools
        - `uv tool install tool_name` to install a tool

## Linter / Formatter
- Using [ruff](https://github.com/astral-sh/ruff)

EOF

git commit -m "Update README.md" > /dev/null
git push -u origin main > /dev/null
ok "Updated README.md"

# ----------------------------------------
# Remove self
# ----------------------------------------
SCRIPT_NAME=$(basename "$0")
rm -f "$SCRIPT_NAME"
ok "Deleted $SCRIPT_NAME"

ok "Setup complete!"
