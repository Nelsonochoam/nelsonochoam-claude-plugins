# Introspection Sources

Where to find failures, corrections, and gaps to extract learnings from.

## Source Priority

Process these in order. Earlier sources are more concrete; later sources require more judgment.

### 1. Evidence Logs (most concrete)

Location: `$DEMO_BASE/evidence/*.jsonl`

What to look for:
- `exit_code != 0` on command evidence — a test, build, or script failed
- `type: "screenshot_unavailable"` — couldn't take a screenshot (tool issue)
- `type: "startup_failure"` — dev server or service didn't start
- `status >= 400` on HTTP evidence — API returned an error
- Empty `stdout` on commands that should produce output — command may be wrong

For each failure, note:
- What was attempted (the command, URL, or action)
- What went wrong (exit code, error message, HTTP status)
- Whether this was a one-off failure or a pattern

### 2. Verification Reports

Location: `$DEMO_BASE/verifications/*.md`

What to look for:
- Sections marked `FAIL` — something that previously worked now doesn't
- Sections marked `SKIP` — couldn't be verified (missing capability)
- The "Possible cause" and "Recommendations" sections
- Differences between expected and actual output

Regressions are especially valuable learnings — they reveal what changes break things.

### 3. Demo Documents

Location: `$DEMO_BASE/demos/*.md`

What to look for:
- `status: partial` in frontmatter — demo was incomplete
- `status: regression` — verified and found broken
- Unchecked items in the Verification Checklist
- `screenshot_unavailable` placeholders in the Evidence section
- Missing evidence sections (e.g., no API verification for an API change)

### 4. Conversation Context (most valuable)

The current conversation may contain corrections the user made in real time. These are the highest-value learnings because they represent tacit knowledge that isn't captured anywhere else.

Look for messages where the user:
- Corrected a URL, route, or path
- Explained an auth or login requirement
- Told the agent to wait or retry
- Provided a CSS selector or click target
- Shared test credentials or seed data
- Explained environment setup steps
- Corrected the order of operations
- Suggested a different tool or approach

If there's nothing obvious in the conversation, ask the user.

### 5. Testing Context Gaps

Location: `$DEMO_BASE/testing-context.md`

Compare the testing context against what happened in the evidence:
- Routes in the context that returned 404 in evidence → route is wrong
- Dev server command that caused a startup failure → command changed
- Test commands that returned "command not found" → script renamed or removed
- Pages not in the context that were needed during demos → missing coverage
- Endpoints not in the context that were called → missing API documentation

## What to Skip

Not everything is a learning. Skip:
- **Transient failures**: network timeouts, flaky tests that pass on retry
- **Expected failures**: tests that are supposed to fail (negative test cases)
- **Known limitations**: documented issues, planned work
- **Agent mistakes unrelated to testing**: typos in code, wrong variable names

Focus on learnings that would help **future testing sessions succeed where this one struggled**.
