#!/bin/bash
# session-start.sh: Restore CRISPY_FEATURE across /clear within the same claude session.
#
# How it works:
#   - $PPID inside this hook subprocess is the claude process PID
#   - This is stable within one claude session and changes on fresh invocations
#   - Feature-discovery writes the feature name to /tmp/.crispy_session_${PPID}
#   - This hook restores it via CLAUDE_ENV_FILE after every /clear

SESSION_FILE="/tmp/.crispy_session_${PPID}"

if [ -f "$SESSION_FILE" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
  CRISPY_FEATURE=$(cat "$SESSION_FILE")
  # Strip anything that isn't alphanumeric, dash, or underscore to prevent shell injection
  CRISPY_FEATURE=$(echo "$CRISPY_FEATURE" | tr -cd '[:alnum:]-_')
  if [ -n "$CRISPY_FEATURE" ]; then
    echo "export CRISPY_FEATURE=\"$CRISPY_FEATURE\"" >> "$CLAUDE_ENV_FILE"
  fi
fi

exit 0
