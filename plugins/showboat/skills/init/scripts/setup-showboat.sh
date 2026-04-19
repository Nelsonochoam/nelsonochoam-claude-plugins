#!/usr/bin/env bash
# setup-showboat.sh — Creates showboat configuration.
#
# Usage:
#   bash setup-showboat.sh "<base_dir>" ["<runbook>"]
#
# Creates:
#   ~/.showboat/config.json
#   <base_dir>/ directory

set -euo pipefail

BASE_DIR="$1"
RUNBOOK="${2:-}"

if [ -z "$BASE_DIR" ]; then
  echo "Usage: setup-showboat.sh <base_dir> [<runbook>]" >&2
  exit 1
fi

# Expand ~ if present
BASE_DIR="${BASE_DIR/#\~/$HOME}"
[ -n "$RUNBOOK" ] && RUNBOOK="${RUNBOOK/#\~/$HOME}"

# Ensure base_dir is absolute
if [[ "$BASE_DIR" != /* ]]; then
  echo "Error: base_dir must be an absolute path (got: $BASE_DIR)" >&2
  exit 1
fi

# Validate runbook if provided
if [ -n "$RUNBOOK" ] && [[ "$RUNBOOK" != /* ]]; then
  echo "Error: runbook must be an absolute path (got: $RUNBOOK)" >&2
  exit 1
fi

# Strip trailing slash
BASE_DIR="${BASE_DIR%/}"

# Create config directory
CONFIG_DIR="$HOME/.showboat"
if [ -L "$CONFIG_DIR" ]; then
  CONFIG_DIR=$(readlink -f "$CONFIG_DIR")
elif [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
fi

# Create the base directory
mkdir -p "$BASE_DIR"

# Build config JSON
CONFIG_FILE="$HOME/.showboat/config.json"
CONFIG_JSON=$(jq -n \
  --arg base_dir "$BASE_DIR" \
  --arg runbook "$RUNBOOK" \
  '{
    base_dir: $base_dir
  }
  + (if $runbook != "" then {runbook: $runbook} else {} end)
')
printf '%s\n' "$CONFIG_JSON" > "$CONFIG_FILE"

# Validate JSON
if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
  echo "Error: Failed to write valid JSON to $CONFIG_FILE" >&2
  exit 1
fi

echo "OK"
