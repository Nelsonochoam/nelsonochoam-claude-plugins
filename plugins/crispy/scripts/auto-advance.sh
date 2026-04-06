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
#   3. Re-checks prerequisites after each phase to confirm it completed
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
# Maps phase keys to their skill slash-command names and artifact files
declare -A PHASE_SKILL=(
  [research-questions]="crispy-research-questions"
  [research]="crispy-research"
  [design]="crispy-design"
  [structure]="crispy-structure-outline"
  [plan]="crispy-plan"
)

declare -A PHASE_ARTIFACT=(
  [research-questions]="research-questions.md"
  [research]="research.md"
  [design]="design.md"
  [structure]="structure-outline.md"
  [plan]="plan.md"
)

PIPELINE_ORDER=(research-questions research design structure plan)

# --- Get missing phases ---
PREREQ_JSON=$(bash "$SCRIPTS_DIR/check-prerequisites.sh" "$FEATURE_PATH" "$TARGET_PHASE")

INTENT_MISSING=$(echo "$PREREQ_JSON" | jq -r '.intent_missing')
if [ "$INTENT_MISSING" = "true" ]; then
  echo "Error: Intent is missing. Run /crispy-intent first — it cannot be auto-advanced." >&2
  exit 1
fi

OK=$(echo "$PREREQ_JSON" | jq -r '.ok')
if [ "$OK" = "true" ]; then
  echo "All prerequisites for '$TARGET_PHASE' are already met."
  exit 0
fi

MISSING=$(echo "$PREREQ_JSON" | jq -r '.missing[]')

if [ -z "$MISSING" ]; then
  echo "All prerequisites for '$TARGET_PHASE' are already met."
  exit 0
fi

echo "Auto-advancing missing phases for '$TARGET_PHASE'..."
echo "Missing: $MISSING"
echo ""

# --- Run each missing phase in pipeline order ---
for phase in "${PIPELINE_ORDER[@]}"; do
  # Skip phases that aren't missing
  if ! echo "$MISSING" | grep -qx "$phase"; then
    continue
  fi

  SKILL_NAME="${PHASE_SKILL[$phase]}"
  ARTIFACT="${PHASE_ARTIFACT[$phase]}"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Auto-advancing: $phase (via /crispy-$SKILL_NAME)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Build the prompt for claude -p
  # We tell it to run the skill in auto-advance mode (no user interaction)
  PROMPT="You are running in auto-advance mode. Execute the /$SKILL_NAME skill for feature '$FEATURE_NAME' at path '$FEATURE_PATH'.

IMPORTANT auto-advance rules:
- Do NOT ask the user any questions — make reasonable decisions yourself
- Do NOT wait for user confirmation — write the artifact and mark the phase done
- Do NOT run the prerequisite check (prerequisites are being handled by the auto-advance pipeline)
- DO execute the full analysis/research/writing workflow from the skill
- DO write the artifact to $FEATURE_PATH/$ARTIFACT
- DO update $FEATURE_PATH/manifest.json to mark the '$phase' phase as done with today's date
- Read $FEATURE_PATH/intent.md and any other existing artifacts in $FEATURE_PATH/ for context

Run /$SKILL_NAME now."

  # Run claude -p with the crispy plugin loaded
  if ! CRISPY_FEATURE="$FEATURE_NAME" claude -p \
    --plugin-dir "$PLUGIN_DIR/crispy" \
    --permission-mode auto \
    --model opus \
    "$PROMPT" 2>&1; then
    echo "" >&2
    echo "Error: Auto-advance failed for phase '$phase'." >&2
    echo "You can run /$SKILL_NAME manually to complete this phase." >&2
    exit 1
  fi

  echo ""

  # Verify the phase completed
  VERIFY_JSON=$(bash "$SCRIPTS_DIR/check-prerequisites.sh" "$FEATURE_PATH" "$TARGET_PHASE")
  PHASE_STATUS=$(jq -r ".phases[\"$phase\"].status // \"pending\"" "$FEATURE_PATH/manifest.json" 2>/dev/null || echo "pending")

  if [ "$PHASE_STATUS" = "done" ]; then
    echo "Auto-advanced: $phase — artifact written to $FEATURE_PATH/$ARTIFACT"
  else
    # Check if the artifact file was created even if manifest wasn't updated
    if [ -f "$FEATURE_PATH/$ARTIFACT" ]; then
      echo "Warning: $phase artifact was written but manifest was not updated. Updating now..."
      # Update manifest using jq
      UPDATED=$(jq --arg phase "$phase" --arg file "$FEATURE_PATH/$ARTIFACT" --arg date "$(date +%Y-%m-%d)" \
        '.phases[$phase].status = "done" | .phases[$phase].file = $file | .phases[$phase].updated = $date' \
        "$FEATURE_PATH/manifest.json")
      echo "$UPDATED" > "$FEATURE_PATH/manifest.json"
      echo "Auto-advanced: $phase — artifact written to $FEATURE_PATH/$ARTIFACT"
    else
      echo "Error: Auto-advance for '$phase' did not produce the expected artifact." >&2
      echo "You can run /$SKILL_NAME manually to complete this phase." >&2
      exit 1
    fi
  fi

  echo ""
done

# --- Final verification ---
FINAL_JSON=$(bash "$SCRIPTS_DIR/check-prerequisites.sh" "$FEATURE_PATH" "$TARGET_PHASE")
FINAL_OK=$(echo "$FINAL_JSON" | jq -r '.ok')

if [ "$FINAL_OK" = "true" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "All prerequisites for '$TARGET_PHASE' are now met."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  STILL_MISSING=$(echo "$FINAL_JSON" | jq -r '.missing | join(", ")')
  echo "Warning: Some prerequisites are still missing after auto-advance: $STILL_MISSING" >&2
  exit 1
fi
