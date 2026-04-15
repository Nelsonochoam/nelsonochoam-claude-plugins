#!/usr/bin/env bash
# capture-command.sh — Runs a command and outputs a JSON evidence record.
#
# Usage:
#   bash capture-command.sh "<command>" "<label>" ["<evidence-file>"]
#
# Outputs a single JSON line to stdout (and appends to evidence file if provided).
# The command is executed via bash -c, so pipes and redirects work.

set -uo pipefail

COMMAND="$1"
LABEL="${2:-}"
EVIDENCE_FILE="${3:-}"

if [ -z "$COMMAND" ]; then
  echo '{"error":"No command provided"}' >&2
  exit 1
fi

# Generate a unique evidence ID
EV_ID="ev-$(date +%s)-$$"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Capture command output with timing
TMPOUT=$(mktemp)
TMPERR=$(mktemp)

START_TIME=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))' 2>/dev/null || echo 0)

# Run the command
bash -c "$COMMAND" > "$TMPOUT" 2> "$TMPERR"
EXIT_CODE=$?

END_TIME=$(date +%s%N 2>/dev/null || python3 -c 'import time; print(int(time.time()*1e9))' 2>/dev/null || echo 0)

# Calculate duration in milliseconds
if [ "$START_TIME" != "0" ] && [ "$END_TIME" != "0" ]; then
  DURATION_MS=$(( (END_TIME - START_TIME) / 1000000 ))
else
  DURATION_MS=0
fi

# Read output (truncate if extremely large)
STDOUT=$(head -c 50000 "$TMPOUT")
STDERR=$(head -c 10000 "$TMPERR")

# Clean up temp files
rm -f "$TMPOUT" "$TMPERR"

# Build JSON record
RECORD=$(jq -n \
  --arg id "$EV_ID" \
  --arg type "command" \
  --arg timestamp "$TIMESTAMP" \
  --arg command "$COMMAND" \
  --argjson exit_code "$EXIT_CODE" \
  --arg stdout "$STDOUT" \
  --arg stderr "$STDERR" \
  --argjson duration_ms "$DURATION_MS" \
  --arg label "$LABEL" \
  '{id: $id, type: $type, timestamp: $timestamp, command: $command, exit_code: $exit_code, stdout: $stdout, stderr: $stderr, duration_ms: $duration_ms, label: $label}')

# Output to stdout
echo "$RECORD"

# Append to evidence file if provided
if [ -n "$EVIDENCE_FILE" ]; then
  echo "$RECORD" >> "$EVIDENCE_FILE"
fi
