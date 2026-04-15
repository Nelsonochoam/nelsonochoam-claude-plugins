#!/usr/bin/env bash
# resolve-basedir.sh — Returns the showboat output base directory for the current repo.
#
# Reads ~/.showboat/config.json and returns:
#   <base_dir>/<repo-name>/
#
# Falls back to ~/.showboat/<repo-name>/ if showboat:init has not been run.
#
# Usage:
#   BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh")

CONFIG_FILE="$HOME/.showboat/config.json"
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
  BASE_DIR="$HOME/.showboat"
fi

# Strip trailing slash for consistency
BASE_DIR="${BASE_DIR%/}"

printf '%s/%s\n' "$BASE_DIR" "$REPO_NAME"
