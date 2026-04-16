---
name: demo
description: Build a demo document using the showboat CLI — proves a feature works through manual browser interaction (rodney) and API calls (curl), not just test output.
argument-hint: '<feature-name>'
model: opus
---

User's request: $ARGUMENTS

# Demo: Prove It With Showboat

You are building a demo document that **manually proves a feature works**. The document is constructed entirely by running `showboat` commands — never by writing markdown directly. That distinction matters: a document built from real command executions is proof; one written by hand is not.

The goal is to act like a human tester sitting at a browser: navigate to the feature, interact with it, observe the results, and capture everything. Automated tests are supporting evidence. The manual demonstration is the main event.

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved variables as `$BASE_DIR` and `$DEMO_BASE`.

## Parse Arguments

Extract the feature name from `$ARGUMENTS` (e.g., `add-user-search`). If missing, use `AskUserQuestion` to ask for it.

Also extract any inline details the user provided — app URL, port, credentials, routes. These override everything else.

```bash
DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "<feature-name>")
DEMO_FILE="$DEMO_BASE/<feature-name>.md"
```

## Understand What Changed

```bash
git log --oneline -5
git diff --stat HEAD~1
```

Read the diff of the most relevant changed files to understand: what routes, endpoints, or UI components were added or modified. This tells you exactly what to test.

## Prepare to Test

The goal is to know: where the app runs, how to authenticate, which routes or endpoints to exercise, and which test commands are relevant.

### Read the playbook (if configured)

```bash
PLAYBOOK=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-playbook.sh" 2>/dev/null) || true
echo "${PLAYBOOK:-NO_PLAYBOOK}"
```

If a playbook path is returned, read it:

```bash
cat "$PLAYBOOK"
```

The playbook is a markdown document with general testing knowledge for the application — how to log in, which URLs to use, test commands, common patterns, known quirks. It may be a single self-contained file, or it may contain links to other files (Obsidian wikilinks like `[[auth-guide]]` or relative paths like `./api-testing.md`).

**Follow links progressively**: scan the playbook for links relevant to what you're testing (the feature name, the route, the service). Read only those linked pages — not everything. This mirrors how you'd browse a wiki: start at the index, follow only what's relevant.

Use everything you find to inform: how to start the app, how to authenticate, which endpoints or pages to exercise, what a passing response looks like.

### When there is no playbook

Read `${CLAUDE_SKILL_DIR}/references/self-discovery.md` and follow it to discover the same information from the codebase. The git diff is your primary guide — it tells you exactly what changed and therefore what to demonstrate.

Do not block on missing information. Make a reasonable attempt, use `showboat pop` to discard failed commands, and move on. Mark the demo `partial` in the closing report.

## Initialize the Demo Document

```bash
showboat init "$DEMO_FILE" "<Feature Title>"
showboat note "$DEMO_FILE" "<2-3 sentence summary of what was built and why, derived from git log.>"
```

## Capture Evidence

Every piece of evidence is captured by a `showboat` command. If a command errors in a way that shouldn't stay in the document, remove it with `showboat pop "$DEMO_FILE"` before retrying.

### 1. What Changed

```bash
showboat note "$DEMO_FILE" "## What Changed"
showboat exec "$DEMO_FILE" bash "git diff --stat HEAD~1"
```

### 2. Manual Demonstration (primary proof)

This is the heart of the demo. Manually exercise the feature the way a user would — navigate, interact, observe, assert. Use rodney for browser-based features and curl for APIs.

#### Check what tools are available

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-capabilities.sh"
```

**If rodney or curl is needed**, read `${CLAUDE_SKILL_DIR}/references/testing-commands.md` now — it has the full reference for both tools: rodney navigation/interaction/assertions/screenshots and curl patterns for auth, chaining, and field assertions.

#### For web app features — use Rodney

Start one browser session and keep it running for all interactions. Don't restart between pages.

```bash
showboat note "$DEMO_FILE" "## Manual Browser Verification"
showboat exec "$DEMO_FILE" bash "rodney start"
```

Navigate to the feature. If the app requires login, authenticate first:

```bash
showboat exec "$DEMO_FILE" bash "rodney open '<login-url>'"
showboat exec "$DEMO_FILE" bash "rodney input '<email-selector>' '<email>'"
showboat exec "$DEMO_FILE" bash "rodney input '<password-selector>' '<password>'"
showboat exec "$DEMO_FILE" bash "rodney click '<submit-selector>'"
showboat exec "$DEMO_FILE" bash "rodney waitload"
```

Navigate to the feature being demonstrated:

```bash
showboat exec "$DEMO_FILE" bash "rodney open '<feature-url>'"
showboat exec "$DEMO_FILE" bash "rodney waitstable"
```

Take a before-state screenshot:

```bash
showboat note "$DEMO_FILE" "Initial state of <page/feature>:"
rodney screenshot /tmp/sb-<feature>-before.png
showboat image "$DEMO_FILE" /tmp/sb-<feature>-before.png
```

Interact with the feature — click buttons, fill forms, trigger the behavior being tested:

```bash
showboat exec "$DEMO_FILE" bash "rodney click '<selector>'"
showboat exec "$DEMO_FILE" bash "rodney input '<selector>' '<value>'"
showboat exec "$DEMO_FILE" bash "rodney waitstable"
```

Assert the expected outcome is visible. Use `rodney exists`, `rodney text`, `rodney assert`, or `rodney js` to verify — not just screenshot:

```bash
# Verify expected element/text appeared
showboat exec "$DEMO_FILE" bash "rodney exists '<result-selector>'"
showboat exec "$DEMO_FILE" bash "rodney text '<result-selector>'"

# Or use JS assertions
showboat exec "$DEMO_FILE" bash "rodney assert 'document.querySelector(\"<sel>\").textContent' '<expected>'"
```

Take an after-state screenshot showing the result:

```bash
showboat note "$DEMO_FILE" "Result after <action>:"
rodney screenshot /tmp/sb-<feature>-after.png
showboat image "$DEMO_FILE" /tmp/sb-<feature>-after.png
```

Repeat for each meaningful state or interaction the feature has.

Stop the browser when done:

```bash
showboat exec "$DEMO_FILE" bash "rodney stop"
```

#### For API features — use curl

For each affected endpoint, make a real request and capture the full response. Prove specific behavior — not just a 200 status, but that the response contains the right data. See `${CLAUDE_SKILL_DIR}/references/testing-commands.md` for auth, chaining, and field-assertion patterns.

```bash
showboat note "$DEMO_FILE" "## API Verification"
showboat note "$DEMO_FILE" "Testing <endpoint description>:"
showboat exec "$DEMO_FILE" bash "curl -s -X <METHOD> '<url>' \
  -H 'Content-Type: application/json' \
  -d '<body>' | jq ."
```

### 3. Automated Tests (supporting evidence)

Tests confirm correctness but don't replace the manual demonstration above. Run them as supporting evidence:

```bash
showboat note "$DEMO_FILE" "## Test Suite"
showboat exec "$DEMO_FILE" bash "<test-command>"
```

If tests are slow or noisy, run only the test file(s) directly related to the changed code.

### 4. Type Check / Build (if applicable)

```bash
showboat exec "$DEMO_FILE" bash "<type-check-or-build-command>"
```

### 5. Closing Note

```bash
showboat note "$DEMO_FILE" "The <feature> is correctly implemented. The browser interaction and API calls above demonstrate the full user-facing behavior."
```

## Verify

```bash
showboat verify "$DEMO_FILE"
```

If verify exits non-zero, review the diffs and either fix the commands or add a note explaining the divergence.

## Done

Report:

```
Demo written: $DEMO_FILE

Evidence captured:
  - <count> rodney interactions
  - <count> screenshots
  - <count> curl/API calls
  - <count> test/build outputs
  - Status: <verified | partial>

Re-run all checks:
  showboat verify "$DEMO_FILE"
```
