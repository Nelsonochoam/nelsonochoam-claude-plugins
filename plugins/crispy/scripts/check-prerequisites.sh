#!/usr/bin/env bash
# check-prerequisites.sh — Check whether intent exists and report available artifacts.
#
# Usage:
#   PREREQ_RESULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-prerequisites.sh" "$FEATURE_PATH" "<phase>")
#
# Arguments:
#   $1 — FEATURE_PATH (absolute path to the feature folder)
#   $2 — Current phase name (research-questions, research, design, structure, plan, implement)
#
# Output: JSON object to stdout with:
#   ok              — true if 1-intent.md exists (the only hard gate)
#   intent_missing  — true if 1-intent.md does not exist
#   available       — array of artifact keys whose files exist
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

# --- Check intent (the only hard gate) ---
INTENT_MISSING=true
if [ -f "$FEATURE_PATH/1-intent.md" ]; then
  INTENT_MISSING=false
fi

# --- Check which other artifacts exist ---
AVAILABLE_JSON="[]"

for key in research-questions research design structure plan; do
  case "$key" in
    research-questions) artifact="$FEATURE_PATH/2-research-questions.md" ;;
    research)           artifact="$FEATURE_PATH/3-research.md" ;;
    design)             artifact="$FEATURE_PATH/4-design.md" ;;
    structure)          artifact="$FEATURE_PATH/5-structure-outline.md" ;;
    plan)               artifact="$FEATURE_PATH/6-plan.md" ;;
  esac
  if [ -f "$artifact" ]; then
    AVAILABLE_JSON=$(echo "$AVAILABLE_JSON" | jq --arg p "$key" '. + [$p]')
  fi
done

if [ "$INTENT_MISSING" = "false" ]; then
  AVAILABLE_JSON=$(echo "$AVAILABLE_JSON" | jq '. + ["intent"]' | jq 'sort')
fi

# --- Determine ok ---
OK=true
if [ "$INTENT_MISSING" = "true" ]; then
  OK=false
fi

# --- Output ---
jq -n \
  --argjson ok "$OK" \
  --argjson intent_missing "$INTENT_MISSING" \
  --argjson available "$AVAILABLE_JSON" \
  --arg current_phase "$CURRENT_PHASE" \
  '{
    ok: $ok,
    intent_missing: $intent_missing,
    available: $available,
    current_phase: $current_phase
  }'
