#!/bin/bash
# agile-companion team setup
# Interactive first-time configuration. Writes to .agile-companion/team-config.yml
# Commit the result to your team repo.
#
# Usage: bash scripts/team-setup.sh

set -e

CONFIG_DIR=".agile-companion"
CONFIG_FILE="$CONFIG_DIR/team-config.yml"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  agile-companion — team setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -f "$CONFIG_FILE" ]; then
  echo "Config already exists at $CONFIG_FILE"
  read -p "Overwrite it? (y/N): " overwrite
  [[ "$overwrite" =~ ^[Yy]$ ]] || exit 0
fi

mkdir -p "$CONFIG_DIR"

echo "Answer a few questions. Press Enter to accept defaults."
echo ""

# Team identity
read -p "Team name [Data Science Team]: " TEAM_NAME
TEAM_NAME="${TEAM_NAME:-Data Science Team}"

read -p "Team repo (git remote URL): " TEAM_REPO

read -p "Team members (comma-separated usernames, or leave blank): " MEMBERS_RAW
MEMBERS_YML=""
if [ -n "$MEMBERS_RAW" ]; then
  IFS=',' read -ra MEMBERS <<< "$MEMBERS_RAW"
  for m in "${MEMBERS[@]}"; do
    m=$(echo "$m" | xargs)  # trim whitespace
    MEMBERS_YML+="  - $m"$'\n'
  done
fi

# Confluence
echo ""
echo "── Confluence ───────────────────────────────────────"
read -p "Confluence space key [DS]: " SPACE_KEY
SPACE_KEY="${SPACE_KEY:-DS}"

read -p "Confluence database ID (from your team's database URL): " DB_ID

read -p "Team page ID (the digest page, from the page URL): " TEAM_PAGE_ID

read -p "Personal pages parent ID (where individual pages live): " PERSONAL_PARENT_ID

# Jira
echo ""
echo "── Jira ─────────────────────────────────────────────"
read -p "Default Jira project key [DS]: " JIRA_KEY
JIRA_KEY="${JIRA_KEY:-DS}"

read -p "Atlassian MCP endpoint [https://atl.mcp.claude.com/mcp]: " MCP_ENDPOINT
MCP_ENDPOINT="${MCP_ENDPOINT:-https://atl.mcp.claude.com/mcp}"

# Team type — sets IDE signal defaults
echo ""
echo "── Team type (sets IDE signal defaults) ────────────"
echo "  1. Data science (notebooks, model training)"
echo "  2. Backend engineering (tests, builds)"
echo "  3. Frontend engineering (builds, file saves)"
echo "  4. Mixed / custom (configure manually)"
read -p "Team type [1]: " TEAM_TYPE
TEAM_TYPE="${TEAM_TYPE:-1}"

case $TEAM_TYPE in
  1)
    NB_ENABLED="true"; ML_ENABLED="true"; BUILD_ENABLED="false"
    TEAM_TYPE_LABEL="data_science"
    ;;
  2)
    NB_ENABLED="false"; ML_ENABLED="false"; BUILD_ENABLED="true"
    TEAM_TYPE_LABEL="backend"
    ;;
  3)
    NB_ENABLED="false"; ML_ENABLED="false"; BUILD_ENABLED="true"
    TEAM_TYPE_LABEL="frontend"
    ;;
  *)
    NB_ENABLED="false"; ML_ENABLED="false"; BUILD_ENABLED="false"
    TEAM_TYPE_LABEL="custom"
    ;;
esac

# Write config
cat > "$CONFIG_FILE" << YAML
# agile-companion team configuration
# Generated: $(date +"%Y-%m-%d") by $(git config user.name 2>/dev/null || echo "setup")
# Commit this file to your team repo. Every skill instance reads it on startup.

team:
  name: "$TEAM_NAME"
  type: "$TEAM_TYPE_LABEL"
  repo: "$TEAM_REPO"
  changelog_dir: "changelogs"
  members:
$MEMBERS_YML
confluence:
  space_key: "$SPACE_KEY"
  database_id: "$DB_ID"
  database_name: "Team 3P Log"
  team_page_id: "$TEAM_PAGE_ID"
  team_page_title: "$TEAM_NAME — Weekly Digest"
  personal_pages: true
  personal_page_parent_id: "$PERSONAL_PARENT_ID"
  sync:
    auto_offer_on_comms_approval: true
    manual_anytime: true
    require_approval_before_sync: true

jira:
  default_project_key: "$JIRA_KEY"
  mcp_endpoint: "$MCP_ENDPOINT"
  fallback_mode: "clipboard"

ide_signals:
  commits:
    enabled: true
    weight: high
  file_saves:
    enabled: true
    weight: low
    min_session_minutes: 10
  test_runs:
    enabled: true
    weight: medium
    capture_pass_fail: true
  builds:
    enabled: $BUILD_ENABLED
    weight: low
  notebook_runs:
    enabled: $NB_ENABLED
    weight: high
    capture_cell_count: true
  model_training:
    enabled: $ML_ENABLED
    weight: high
    capture_duration: true
  time_in_file:
    enabled: true
    weight: low
    deep_work_threshold_minutes: 25

wins:
  adaptive: true
  heavy_meeting_day_count: 1
  normal_day_count: 2

comms:
  available: always
  week_close_checks_if_filed: true
  short_week_days_question: true

friction:
  quick_standup_available: true
  silent_eod_generation: true
  trust_calibration_sessions: 10
  pre_read_pullback: true
  wins_file: "~/.agile-companion/today-wins.json"
  activity_log: "~/.agile-companion/today-activity.log"
  commit_log: "~/.agile-companion/today-commits.log"
YAML

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Config written to $CONFIG_FILE"
echo ""
echo "Next steps:"
echo "  1. Review $CONFIG_FILE and adjust any settings"
echo "  2. git add $CONFIG_FILE && git commit -m 'chore: add agile-companion team config'"
echo "  3. git push — team members get the config on next pull"
echo ""
echo "Each team member runs their local setup:"
echo "  bash scripts/git-hook-setup.sh --global"
echo "  python3 scripts/ide-activity-watcher.py --watch ~/[their-project-dir] &"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
