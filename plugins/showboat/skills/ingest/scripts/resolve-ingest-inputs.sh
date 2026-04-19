#!/usr/bin/env bash
# resolve-ingest-inputs.sh — Resolves and validates the inputs for the ingest skill.
#
# Resolves:
#   1. INTROSPECTION_FILE — from $1 if given and exists, else $DEMO_BASE/introspection.md
#   2. RUNBOOK — from ~/.showboat/config.json via resolve-runbook.sh (may be unset)
#   3. REFS_DIR — <dirname RUNBOOK>/references (created if RUNBOOK is set)
#
# Inputs:
#   $1         — optional explicit path to introspection file
#   $DEMO_BASE — required env var (resolved by the caller via ensure-demo.sh)
#
# Prints three key=value lines on success:
#   INTROSPECTION_FILE=...
#   RUNBOOK=...          (empty string if no runbook is configured)
#   REFS_DIR=...          (empty string if no runbook is configured)
#
# The caller handles the empty-runbook case (ask the user, then call set-runbook.sh).
# Exits 1 only on hard errors: missing introspection file or missing DEMO_BASE.
#
# Usage:
#   eval "$(DEMO_BASE="$DEMO_BASE" bash "${CLAUDE_SKILL_DIR}/scripts/resolve-ingest-inputs.sh" "$ARG_PATH")"

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"
ARG_PATH="${1:-}"

if [ -z "${DEMO_BASE:-}" ]; then
  echo "ERROR: DEMO_BASE env var is not set. Run project discovery first." >&2
  exit 1
fi

# 1. Introspection file — explicit arg first, then default location
if [ -n "$ARG_PATH" ] && [ -f "$ARG_PATH" ]; then
  INTROSPECTION_FILE="$ARG_PATH"
else
  INTROSPECTION_FILE="$DEMO_BASE/introspection.md"
fi

if [ ! -f "$INTROSPECTION_FILE" ]; then
  echo "ERROR: No introspection file at: $INTROSPECTION_FILE" >&2
  echo "Run /showboat:introspect first, or pass a file path explicitly." >&2
  exit 1
fi

# 2. Runbook — soft-fail if not configured; caller will prompt + call set-runbook.sh
RUNBOOK=""
REFS_DIR=""
if P=$(bash "$PLUGIN_ROOT/scripts/resolve-runbook.sh" 2>/dev/null); then
  RUNBOOK="$P"
  REFS_DIR="$(dirname "$RUNBOOK")/references"
  mkdir -p "$REFS_DIR"
fi

printf 'INTROSPECTION_FILE=%s\n' "$INTROSPECTION_FILE"
printf 'RUNBOOK=%s\n' "$RUNBOOK"
printf 'REFS_DIR=%s\n' "$REFS_DIR"
