#!/bin/bash
set -euo pipefail

# setup-crispy.sh: Initialize crispy configuration
# Usage: setup-crispy.sh <base_dir>
#
# Handles:
#   - Creating ~/.crispy directory
#   - Removing/backing up existing symlinks
#   - Validating artifact base directory exists
#   - Writing config.json with proper escaping
#   - Validation

if [[ $# -ne 1 ]]; then
  echo "Usage: setup-crispy.sh <base_dir>" >&2
  exit 1
fi

BASE_DIR="$1"
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

# Handle existing ~/.crispy
if [[ -L "$CRISPY_HOME" ]]; then
  # It's a symlink - remove it
  rm "$CRISPY_HOME"
elif [[ -d "$CRISPY_HOME" ]]; then
  # It's a directory - keep it, we'll just update the config
  :
fi

# Validate provided path exists
if [[ ! -d "$BASE_DIR" ]]; then
  echo "ERROR: Path does not exist: $BASE_DIR" >&2
  exit 1
fi

# Create ~/.crispy directory
mkdir -p "$CRISPY_HOME"

# Write config with proper JSON escaping
# Use printf with %q won't work for JSON, so we'll escape manually
write_json_config() {
  local base_dir="$1"
  # Escape backslashes first, then quotes
  local escaped="${base_dir//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  printf '{"base_dir":"%s"}\n' "$escaped"
}

write_json_config "$BASE_DIR" > "$CONFIG_FILE"

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
