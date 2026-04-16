#!/usr/bin/env bash
# resolve-playbook.sh — Returns the configured playbook path.
#
# Reads ~/.showboat/config.json and returns the playbook path if configured.
# Prints nothing and exits 1 if no playbook is configured.
#
# Usage:
#   PLAYBOOK=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-playbook.sh") || true

CONFIG_FILE="$HOME/.showboat/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  exit 1
fi

PLAYBOOK=$(jq -r '.playbook // empty' "$CONFIG_FILE" 2>/dev/null || true)

if [ -z "$PLAYBOOK" ]; then
  exit 1
fi

# Verify the file exists
if [ ! -f "$PLAYBOOK" ]; then
  echo "WARNING: playbook configured but file not found: $PLAYBOOK" >&2
  printf '%s\n' "$PLAYBOOK"
  exit 0
fi

printf '%s\n' "$PLAYBOOK"
