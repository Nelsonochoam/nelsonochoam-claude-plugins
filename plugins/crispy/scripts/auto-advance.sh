#!/usr/bin/env bash
# auto-advance.sh — Runs missing prerequisite phases using `claude -p`.
#
# Takes the feature path and target phase, determines which phases are missing,
# and runs each one sequentially via `claude -p` with the crispy plugin loaded.
#
# Usage:
#   bash "${CLAUDE_PLUGIN_ROOT}/scripts/auto-advance.sh" "$FEATURE_PATH" "<target-phase>" "$CLAUDE_PLUGIN_ROOT"
#
# Arguments:
#   $1 — FEATURE_PATH (absolute path to the feature folder)
#   $2 — Target phase the user wants to reach
#   $3 — CLAUDE_PLUGIN_ROOT (path to the crispy plugin root)
#
# The script:
#   1. Runs check-prerequisites.sh to find missing phases
#   2. For each missing phase (in pipeline order), invokes `claude -p` with the skill
#   3. Verifies the artifact file exists after each phase
#   4. Exits 0 if all prerequisites are now met, 1 if any phase failed
#
# Output: Progress messages to stdout, errors to stderr.

set -euo pipefail

FEATURE_PATH="${1:-}"
TARGET_PHASE="${2:-}"
PLUGIN_ROOT="${3:-}"

if [ -z "$FEATURE_PATH" ] || [ -z "$TARGET_PHASE" ] || [ -z "$PLUGIN_ROOT" ]; then
  echo "Usage: auto-advance.sh <feature-path> <target-phase> <plugin-root>" >&2
  exit 1
fi

SCRIPTS_DIR="$PLUGIN_ROOT/scripts"
PLUGIN_DIR="$(dirname "$PLUGIN_ROOT")"

# Extract feature name from path
FEATURE_NAME=$(basename "$FEATURE_PATH")

# --- Pipeline order ---
# Bash 3 compatible — no associative arrays
PIPELINE_ORDER="research-questions research design structure plan"

get_skill_name() {
  case "$1" in
    research-questions) echo "research-questions" ;;
    research) echo "research" ;;
    design) echo "design" ;;
    structure) echo "structure-outline" ;;
    plan) echo "plan" ;;
  esac
}

get_artifact_file() {
  case "$1" in
    research-questions) echo "$FEATURE_PATH/2-research-questions.md" ;;
    research) echo "$FEATURE_PATH/3-research.md" ;;
    design) echo "$FEATURE_PATH/4-design.md" ;;
    structure) echo "$FEATURE_PATH/5-structure-outline.md" ;;
    plan) echo "$FEATURE_PATH/6-plan.md" ;;
  esac
}

# --- Get missing phases ---
PREREQ_JSON=$(bash "$SCRIPTS_DIR/check-prerequisites.sh" "$FEATURE_PATH" "$TARGET_PHASE")

INTENT_MISSING=$(echo "$PREREQ_JSON" | jq -r '.intent_missing')
if [ "$INTENT_MISSING" = "true" ]; then
  echo "Error: Intent is missing. Run /crispy:intent first — it cannot be auto-advanced." >&2
  exit 1
fi

# Compute which phases before the target are missing by comparing pipeline order vs available artifacts.
# check-prerequisites.sh only hard-gates on intent (ok=true whenever intent exists), so we cannot
# rely on its `ok` field to determine whether pipeline phases are missing.
AVAILABLE=$(echo "$PREREQ_JSON" | jq -r '.available[]' 2>/dev/null || true)

MISSING=""
for phase in $PIPELINE_ORDER; do
  if [ "$phase" = "$TARGET_PHASE" ]; then
    break
  fi
  if ! echo "$AVAILABLE" | grep -qx "$phase"; then
    MISSING="${MISSING}${MISSING:+
}${phase}"
  fi
done

if [ -z "$MISSING" ]; then
  echo "All prerequisites for '$TARGET_PHASE' are already met."
  exit 0
fi

echo "Auto-advancing missing phases for '$TARGET_PHASE'..."
echo "Missing: $MISSING"
echo ""

# --- Run each missing phase in pipeline order ---
for phase in $PIPELINE_ORDER; do
  # Skip phases that aren't missing
  if ! echo "$MISSING" | grep -qx "$phase"; then
    continue
  fi

  SKILL_NAME=$(get_skill_name "$phase")
  ARTIFACT_PATH=$(get_artifact_file "$phase")

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Auto-advancing: $phase (via /crispy:$SKILL_NAME)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  PROMPT="You are running in auto-advance mode. Execute the /crispy:$SKILL_NAME skill for feature '$FEATURE_NAME' at path '$FEATURE_PATH'.

IMPORTANT auto-advance rules:
- Do NOT ask the user any questions — make reasonable decisions yourself
- Do NOT wait for user confirmation — write the artifact and continue
- Do NOT run the prerequisite check (prerequisites are being handled by the auto-advance pipeline)
- DO execute the full analysis/research/writing workflow from the skill
- DO write the artifact to $ARTIFACT_PATH
- Read $FEATURE_PATH/1-intent.md and any other existing artifacts in $FEATURE_PATH/ for context

Run /crispy:$SKILL_NAME now."

  if ! CRISPY_FEATURE="$FEATURE_NAME" claude -p \
    --plugin-dir "$PLUGIN_DIR/crispy" \
    --add-dir "$FEATURE_PATH" \
    --permission-mode auto \
    --model opus \
    "$PROMPT" 2>&1; then
    echo "" >&2
    echo "Error: Auto-advance failed for phase '$phase'." >&2
    echo "You can run /crispy:$SKILL_NAME manually to complete this phase." >&2
    exit 1
  fi

  echo ""

  # Verify artifact was written
  if [ -f "$ARTIFACT_PATH" ]; then
    echo "Auto-advanced: $phase — artifact written to $ARTIFACT_PATH"
  else
    echo "Error: Auto-advance for '$phase' did not produce the expected artifact at $ARTIFACT_PATH." >&2
    echo "You can run /crispy:$SKILL_NAME manually to complete this phase." >&2
    exit 1
  fi

  echo ""
done

# --- Final verification ---
FINAL_JSON=$(bash "$SCRIPTS_DIR/check-prerequisites.sh" "$FEATURE_PATH" "$TARGET_PHASE")
FINAL_AVAILABLE=$(echo "$FINAL_JSON" | jq -r '.available[]' 2>/dev/null || true)

STILL_MISSING=""
for phase in $PIPELINE_ORDER; do
  if [ "$phase" = "$TARGET_PHASE" ]; then
    break
  fi
  if ! echo "$FINAL_AVAILABLE" | grep -qx "$phase"; then
    STILL_MISSING="${STILL_MISSING}${STILL_MISSING:+, }${phase}"
  fi
done

if [ -z "$STILL_MISSING" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "All prerequisites for '$TARGET_PHASE' are now met."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo "Warning: Some prerequisites are still missing after auto-advance: $STILL_MISSING" >&2
  exit 1
fi
