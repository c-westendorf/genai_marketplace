#!/bin/bash
# agile-companion changelog publisher
# Appends the approved 3P entry to the annual file and optionally
# commits it to the team's shared repository.
#
# Usage:
#   bash publish-changelog.sh --local           # local save only
#   bash publish-changelog.sh --repo [repo_dir] # local + commit to repo
#   bash publish-changelog.sh --repo [repo_dir] --pr  # open a PR instead of direct commit

set -e

# ── Config ───────────────────────────────────────────────────────────
USERNAME="${AGILE_COMPANION_USER:-$(git config user.name 2>/dev/null | tr ' ' '_' | tr '[:upper:]' '[:lower:]')}"
YEAR=$(date +"%Y")
WEEK=$(date +"%Y-W%V")
LOCAL_DIR="$HOME/agile-companion/changelogs/$USERNAME"
ANNUAL_FILE="$LOCAL_DIR/${YEAR}_${USERNAME}_3p.md"
DRAFT_DIR="$LOCAL_DIR/drafts"
DRAFT_FILE="$DRAFT_DIR/${WEEK}_draft.md"

MODE="local"
REPO_DIR=""
OPEN_PR=false

# ── Argument parsing ──────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --local) MODE="local"; shift ;;
    --repo) MODE="repo"; REPO_DIR="$2"; shift 2 ;;
    --pr) OPEN_PR=true; shift ;;
    --user) USERNAME="$2"; shift 2 ;;
    --draft) DRAFT_FILE="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

# ── Validate ──────────────────────────────────────────────────────────
if [ ! -f "$DRAFT_FILE" ]; then
  echo "Error: No draft found at $DRAFT_FILE"
  echo "The companion should have written the draft before calling this script."
  exit 1
fi

# ── Ensure local directory exists ────────────────────────────────────
mkdir -p "$LOCAL_DIR" "$DRAFT_DIR"

# ── Initialize annual file if new ────────────────────────────────────
if [ ! -f "$ANNUAL_FILE" ]; then
  cat > "$ANNUAL_FILE" << HEADER
# $USERNAME — Agile Companion 3P Log

*Started: $(date +"%Y-%m-%d")*

---

HEADER
  echo "Created new annual log: $ANNUAL_FILE"
fi

# ── Append draft to annual file ──────────────────────────────────────
cat "$DRAFT_FILE" >> "$ANNUAL_FILE"
echo "" >> "$ANNUAL_FILE"
echo "---" >> "$ANNUAL_FILE"
echo "" >> "$ANNUAL_FILE"

WEEK_COUNT=$(grep -c "## Week of" "$ANNUAL_FILE" 2>/dev/null || echo 0)

echo "✓ Saved to $ANNUAL_FILE"
echo "  $WEEK_COUNT week(s) logged this year."

# ── Delete draft ─────────────────────────────────────────────────────
rm "$DRAFT_FILE"
echo "✓ Draft cleared."

# ── Repo publish ─────────────────────────────────────────────────────
if [ "$MODE" = "repo" ]; then
  if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/.git" ]; then
    echo "Error: $REPO_DIR is not a git repository."
    exit 1
  fi

  REPO_CHANGELOG_DIR="$REPO_DIR/changelogs/$USERNAME"
  REPO_ANNUAL_FILE="$REPO_CHANGELOG_DIR/${YEAR}_${USERNAME}_3p.md"

  mkdir -p "$REPO_CHANGELOG_DIR"

  # Copy the local annual file to repo
  cp "$ANNUAL_FILE" "$REPO_ANNUAL_FILE"

  cd "$REPO_DIR"

  BRANCH="changelogs/$USERNAME"
  COMMIT_MSG="3p: week of $WEEK — $USERNAME"

  if $OPEN_PR; then
    # Create a branch for a PR
    git checkout -b "$BRANCH-$WEEK" 2>/dev/null || git checkout "$BRANCH-$WEEK"
    git add "changelogs/$USERNAME/"
    git commit -m "$COMMIT_MSG"
    git push origin "$BRANCH-$WEEK"
    echo "✓ Pushed to branch $BRANCH-$WEEK"
    echo "  Open a PR from that branch to publish to the team."

    # If gh CLI is available, open PR automatically
    if command -v gh &> /dev/null; then
      gh pr create \
        --title "$COMMIT_MSG" \
        --body "Weekly 3P changelog entry for $USERNAME — $WEEK." \
        --base main \
        --head "$BRANCH-$WEEK"
      echo "✓ PR opened via GitHub CLI."
    fi
  else
    # Direct commit to changelogs branch or main
    git add "changelogs/$USERNAME/"
    git commit -m "$COMMIT_MSG"
    git push origin HEAD
    echo "✓ Committed and pushed: $COMMIT_MSG"
  fi
fi

echo ""
echo "Your 3P is saved. Reference it at:"
echo "  $ANNUAL_FILE"
