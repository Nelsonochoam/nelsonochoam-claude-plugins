#!/usr/bin/env bash
# detect-capabilities.sh — Detects what screenshot/browser tools are available.
#
# Outputs a JSON object describing available capabilities.
#
# Usage:
#   CAPS=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-capabilities.sh")

BROWSER="none"
SCREENSHOT=false
HEADLESS=false
TOOLS=()

# Check for Rodney (Simon Willison's browser automation CLI — preferred tool)
# Rodney manages multi-turn Chrome sessions via Chrome DevTools Protocol.
# Commands: start, open, js, click, screenshot, stop
if command -v rodney &>/dev/null; then
  BROWSER="rodney"
  HEADLESS=true
  SCREENSHOT=true
  TOOLS+=("rodney")
fi

# Check for Chrome/Chromium (headless screenshot support)
if command -v google-chrome &>/dev/null; then
  BROWSER="chrome"
  HEADLESS=true
  SCREENSHOT=true
  TOOLS+=("chrome")
elif command -v chromium &>/dev/null; then
  BROWSER="chromium"
  HEADLESS=true
  SCREENSHOT=true
  TOOLS+=("chromium")
elif [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
  BROWSER="chrome-mac"
  HEADLESS=true
  SCREENSHOT=true
  TOOLS+=("chrome-mac")
fi

# Check for shot-scraper (Simon Willison's screenshot CLI)
if command -v shot-scraper &>/dev/null; then
  SCREENSHOT=true
  TOOLS+=("shot-scraper")
fi

# Check for Playwright
if command -v playwright &>/dev/null || npx playwright --version &>/dev/null 2>&1; then
  SCREENSHOT=true
  TOOLS+=("playwright")
fi

# Check for puppeteer
if npx puppeteer --version &>/dev/null 2>&1; then
  SCREENSHOT=true
  TOOLS+=("puppeteer")
fi

# Check for macOS screencapture (captures desktop, not headless)
if command -v screencapture &>/dev/null; then
  TOOLS+=("screencapture")
fi

# Check for common CLI tools
for tool in curl jq wget httpie; do
  if command -v "$tool" &>/dev/null; then
    TOOLS+=("$tool")
  fi
done

# Build JSON output
TOOLS_JSON=$(printf '%s\n' "${TOOLS[@]}" | jq -R . | jq -s .)

printf '{"browser":"%s","screenshot":%s,"headless":%s,"tools":%s}\n' \
  "$BROWSER" "$SCREENSHOT" "$HEADLESS" "$TOOLS_JSON"
