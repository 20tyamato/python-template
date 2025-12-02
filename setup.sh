#!/usr/bin/env bash
set -e

rm -rf .git
git init > /dev/null 2>&1
git add . > /dev/null 2>&1
git commit -m "Initial commit" > /dev/null 2>&1
git branch -M main > /dev/null 2>&1
git remote add origin "https://$GIT_PERSONAL_TOKEN@github.com/20tyamato/new-project.git"
git push -u origin main
echo -e "\033[32m✅ Initialized new Git repository and pushed to remote.\033[0m"

uv init
uv venv -p 3.12
# uv sync
source .venv/bin/activate
echo -e "\033[32m✅ Set up Python virtual environment using uv.\033[0m"

echo -e "\033[32m✅ Installed project dependencies.\033[0m"

mkdir -p data

pre-commit install

SCRIPT_NAME=$(basename "$0")
rm -f "$SCRIPT_NAME"
echo -e "\033[32m✅ Setup completed and $SCRIPT_NAME removed.\033[0m"
