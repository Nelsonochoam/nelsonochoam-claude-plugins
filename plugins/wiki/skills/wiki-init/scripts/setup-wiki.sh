#!/usr/bin/env bash
# Symlink to the shared setup script in the plugin's scripts/ directory.
# This avoids duplication while keeping the skill self-contained in structure.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

exec bash "$PLUGIN_ROOT/scripts/setup-wiki.sh" "$@"
