#!/usr/bin/env bash
# session-start.sh — Restores WIKI_VAULT across /clear within the same claude session.

SESSION_FILE="/tmp/.wiki_session_${PPID}"

if [ -z "$WIKI_VAULT" ] && [ -f "$SESSION_FILE" ]; then
  WIKI_VAULT=$(cat "$SESSION_FILE")
  if [ -n "$WIKI_VAULT" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export WIKI_VAULT=\"$WIKI_VAULT\"" >> "$CLAUDE_ENV_FILE"
  fi
fi
