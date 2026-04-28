#!/usr/bin/env bash
# resolve-basedir.sh — Returns the crispy base directory for the current context.
#
# Reads ~/.crispy/config.json and returns either:
#   <base_dir>/<repo-name>/   when folders.git=true and inside a git repo
#   <base_dir>/               when folders.git=false or outside any git repo
#
# Falls back to ~/.crispy/ if crispy has not been initialized.
#
# Usage:
#   BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh")
#   Feature folder: $BASE_DIR/<feature-name>/

CONFIG_FILE="$HOME/.crispy/config.json"

# Use git-common-dir to handle worktrees correctly (returns the shared git dir).
# Returns .git for normal repos, absolute path for worktrees, empty outside any repo.
GIT_COMMON=$(git rev-parse --git-common-dir 2>/dev/null)
if [ -n "$GIT_COMMON" ] && [ "$GIT_COMMON" != ".git" ]; then
  REPO_NAME=$(basename "$(dirname "$GIT_COMMON")" 2>/dev/null)
else
  REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
fi

BASE_DIR=""
FOLDERS_GIT="true"

if [ -f "$CONFIG_FILE" ]; then
  BASE_DIR=$(jq -r '.base_dir // empty' "$CONFIG_FILE" 2>/dev/null || true)
  # Cannot use // operator here: in jq, `false // true` evaluates to `true`
  FOLDERS_GIT=$(jq -r 'if .folders.git == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
fi

if [ -z "$BASE_DIR" ]; then
  BASE_DIR="$HOME/.crispy"
fi

BASE_DIR="${BASE_DIR%/}"

if [ "$FOLDERS_GIT" = "true" ] && [ -n "$REPO_NAME" ]; then
  printf '%s/%s\n' "$BASE_DIR" "$REPO_NAME"
else
  printf '%s\n' "$BASE_DIR"
fi
