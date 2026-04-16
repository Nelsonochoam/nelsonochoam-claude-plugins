#!/usr/bin/env bash
# check-prerequisites.sh — Checks for required and recommended tools.
#
# Outputs a JSON object with tool status and install instructions.
# Exit code 0 = all required tools present, 1 = missing required tools.
#
# Usage:
#   bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-prerequisites.sh"

set -uo pipefail

MISSING_REQUIRED=()
MISSING_RECOMMENDED=()
INSTALLED=()

# ── Required tools (showboat will not work without these) ────────────

# showboat — the showboat CLI itself (https://github.com/simonw/showboat)
if command -v showboat &>/dev/null; then
  INSTALLED+=("showboat")
else
  MISSING_REQUIRED+=("showboat")
fi

# jq — used by resolve-basedir.sh, capture-command.sh, detect-capabilities.sh
if command -v jq &>/dev/null; then
  INSTALLED+=("jq")
else
  MISSING_REQUIRED+=("jq")
fi

# curl — used for HTTP evidence capture
if command -v curl &>/dev/null; then
  INSTALLED+=("curl")
else
  MISSING_REQUIRED+=("curl")
fi

# git — used for diff evidence, repo detection
if command -v git &>/dev/null; then
  INSTALLED+=("git")
else
  MISSING_REQUIRED+=("git")
fi

# ── Recommended tools (screenshots and browser automation) ───────────

# Rodney — preferred browser automation CLI (multi-turn sessions)
if command -v rodney &>/dev/null; then
  INSTALLED+=("rodney")
else
  MISSING_RECOMMENDED+=("rodney")
fi

# shot-scraper — fallback single-shot screenshots
if command -v shot-scraper &>/dev/null; then
  INSTALLED+=("shot-scraper")
else
  MISSING_RECOMMENDED+=("shot-scraper")
fi

# ── Browser fallbacks (checked but not flagged as missing) ───────────

HAS_BROWSER=false
if command -v rodney &>/dev/null; then
  HAS_BROWSER=true
elif command -v shot-scraper &>/dev/null; then
  HAS_BROWSER=true
elif command -v google-chrome &>/dev/null || command -v chromium &>/dev/null; then
  HAS_BROWSER=true
  INSTALLED+=("chrome")
elif [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
  HAS_BROWSER=true
  INSTALLED+=("chrome-mac")
fi

# ── Build output ─────────────────────────────────────────────────────

INSTALLED_JSON=$(printf '%s\n' "${INSTALLED[@]}" | jq -R . 2>/dev/null | jq -s . 2>/dev/null || echo '[]')
MISSING_REQ_JSON=$(printf '%s\n' "${MISSING_REQUIRED[@]}" | jq -R . 2>/dev/null | jq -s . 2>/dev/null || echo '[]')
MISSING_REC_JSON=$(printf '%s\n' "${MISSING_RECOMMENDED[@]}" | jq -R . 2>/dev/null | jq -s . 2>/dev/null || echo '[]')

# Handle empty arrays (jq -s on empty input returns null)
[ ${#INSTALLED[@]} -eq 0 ] && INSTALLED_JSON='[]'
[ ${#MISSING_REQUIRED[@]} -eq 0 ] && MISSING_REQ_JSON='[]'
[ ${#MISSING_RECOMMENDED[@]} -eq 0 ] && MISSING_REC_JSON='[]'

printf '{"ok":%s,"has_browser":%s,"installed":%s,"missing_required":%s,"missing_recommended":%s}\n' \
  "$([ ${#MISSING_REQUIRED[@]} -eq 0 ] && echo true || echo false)" \
  "$HAS_BROWSER" \
  "$INSTALLED_JSON" \
  "$MISSING_REQ_JSON" \
  "$MISSING_REC_JSON"

# Exit with error if required tools are missing
if [ ${#MISSING_REQUIRED[@]} -gt 0 ]; then
  exit 1
fi
