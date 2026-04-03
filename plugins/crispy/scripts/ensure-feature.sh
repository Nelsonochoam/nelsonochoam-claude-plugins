#!/usr/bin/env bash
# ensure-feature.sh — Resolves and creates the feature folder for a given feature name.
#
# Usage:
#   FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "<feature-name>")
#
# Prints the full path: <BASE_DIR>/<feature-name>/
# Creates the directory if it does not already exist.

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: ensure-feature.sh <feature-name>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR=$(bash "$SCRIPT_DIR/get-config.sh")

FEATURE_PATH="$BASE_DIR/$FEATURE_NAME"
mkdir -p "$FEATURE_PATH"
printf '%s\n' "$FEATURE_PATH"
