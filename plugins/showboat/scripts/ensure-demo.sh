#!/usr/bin/env bash
# ensure-demo.sh — Creates and returns the demo directory for the active feature.
#
# Feature resolution priority:
#   1. FEATURE env var
#   2. /tmp/.showboat_feature_${PPID} session file
#   3. $1 argument
#   4. No feature — returns BASE_DIR directly (backward compatible)
#
# Usage:
#   DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "<feature-name>")
#
# Creates:
#   <BASE_DIR>/<feature>/demo/
#
# Prints: <BASE_DIR>/<feature>/demo  (or <BASE_DIR> if no feature)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR=$(bash "$SCRIPT_DIR/resolve-basedir.sh")

# Resolve feature — env var > session file > argument
RESOLVED_FEATURE="${FEATURE:-}"

if [ -z "$RESOLVED_FEATURE" ]; then
  SESSION_FILE="/tmp/.showboat_feature_${PPID}"
  if [ -f "$SESSION_FILE" ]; then
    RESOLVED_FEATURE=$(cat "$SESSION_FILE")
  fi
fi

if [ -z "$RESOLVED_FEATURE" ] && [ -n "$1" ]; then
  RESOLVED_FEATURE="$1"
fi

# Persist to session file so subsequent skills don't need to re-resolve
if [ -n "$RESOLVED_FEATURE" ]; then
  echo "$RESOLVED_FEATURE" > "/tmp/.showboat_feature_${PPID}"
  DEMO_BASE="$BASE_DIR/$RESOLVED_FEATURE/demo"
else
  DEMO_BASE="$BASE_DIR"
fi

# Create directory — demo docs and introspection.md live directly here
mkdir -p "$DEMO_BASE"

printf '%s\n' "$DEMO_BASE"
