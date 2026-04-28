#!/usr/bin/env bash
# next-phase.sh — Deterministic lookup for the next workable implementation phase.
#
# Reads manifest.json and finds the first implementation phase where
# status is "pending" and all dependencies have status "done".
#
# Usage:
#   NEXT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/next-phase.sh" "$FEATURE_PATH")
#
# Arguments:
#   $1 — FEATURE_PATH (absolute path to the feature folder)
#
# Output: JSON object to stdout with:
#   found   — true if a workable phase was found
#   id      — phase key (e.g., "phase-1"), null if not found
#   name    — phase display name, null if not found
#   file    — absolute path to the phase doc, null if not found
#   reason  — null if found; "all_done", "blocked", or "no_implementation_key" otherwise
#   blocked_by — array of blocking dependency IDs (only when reason is "blocked")
#
# Exit code is always 0. The script reports facts; it does not make decisions.

set -euo pipefail

FEATURE_PATH="${1:-}"

if [ -z "$FEATURE_PATH" ]; then
  echo '{"error":"Usage: next-phase.sh <feature-path>"}' >&2
  exit 1
fi

MANIFEST="$FEATURE_PATH/manifest.json"

if [ ! -f "$MANIFEST" ]; then
  jq -n '{found: false, id: null, name: null, file: null, reason: "no_manifest", blocked_by: []}'
  exit 0
fi

# Check if the implementation key exists
HAS_IMPL=$(jq 'has("implementation")' "$MANIFEST" 2>/dev/null || echo "false")

if [ "$HAS_IMPL" != "true" ]; then
  jq -n '{found: false, id: null, name: null, file: null, reason: "no_implementation_key", blocked_by: []}'
  exit 0
fi

# Find the next workable phase:
# - status is "pending"
# - all dependencies have status "done"
#
# jq does the heavy lifting: iterate implementation entries, check each pending
# phase's dependencies against the implementation map, return the first match.
jq -r '
  .implementation as $impl |

  # Collect all pending phase IDs
  [ $impl | to_entries[] | select(.value.status == "pending") | .key ] as $pending |

  # If no pending phases, everything is done
  if ($pending | length) == 0 then
    {found: false, id: null, name: null, file: null, reason: "all_done", blocked_by: []}
  else
    # For each pending phase, check if all dependencies are done
    [ $pending[] as $pid |
      $impl[$pid].dependencies as $deps |
      # Find which dependencies are NOT done
      [ $deps[] | select($impl[.].status != "done") ] as $blockers |
      if ($blockers | length) == 0 then
        {id: $pid, name: $impl[$pid].name, file: $impl[$pid].file, blockers: []}
      else
        {id: $pid, name: $impl[$pid].name, file: $impl[$pid].file, blockers: $blockers}
      end
    ] |

    # Find first phase with no blockers
    ( [ .[] | select(.blockers | length == 0) ] | first ) as $ready |

    if $ready != null then
      {found: true, id: $ready.id, name: $ready.name, file: $ready.file, reason: null, blocked_by: []}
    else
      # All pending phases are blocked — report the first one and its blockers
      .[0] as $first |
      {found: false, id: null, name: null, file: null, reason: "blocked", blocked_by: $first.blockers}
    end
  end
' "$MANIFEST"
