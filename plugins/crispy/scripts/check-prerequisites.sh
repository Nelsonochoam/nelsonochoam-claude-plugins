#!/usr/bin/env bash
# check-prerequisites.sh — Deterministic prerequisite check for crispy phases.
#
# Checks whether the required prerequisite phase artifact files exist on disk
# for a given target phase. No manifest read needed for planning phases —
# done is determined by file existence alone.
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
#   intent_missing  — true if intent.md does not exist (always checked first)
#   missing         — array of prerequisite phase keys whose artifact files are absent
#   done            — array of prerequisite phase keys whose artifact files exist
#   current_phase   — echo of the requested phase
#
# Exit code is always 0. The script reports facts; it does not make decisions.

set -euo pipefail

FEATURE_PATH="${1:-}"
CURRENT_PHASE="${2:-}"

if [ -z "$FEATURE_PATH" ] || [ -z "$CURRENT_PHASE" ]; then
  echo '{"error":"Usage: check-prerequisites.sh <feature-path> <phase>"}' >&2
  exit 1
fi

# --- Phase → artifact file map ---
get_artifact_file() {
  local phase="$1"
  case "$phase" in
    intent)             echo "$FEATURE_PATH/intent.md" ;;
    research-questions) echo "$FEATURE_PATH/research-questions.md" ;;
    research)           echo "$FEATURE_PATH/research.md" ;;
    design)             echo "$FEATURE_PATH/design.md" ;;
    structure)          echo "$FEATURE_PATH/structure-outline.md" ;;
    plan)               echo "$FEATURE_PATH/plan.md" ;;
    *)                  echo "" ;;
  esac
}

# --- Prerequisite map ---
# Intent is always implicitly required and checked separately.
get_prerequisites() {
  local phase="$1"
  case "$phase" in
    research-questions) echo "" ;;
    research)           echo "research-questions" ;;
    design)             echo "research-questions research" ;;
    structure)          echo "research-questions research design" ;;
    plan)               echo "research-questions research design structure" ;;
    implement)          echo "research-questions research design structure plan" ;;
    *)                  echo "" ;;
  esac
}

# --- Check intent ---
INTENT_FILE=$(get_artifact_file "intent")
INTENT_MISSING=false
if [ ! -f "$INTENT_FILE" ]; then
  INTENT_MISSING=true
fi

# --- Check other prerequisites ---
PREREQS=$(get_prerequisites "$CURRENT_PHASE")

MISSING_JSON="[]"
DONE_JSON="[]"

if [ -n "$PREREQS" ]; then
  for prereq in $PREREQS; do
    FILE=$(get_artifact_file "$prereq")
    if [ -f "$FILE" ]; then
      DONE_JSON=$(echo "$DONE_JSON" | jq --arg p "$prereq" '. + [$p]')
    else
      MISSING_JSON=$(echo "$MISSING_JSON" | jq --arg p "$prereq" '. + [$p]')
    fi
  done
fi

# Always include intent in the done list if it's done
if [ "$INTENT_MISSING" = "false" ]; then
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
    current_phase: $current_phase
  }'
