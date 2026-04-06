#!/usr/bin/env bash
# check-prerequisites.sh — Deterministic prerequisite check for crispy phases.
#
# Reads manifest.json and checks whether the required prerequisite phases
# are marked "done" for a given target phase.
#
# Usage:
#   PREREQ_RESULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-prerequisites.sh" "$FEATURE_PATH" "<phase>")
#
# Arguments:
#   $1 — FEATURE_PATH (absolute path to the feature folder)
#   $2 — Current phase name (research-questions, research, design, structure, plan, implement)
#
# Output: JSON object to stdout with:
#   ok              — true if all prerequisites are met
#   intent_missing  — true if intent phase is not done (always checked first)
#   missing         — array of prerequisite phase keys that are not done
#   done            — array of prerequisite phase keys that are done
#   current_phase   — echo of the requested phase
#   manifest_exists — whether manifest.json was found
#
# Exit code is always 0. The script reports facts; it does not make decisions.

set -euo pipefail

FEATURE_PATH="${1:-}"
CURRENT_PHASE="${2:-}"

if [ -z "$FEATURE_PATH" ] || [ -z "$CURRENT_PHASE" ]; then
  echo '{"error":"Usage: check-prerequisites.sh <feature-path> <phase>"}' >&2
  exit 1
fi

MANIFEST="$FEATURE_PATH/manifest.json"

# --- Prerequisite map ---
# Each phase lists the prerequisite phase keys (as they appear in manifest.json).
# Intent is always implicitly required and checked separately.
get_prerequisites() {
  local phase="$1"
  case "$phase" in
    research-questions) echo "" ;;                                    # only intent
    research)           echo "research-questions" ;;                  # + intent
    design)             echo "research-questions research" ;;         # + intent
    structure)          echo "research-questions research design" ;;  # + intent
    plan)               echo "research-questions research design structure" ;; # all prior phases
    implement)          echo "research-questions research design structure plan" ;; # all phases
    *)                  echo "" ;;
  esac
}

# --- Check manifest existence ---
if [ ! -f "$MANIFEST" ]; then
  cat <<EOF
{"ok":false,"intent_missing":true,"missing":[],"done":[],"current_phase":"$CURRENT_PHASE","manifest_exists":false}
EOF
  exit 0
fi

# --- Read intent status ---
INTENT_STATUS=$(jq -r '.phases.intent.status // "pending"' "$MANIFEST" 2>/dev/null || echo "pending")

INTENT_MISSING=false
if [ "$INTENT_STATUS" != "done" ]; then
  INTENT_MISSING=true
fi

# --- Check other prerequisites ---
PREREQS=$(get_prerequisites "$CURRENT_PHASE")

MISSING_JSON="[]"
DONE_JSON="[]"

if [ -n "$PREREQS" ]; then
  for prereq in $PREREQS; do
    STATUS=$(jq -r ".phases[\"$prereq\"].status // \"pending\"" "$MANIFEST" 2>/dev/null || echo "pending")
    if [ "$STATUS" = "done" ]; then
      DONE_JSON=$(echo "$DONE_JSON" | jq --arg p "$prereq" '. + [$p]')
    else
      MISSING_JSON=$(echo "$MISSING_JSON" | jq --arg p "$prereq" '. + [$p]')
    fi
  done
fi

# Always include intent in the done list if it's done
if [ "$INTENT_STATUS" = "done" ]; then
  DONE_JSON=$(echo "$DONE_JSON" | jq '. + ["intent"]')
fi

# --- Determine ok ---
OK=true
if [ "$INTENT_MISSING" = "true" ]; then
  OK=false
fi
MISSING_COUNT=$(echo "$MISSING_JSON" | jq 'length')
if [ "$MISSING_COUNT" -gt 0 ]; then
  OK=false
fi

# --- Output ---
jq -n \
  --argjson ok "$OK" \
  --argjson intent_missing "$INTENT_MISSING" \
  --argjson missing "$MISSING_JSON" \
  --argjson done_phases "$DONE_JSON" \
  --arg current_phase "$CURRENT_PHASE" \
  '{
    ok: $ok,
    intent_missing: $intent_missing,
    missing: $missing,
    done: $done_phases,
    current_phase: $current_phase,
    manifest_exists: true
  }'
