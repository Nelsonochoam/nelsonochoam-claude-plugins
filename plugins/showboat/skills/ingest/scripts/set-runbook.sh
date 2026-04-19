#!/usr/bin/env bash
# set-runbook.sh — Writes the runbook path into ~/.showboat/config.json
# (preserving other fields) and ensures the references/ directory exists alongside it.
#
# Usage:
#   bash "${CLAUDE_SKILL_DIR}/scripts/set-runbook.sh" "<absolute-runbook-path>"
#
# Prints two key=value lines on success:
#   RUNBOOK=...
#   REFS_DIR=...

set -euo pipefail

RUNBOOK_PATH="${1:-}"

if [ -z "$RUNBOOK_PATH" ]; then
  echo "Usage: set-runbook.sh <absolute-runbook-path>" >&2
  exit 1
fi

# Expand ~
RUNBOOK_PATH="${RUNBOOK_PATH/#\~/$HOME}"

# Validate absolute
if [[ "$RUNBOOK_PATH" != /* ]]; then
  echo "ERROR: runbook must be an absolute path (got: $RUNBOOK_PATH)" >&2
  exit 1
fi

# Validate .md
if [[ "$RUNBOOK_PATH" != *.md ]]; then
  echo "ERROR: runbook must be a .md file (got: $RUNBOOK_PATH)" >&2
  exit 1
fi

CONFIG_FILE="$HOME/.showboat/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: Showboat is not configured. Run /showboat:init first." >&2
  exit 1
fi

# Merge runbook key into existing config
TMP_FILE=$(mktemp)
jq --arg runbook "$RUNBOOK_PATH" '. + {runbook: $runbook}' "$CONFIG_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$CONFIG_FILE"

if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
  echo "ERROR: Failed to write valid JSON to $CONFIG_FILE" >&2
  exit 1
fi

# Ensure runbook dir and references/ exist
RUNBOOK_DIR="$(dirname "$RUNBOOK_PATH")"
mkdir -p "$RUNBOOK_DIR"
REFS_DIR="$RUNBOOK_DIR/references"
mkdir -p "$REFS_DIR"

printf 'RUNBOOK=%s\n' "$RUNBOOK_PATH"
printf 'REFS_DIR=%s\n' "$REFS_DIR"
