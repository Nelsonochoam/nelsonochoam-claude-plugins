---
name: showboat-verify
description: Re-execute a demo's verification steps to check for regressions. Compares current results against original evidence and produces a verification report.
argument-hint: '<feature-name>'
disable-model-invocation: true
---

User's request: $ARGUMENTS

# Verify Demo

You are re-running all verification steps from an existing demo document to check that everything still works. This catches regressions.

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved base directory as `$DEMO_BASE`.

## Parse Arguments

Extract the feature name from `$ARGUMENTS`. If missing, list available demos and ask:

```bash
ls "$DEMO_BASE/demos/"*.md 2>/dev/null | grep -v index.md | while read f; do basename "$f" .md; done
```

Use `AskUserQuestion` to ask which demo to verify.

## Read the Demo Document

```bash
cat "$DEMO_BASE/demos/<feature-name>.md"
```

If the file doesn't exist, stop and tell the user:

> No demo found for `<feature-name>`. Available demos: <list>
>
> Run `/showboat-demo <feature-name>` to create a demo first.

## Extract Verification Commands

Find the `Verification Commands` JSON block in the demo document. It is a fenced code block labeled `json` inside the `## Verification Commands` section.

Parse it into a list of verification steps. Each step has: `type`, `command`/`method`/`url`, `expect_exit`/`expect_status`, and `label`.

If there are no verification commands, stop:

> This demo has no machine-readable verification commands. It may have been created manually or from an older version of showboat.

## Start Dev Server (if needed)

Only if the verification commands include `http` or `screenshot` steps that require a running server, read the testing context for dev server instructions:

```bash
cat "$DEMO_BASE/testing-context.md" 2>/dev/null || echo "NOT_FOUND"
```

Skip this section entirely if all verification steps are `command` type (no server needed).

If a testing context exists and it specifies a dev server:

1. Start the dev server in the background
2. Wait for the ready signal (from testing context)
3. If the server fails to start, record a `startup_failure` and continue with non-server checks

## Re-Execute Verification Steps

Read comparison strategies once before the loop: `${CLAUDE_SKILL_DIR}/references/comparison-strategies.md`. Do not re-read this for each step.

For each step in the verification commands:

### Type: `command`

```bash
RESULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/capture-command.sh" "<command>" "<label>")
```

Compare:
- **Exit code**: must match `expect_exit` exactly
- **Stdout**: fuzzy comparison (see comparison strategies)

### Type: `http`

Execute the HTTP call:

```bash
RESPONSE=$(curl -s -w '\n%{http_code}' -X <method> "<url>")
```

Compare:
- **Status code**: must match `expect_status` exactly
- **Response body**: structural comparison (same keys, same types)

### Type: `screenshot`

If screenshot capability is available, capture a new screenshot:

```bash
CAPS=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-capabilities.sh")
```

If **Rodney** is available, use it for screenshot verification (reuse a single session for all screenshot steps):

```bash
rodney start 2>/dev/null || true
rodney open "<url>"
rodney screenshot "$DEMO_BASE/verifications/assets/verify-<timestamp>.png"
# After all screenshot steps are done:
rodney stop
```

If Rodney is not available, fall back to shot-scraper or Chrome headless.

Save the new screenshot with a verification timestamp in the filename. Note that automated visual comparison is not possible — the verification report will note that a screenshot was captured for manual review.

## Build Verification Report

Read the template at `${CLAUDE_SKILL_DIR}/references/verification-template.md`.

For each step, record:
- **Pass**: current result matches expected
- **Fail**: current result differs from expected (include both original and current values)
- **Skip**: step could not be run (e.g., no browser tools for screenshots)

Write the report to: `$DEMO_BASE/verifications/<feature-name>-<YYYY-MM-DD>.md`

## Update Demo Status

If any step failed, update the demo document's frontmatter:

```yaml
status: regression
```

Use `Edit` to change only the status line in the demo document. Do not modify any other content.

If all steps passed, ensure the status is `verified`.

## Stop Dev Server

If you started a dev server, stop it:

```bash
# Kill the background process
kill %1 2>/dev/null || true
```

## Done

Report the results:

```
Verification complete: <feature-name>

Results:
  Passed: <count>
  Failed: <count>
  Skipped: <count>

<If any failures:>
Failures:
  - <label>: <brief description of what changed>
  - <label>: <brief description>

Report written to: $DEMO_BASE/verifications/<feature-name>-<date>.md
Demo status updated to: <verified | regression>
```
