# Demo Document Template

Use this template when assembling a demo document. Fill in all sections from the evidence log and git diff.

---

```markdown
---
date: <YYYY-MM-DD>
feature: <feature-name>
repo: <repo-name>
status: <verified | partial | regression>
tags:
  - showboat/demo
  - showboat/<status>
evidence_count: <number of evidence items>
created_by: agent
---

# Demo: <Feature Title>

## Summary

<!-- 2-3 sentences explaining what was built and why. Derived from git log messages and commit descriptions. -->

<What was built, what problem it solves, and the key user-facing behavior.>

## What Changed

<!-- Auto-generated from git diff --stat. List files with brief descriptions. -->

| File | Change |
|------|--------|
| `<path>` | <brief description of change> |
| `<path>` | <brief description of change> |

## Evidence

<!-- Each subsection corresponds to evidence from the JSONL log.
     Group by type: Tests first, then Screenshots, then API/CLI, then Other.
     Include capture timestamp and duration for traceability. -->

### Tests

<!-- For each command evidence item where the command is a test runner -->

#### <label>

> Captured: <timestamp> | Exit code: <exit_code> | Duration: <duration_ms>ms

```bash
$ <command>
```

```
<stdout, truncated to ~50 lines if very long>
```

<!-- If exit_code != 0, add a warning -->
<!-- > **Warning**: This test exited with code <exit_code>. See stderr below. -->

### Screenshots

<!-- For each screenshot evidence item -->

#### <label>

> Captured: <timestamp>

![<label>](../evidence/assets/<filename>)

<!-- For screenshot_unavailable items -->
<!-- > **Note**: Screenshot not captured — <reason>. The <URL> page should show <description>. -->

### API Verification

<!-- For each http evidence item -->

#### <method> <url path>

> Captured: <timestamp> | Status: <status_code> | Duration: <duration_ms>ms

```bash
$ curl -s <full url> | jq .
```

```json
<response body, pretty-printed>
```

### CLI Verification

<!-- For command evidence items that are not test runners -->

#### <label>

> Captured: <timestamp> | Exit code: <exit_code> | Duration: <duration_ms>ms

```bash
$ <command>
```

```
<stdout>
```

## Verification Checklist

<!-- One checkbox per evidence item. Checked if the evidence shows success. -->

- [x] <label> (`<command>` — exit code <exit_code>)
- [x] <label> (screenshot captured)
- [x] <label> (<method> <url> — <status_code>)
- [ ] <label> — **FAILED**: <reason>

## Verification Commands

<!-- Machine-readable JSON block used by /showboat-verify to re-run all checks.
     Only include re-runnable evidence (commands, HTTP calls, screenshots).
     Do NOT include diff entries or startup_failure entries. -->

```json
[
  {"type": "command", "command": "<command>", "expect_exit": <expected_exit_code>, "label": "<label>"},
  {"type": "http", "method": "<METHOD>", "url": "<url>", "expect_status": <expected_status>, "label": "<label>"},
  {"type": "screenshot", "url": "<url>", "label": "<label>"}
]
```

## Knowledge Used

<!-- If wiki or learnings were consulted during this demo, list what informed the testing approach.
     This creates traceability: you can see WHY the demo tested things a certain way. -->

<!-- Example entries: -->
<!-- - [[concepts/auth-testing-patterns]] — informed login-before-screenshot approach -->
<!-- - [[concepts/my-app-testing-knowledge]] — provided correct API base path -->
<!-- - [[learnings/2026-04-18-introspect]] — corrected /dashboard route -->

## Links

<!-- Obsidian wikilinks for navigation -->

- Testing Context: [[testing-context]]
- Demo Index: [[demos/index]]
- Learnings: [[learnings/index]]
<!-- If knowledge index pages were relevant, list them -->
```

## Assembly Rules

1. **Group evidence by type**, not by capture order. Tests first, then screenshots, then API, then CLI.
2. **Use the most recent evidence** for each label. If the same test was captured twice, use the later one.
3. **Truncate long output** to ~50 lines with a note: `<... truncated, full output in evidence log>`
4. **Pretty-print JSON** responses for readability.
5. **Mark failed checks** in the checklist with unchecked boxes and a reason.
6. **The status field** in frontmatter:
   - `verified` — all checklist items pass
   - `partial` — no testing context, or some evidence types missing (e.g., no screenshots)
   - `regression` — some checks failed (set by `/showboat-verify` on re-verification)
7. **evidence_count** — total number of evidence items included in this demo.
