#!/usr/bin/env bash
# resolve-basedir.sh — Returns the wiki vault base directory.
#
# Supports multiple named wikis. Reads ~/.wiki/config.json and returns
# the path for the requested wiki (or the default wiki).
#
# Usage:
#   BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh")              # default wiki
#   BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh" "testing")    # named wiki
#
# Config format (single wiki — backward compatible):
#   { "base_dir": "/path/to/vault" }
#
# Config format (multiple wikis):
#   { "wikis": { "personal": "/path/to/personal", "testing": "/path/to/testing" }, "default": "personal" }

CONFIG_FILE="$HOME/.wiki/config.json"
WIKI_NAME="${1:-}"

BASE_DIR=""

if [ -f "$CONFIG_FILE" ]; then
  # Check if config uses the multi-wiki format
  HAS_WIKIS=$(jq -r '.wikis // empty' "$CONFIG_FILE" 2>/dev/null || true)

  if [ -n "$HAS_WIKIS" ]; then
    # Multi-wiki format
    if [ -n "$WIKI_NAME" ]; then
      BASE_DIR=$(jq -r ".wikis[\"$WIKI_NAME\"] // empty" "$CONFIG_FILE" 2>/dev/null || true)
      if [ -z "$BASE_DIR" ]; then
        echo "Error: wiki '$WIKI_NAME' not found in config. Available wikis:" >&2
        jq -r '.wikis | keys[]' "$CONFIG_FILE" 2>/dev/null >&2
        exit 1
      fi
    else
      # Use the default wiki
      DEFAULT=$(jq -r '.default // empty' "$CONFIG_FILE" 2>/dev/null || true)
      if [ -n "$DEFAULT" ]; then
        BASE_DIR=$(jq -r ".wikis[\"$DEFAULT\"] // empty" "$CONFIG_FILE" 2>/dev/null || true)
      fi
      # If no default set, use the first wiki
      if [ -z "$BASE_DIR" ]; then
        BASE_DIR=$(jq -r '.wikis | to_entries[0].value // empty' "$CONFIG_FILE" 2>/dev/null || true)
      fi
    fi
  else
    # Single wiki format (backward compatible)
    BASE_DIR=$(jq -r '.base_dir // empty' "$CONFIG_FILE" 2>/dev/null || true)
  fi
fi

if [ -z "$BASE_DIR" ]; then
  BASE_DIR="$HOME/.wiki"
fi

# Strip trailing slash for consistency
BASE_DIR="${BASE_DIR%/}"

printf '%s\n' "$BASE_DIR"
