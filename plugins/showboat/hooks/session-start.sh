#!/usr/bin/env bash
# session-start.sh — Restores SHOWBOAT_PROJECT across /clear within the same claude session.
#
# The session file is keyed to $PPID (the claude process PID), so it is
# automatically scoped to this session and ignored by future invocations.

SESSION_FILE="/tmp/.showboat_session_${PPID}"

if [ -z "$SHOWBOAT_PROJECT" ] && [ -f "$SESSION_FILE" ]; then
  SHOWBOAT_PROJECT=$(cat "$SESSION_FILE")
  if [ -n "$SHOWBOAT_PROJECT" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export SHOWBOAT_PROJECT=\"$SHOWBOAT_PROJECT\"" >> "$CLAUDE_ENV_FILE"
  fi
fi
