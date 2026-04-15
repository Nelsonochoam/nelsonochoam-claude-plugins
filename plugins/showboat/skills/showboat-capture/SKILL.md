---
name: showboat-capture
description: Capture a single piece of evidence — run a command, take a screenshot, or make an HTTP call. Appends to the feature's evidence log.
argument-hint: '<feature-name> <command or URL to capture>'
disable-model-invocation: true
---

User's request: $ARGUMENTS

# Capture Evidence

You are capturing a single piece of evidence for a showboat demo. This skill appends one entry to the feature's evidence log (JSONL file).

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved base directory as `$DEMO_BASE`.

## Parse Arguments

The user provides: `<feature-name> <what to capture>`

Extract:
- **Feature name**: first argument (kebab-case, e.g., `add-user-search`)
- **Capture target**: everything after the feature name

If the feature name is missing, use `AskUserQuestion` to ask for it.

## Ensure Evidence Directory

```bash
DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "<feature-name>")
EVIDENCE_FILE="$DEMO_BASE/evidence/<feature-name>.jsonl"
```

## Determine Capture Type

**Key rule**: Always execute commands for real — never write evidence records with pre-composed output.

Based on the capture target, determine the evidence type:

### Type: `command`

If the target looks like a shell command (starts with a command name, contains flags, pipes, etc.):

```bash
RECORD=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/capture-command.sh" "<command>" "<label>" "$EVIDENCE_FILE")
```

The label should be a short description of what this command verifies (e.g., "Unit tests pass", "Build succeeds").

Report the result:

```
Evidence captured: <label>
  Command: <command>
  Exit code: <exit_code>
  Duration: <duration_ms>ms
  Evidence file: $EVIDENCE_FILE

<first 20 lines of stdout if non-empty>
```

### Type: `screenshot`

If the target is a URL (starts with `http://` or `https://`):

1. First, check available tools:
   ```bash
   CAPS=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-capabilities.sh")
   ```

2. If screenshot capability is available, take the screenshot using the best available tool (in priority order):

   **Rodney** (preferred — manages multi-turn browser sessions via Chrome DevTools Protocol):
   ```bash
   SCREENSHOT_PATH="$DEMO_BASE/evidence/assets/ev-$(date +%s)-screenshot.png"
   rodney start 2>/dev/null || true
   rodney open "<url>"
   rodney screenshot "$SCREENSHOT_PATH"
   ```
   Note: do NOT call `rodney stop` after a single screenshot — keep the session open for subsequent captures. The session will be stopped at the end of the demo assembly or when explicitly requested. If Rodney is managing a multi-page capture sequence, use `rodney open` to navigate between pages and `rodney click` for interactions before screenshots:
   ```bash
   rodney click '<css-selector>'     # interact with page elements
   rodney js 'document.title'        # extract page data
   rodney screenshot "$PATH"          # capture current state
   ```

   **shot-scraper** (single-shot screenshots, no session management):
   ```bash
   SCREENSHOT_PATH="$DEMO_BASE/evidence/assets/ev-$(date +%s)-screenshot.png"
   shot-scraper "<url>" -o "$SCREENSHOT_PATH" --width 1280 --height 720
   ```

   **Chrome headless** (fallback):
   ```bash
   SCREENSHOT_PATH="$DEMO_BASE/evidence/assets/ev-$(date +%s)-screenshot.png"
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless --disable-gpu --screenshot="$SCREENSHOT_PATH" --window-size=1280,720 "<url>" 2>/dev/null
   ```

3. Write evidence record manually to `$EVIDENCE_FILE`:
   ```jsonl
   {"id":"ev-<timestamp>","type":"screenshot","timestamp":"<ISO8601>","url":"<url>","path":"<relative-path-from-base>","label":"<description>","dimensions":"1280x720"}
   ```

4. If NO screenshot tool is available, write a `screenshot_unavailable` record:
   ```jsonl
   {"id":"ev-<timestamp>","type":"screenshot_unavailable","timestamp":"<ISO8601>","url":"<url>","label":"<description>","reason":"No browser automation tool available. Install Rodney: uvx rodney (preferred) or shot-scraper: pip install shot-scraper && shot-scraper install"}
   ```

Report the result:

```
Screenshot captured: <label>
  URL: <url>
  Saved to: <screenshot_path>
  Evidence file: $EVIDENCE_FILE
```

### Type: `http`

If the target looks like an HTTP method + URL (e.g., `GET http://localhost:3000/api/users`):

Execute the HTTP call using curl and capture the response:

```bash
RESPONSE=$(curl -s -w '\n%{http_code}\n%{time_total}' -X <METHOD> "<URL>" -H 'Content-Type: application/json')
```

Parse the response body, status code, and duration. Write evidence record to `$EVIDENCE_FILE`:
```jsonl
{"id":"ev-<timestamp>","type":"http","timestamp":"<ISO8601>","method":"<METHOD>","url":"<URL>","status":<code>,"body":"<response_body>","duration_ms":<ms>,"label":"<description>"}
```

### Type: `diff`

If the target is `diff` or `git diff`:

```bash
RECORD=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/capture-command.sh" "git diff --stat HEAD~1" "Changes summary" "$EVIDENCE_FILE")
```

## Read Evidence Format Reference

For detailed JSONL schema, read `${CLAUDE_SKILL_DIR}/references/evidence-format.md`.

## Done

After capturing, report what was captured and the total evidence count:

```bash
wc -l < "$EVIDENCE_FILE"
```

```
Evidence item added. Total evidence for <feature>: <count> items.
```
