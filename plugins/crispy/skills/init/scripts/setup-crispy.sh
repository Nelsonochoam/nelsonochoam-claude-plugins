#!/bin/bash
set -euo pipefail

# setup-crispy.sh: Initialize crispy configuration
# Usage: setup-crispy.sh <base_dir> [folders_git]
#
# Handles:
#   - Creating ~/.crispy directory
#   - Removing/backing up existing symlinks
#   - Creating artifact base directory if it doesn't exist
#   - Writing config.json with proper escaping
#   - Validation

if [[ $# -lt 1 ]]; then
  echo "Usage: setup-crispy.sh <base_dir> [folders_git]" >&2
  exit 1
fi

BASE_DIR="$1"
FOLDERS_GIT="${2:-true}"
CRISPY_HOME="$HOME/.crispy"
CONFIG_FILE="$CRISPY_HOME/config.json"

# Expand ~ if present in BASE_DIR
if [[ "$BASE_DIR" == ~* ]]; then
  BASE_DIR="${BASE_DIR/#\~/$HOME}"
fi

# Require absolute path
if [[ ! "$BASE_DIR" = /* ]]; then
  echo "ERROR: base_dir must be an absolute path, got: $BASE_DIR" >&2
  exit 1
fi

# Remove trailing slashes
BASE_DIR="${BASE_DIR%/}"

# Normalize folders_git to true/false
if [[ "$FOLDERS_GIT" == "true" || "$FOLDERS_GIT" == "1" || "$FOLDERS_GIT" == "yes" ]]; then
  FOLDERS_GIT="true"
else
  FOLDERS_GIT="false"
fi

# Handle existing ~/.crispy
if [[ -L "$CRISPY_HOME" ]]; then
  # It's a symlink - remove it
  rm "$CRISPY_HOME"
elif [[ -d "$CRISPY_HOME" ]]; then
  # It's a directory - keep it, we'll just update the config
  :
fi

# Create base dir if it doesn't exist
mkdir -p "$BASE_DIR"

# Create ~/.crispy directory
mkdir -p "$CRISPY_HOME"

# Write config with proper JSON escaping
write_json_config() {
  local base_dir="$1"
  local folders_git="$2"
  # Escape backslashes first, then quotes
  local escaped="${base_dir//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  printf '{"base_dir":"%s","folders":{"git":%s}}\n' "$escaped" "$folders_git"
}

write_json_config "$BASE_DIR" "$FOLDERS_GIT" > "$CONFIG_FILE"

# Validate JSON
if ! jq . "$CONFIG_FILE" > /dev/null 2>&1; then
  echo "ERROR: Invalid JSON written to config file" >&2
  rm "$CONFIG_FILE"
  exit 1
fi

# Validate directories exist
if [[ ! -d "$CRISPY_HOME" ]]; then
  echo "ERROR: Failed to create ~/.crispy directory" >&2
  exit 1
fi

if [[ ! -d "$BASE_DIR" ]]; then
  echo "ERROR: Base directory not found: $BASE_DIR" >&2
  exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Failed to create config file" >&2
  exit 1
fi

# Success - output the configuration
cat "$CONFIG_FILE"
exit 0
