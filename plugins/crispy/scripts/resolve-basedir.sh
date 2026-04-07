#!/usr/bin/env bash
# get-config.sh — Returns the crispy output base directory for the current repo.
#
# Reads ~/.crispy/config.json and returns:
#   <base_dir>/<repo-name>/
#
# Falls back to ~/.crispy/<repo-name>/ if crispy-init has not been run.
#
# Usage:
#   BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/get-config.sh")
#   Feature folder: $BASE_DIR/<feature-name>/

CONFIG_FILE="$HOME/.crispy/config.json"
# Use git-common-dir to get the main repo root (handles worktrees correctly)
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
if [ -n "$GIT_COMMON" ] && [ "$GIT_COMMON" != ".git" ]; then
  REPO_NAME=$(basename "$(dirname "$GIT_COMMON")" 2>/dev/null || echo "default")
else
  REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "default")
fi

BASE_DIR=""

if [ -f "$CONFIG_FILE" ]; then
  BASE_DIR=$(jq -r '.base_dir // empty' "$CONFIG_FILE" 2>/dev/null || true)
fi

if [ -z "$BASE_DIR" ]; then
  BASE_DIR="$HOME/.crispy"
fi

# Strip trailing slash for consistency
BASE_DIR="${BASE_DIR%/}"

printf '%s/%s\n' "$BASE_DIR" "$REPO_NAME"
