#!/usr/bin/env bash
# session-start.sh — Restores the active wiki vault across /clear within the same claude session.
# If WIKI is already set as an env var, it takes effect naturally.
# If not set, checks the session file (written by vault-discovery) and restores WIKI.

SESSION_FILE="/tmp/.wiki_session_${PPID}"

if [ -z "${WIKI:-}" ] && [ -f "$SESSION_FILE" ]; then
  SAVED=$(cat "$SESSION_FILE")
  if [ -n "$SAVED" ] && [ -n "${CLAUDE_ENV_FILE:-}" ]; then
    echo "export WIKI=\"$SAVED\"" >> "$CLAUDE_ENV_FILE"
  fi
fi
