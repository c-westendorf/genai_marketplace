#!/bin/bash
# agile-companion git hook setup
# Installs a post-commit hook that logs commits to ~/.agile-companion/today-commits.log
# The agile-companion skill reads this file at EOD to surface your commits automatically.
#
# Usage: bash git-hook-setup.sh
# Run once per repo, or use --global to apply to all repos.

set -e

GLOBAL=false
if [[ "$1" == "--global" ]]; then
  GLOBAL=true
fi

LOG_DIR="$HOME/.agile-companion"
LOG_FILE="$LOG_DIR/today-commits.log"

mkdir -p "$LOG_DIR"

HOOK_CONTENT='#!/bin/bash
# agile-companion post-commit hook
LOG_DIR="$HOME/.agile-companion"
LOG_FILE="$LOG_DIR/today-commits.log"
mkdir -p "$LOG_DIR"

REPO=$(basename "$(git rev-parse --show-toplevel)")
HASH=$(git rev-parse --short HEAD)
MSG=$(git log -1 --pretty=format:"%s")
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M")

echo "$DATE $TIME | $REPO | $HASH | $MSG" >> "$LOG_FILE"
'

if $GLOBAL; then
  # Set up global git hooks directory
  HOOKS_DIR="$HOME/.git-hooks"
  mkdir -p "$HOOKS_DIR"
  echo "$HOOK_CONTENT" > "$HOOKS_DIR/post-commit"
  chmod +x "$HOOKS_DIR/post-commit"
  git config --global core.hooksPath "$HOOKS_DIR"
  echo "✓ Global git hook installed. All repos will now log commits to $LOG_FILE"
else
  # Install in current repo
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: not inside a git repository. Run from your project directory."
    exit 1
  fi
  HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
  echo "$HOOK_CONTENT" > "$HOOKS_DIR/post-commit"
  chmod +x "$HOOKS_DIR/post-commit"
  echo "✓ Hook installed in current repo. Commits will log to $LOG_FILE"
  echo "  Tip: run with --global to apply to all your repos."
fi

echo ""
echo "Today's commit log will appear at: $LOG_FILE"
echo "Your agile companion will read it automatically at end-of-day."
