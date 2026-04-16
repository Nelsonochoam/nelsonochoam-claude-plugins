#!/usr/bin/env bash
# session-start.sh — Restores SHOWBOAT_PROJECT and FEATURE across /clear within the same claude session.
#
# The session files are keyed to $PPID (the claude process PID), so they are
# automatically scoped to this session and ignored by future invocations.

SESSION_FILE="/tmp/.showboat_session_${PPID}"
FEATURE_FILE="/tmp/.showboat_feature_${PPID}"

if [ -z "$SHOWBOAT_PROJECT" ] && [ -f "$SESSION_FILE" ]; then
  SHOWBOAT_PROJECT=$(cat "$SESSION_FILE")
  if [ -n "$SHOWBOAT_PROJECT" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export SHOWBOAT_PROJECT=\"$SHOWBOAT_PROJECT\"" >> "$CLAUDE_ENV_FILE"
  fi
fi

if [ -z "$FEATURE" ] && [ -f "$FEATURE_FILE" ]; then
  FEATURE=$(cat "$FEATURE_FILE")
  if [ -n "$FEATURE" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export FEATURE=\"$FEATURE\"" >> "$CLAUDE_ENV_FILE"
  fi
fi
