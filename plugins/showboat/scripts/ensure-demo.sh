#!/usr/bin/env bash
# ensure-demo.sh — Creates the demo and evidence directories for a feature.
#
# Usage:
#   DEMO_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "<feature-name>")
#
# Creates:
#   <BASE_DIR>/demos/
#   <BASE_DIR>/evidence/
#   <BASE_DIR>/evidence/assets/
#   <BASE_DIR>/verifications/
#
# Prints the base directory path (repo-level, not feature-level).

FEATURE_NAME="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR=$(bash "$SCRIPT_DIR/resolve-basedir.sh")

# Create directory structure
mkdir -p "$BASE_DIR/demos"
mkdir -p "$BASE_DIR/evidence/assets"
mkdir -p "$BASE_DIR/verifications"
mkdir -p "$BASE_DIR/learnings"

# If a feature name was provided, ensure its evidence file directory exists
if [ -n "$FEATURE_NAME" ]; then
  touch "$BASE_DIR/evidence/${FEATURE_NAME}.jsonl" 2>/dev/null || true
fi

printf '%s\n' "$BASE_DIR"
