#!/usr/bin/env bash
# resolve-runbook.sh — Returns the configured runbook path.
#
# Reads ~/.showboat/config.json and returns the runbook path if configured.
# Prints nothing and exits 1 if no runbook is configured.
#
# Usage:
#   RUNBOOK=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-runbook.sh") || true

CONFIG_FILE="$HOME/.showboat/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  exit 1
fi

RUNBOOK=$(jq -r '.runbook // empty' "$CONFIG_FILE" 2>/dev/null || true)

if [ -z "$RUNBOOK" ]; then
  exit 1
fi

# Verify the file exists
if [ ! -f "$RUNBOOK" ]; then
  echo "WARNING: runbook configured but file not found: $RUNBOOK" >&2
  printf '%s\n' "$RUNBOOK"
  exit 0
fi

printf '%s\n' "$RUNBOOK"
