#!/usr/bin/env bash
# resolve-knowledge-index.sh — Returns the configured knowledge index path.
#
# Reads ~/.showboat/config.json and returns the knowledge_index path if configured.
# Prints nothing and exits 1 if no knowledge index is configured.
#
# Usage:
#   KNOWLEDGE_INDEX=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-knowledge-index.sh") || true

CONFIG_FILE="$HOME/.showboat/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
  exit 1
fi

KNOWLEDGE_INDEX=$(jq -r '.knowledge_index // empty' "$CONFIG_FILE" 2>/dev/null || true)

if [ -z "$KNOWLEDGE_INDEX" ]; then
  exit 1
fi

# Verify the file exists
if [ ! -f "$KNOWLEDGE_INDEX" ]; then
  echo "WARNING: knowledge_index configured but file not found: $KNOWLEDGE_INDEX" >&2
  # Still print the path — the skill can decide what to do
  printf '%s\n' "$KNOWLEDGE_INDEX"
  exit 0
fi

printf '%s\n' "$KNOWLEDGE_INDEX"
