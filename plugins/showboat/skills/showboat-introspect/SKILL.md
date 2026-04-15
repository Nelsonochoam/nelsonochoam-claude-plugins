---
name: showboat-introspect
description: Extract learnings from failed verifications, user corrections, and testing sessions. Writes structured learnings that the wiki can digest to improve future testing.
argument-hint: '<optional: feature-name to scope introspection>'
model: opus
---

User's request: $ARGUMENTS

# Introspect

You are extracting lessons from testing failures, user corrections, and verification gaps. The output is a structured learnings document that:

1. Records what went wrong and why
2. Captures corrections the user provided (routes, selectors, auth flows, timing, etc.)
3. Feeds back into the testing context so future demos work better
4. Can be ingested by the wiki plugin to build long-term testing knowledge

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved base directory as `$DEMO_BASE`.

## Ensure Learnings Directory

```bash
mkdir -p "$DEMO_BASE/learnings"
```

## Gather Sources of Failure and Correction

First, check if there are any sources to introspect. If all of the following are empty, stop early — there's nothing to learn from:

```bash
ls "$DEMO_BASE/evidence/"*.jsonl 2>/dev/null | head -1 || echo "NO_EVIDENCE"
ls "$DEMO_BASE/verifications/"*.md 2>/dev/null | head -1 || echo "NO_VERIFICATIONS"
grep -l 'status: partial\|status: regression' "$DEMO_BASE/demos/"*.md 2>/dev/null | head -1 || echo "NO_FAILED_DEMOS"
```

If all three are empty AND the user hasn't provided corrections in the conversation, say "Nothing to introspect — no failures or corrections found." and stop.

Otherwise, only now read `${CLAUDE_SKILL_DIR}/references/introspection-sources.md` for detailed guidance on each source.

Collect learnings from all available sources:

### 1. Evidence Logs — Find Failures

Scan all evidence files for failures:

```bash
ls "$DEMO_BASE/evidence/"*.jsonl 2>/dev/null
```

For each evidence file, extract entries where:
- `exit_code` is non-zero (command failures)
- `type` is `screenshot_unavailable` or `startup_failure`
- `status` is 4xx or 5xx (HTTP failures)

If `$ARGUMENTS` contains a feature name, scope to that feature's evidence file only.

### 2. Verification Reports — Find Regressions

```bash
ls "$DEMO_BASE/verifications/"*.md 2>/dev/null
```

Read each verification report. Extract every `FAIL` and `SKIP` result, including:
- What was expected vs. what happened
- The possible cause noted in the report

### 3. Demo Documents — Find Partial Demos

```bash
grep -l 'status: partial\|status: regression' "$DEMO_BASE/demos/"*.md 2>/dev/null
```

Read these demos. Note which evidence types are missing or failed.

### 4. Current Conversation — Capture User Corrections

This is the most valuable source. Review the current conversation for:
- **Navigation corrections**: "that page is at /settings/profile not /settings"
- **Auth/flow corrections**: "you need to log in first", "use the admin account"
- **Timing corrections**: "wait for the spinner to finish", "the server takes 10s to start"
- **Selector corrections**: "click the .submit-btn not the #save button"
- **Data corrections**: "use the test user test@example.com", "seed data with npm run db:seed first"
- **Environment corrections**: "you need to set API_KEY=xxx first", "run on port 8080 not 3000"
- **Workflow corrections**: "run migrations before starting the server"
- **Capability corrections**: "use rodney to interact with the dropdown, not just screenshot it"

If no corrections are found in the conversation, use `AskUserQuestion`:

> I'm extracting learnings from this testing session. What corrections or tips would you like me to record?
>
> Examples:
> - "The dashboard requires auth — log in at /login with test@example.com first"
> - "The search page is at /users?tab=search not /search"
> - "Wait 5 seconds after npm run dev before hitting the API"

Options: `I have corrections to share` / `Just analyze the failures, no additional input`

### 5. Testing Context — Find Gaps

```bash
cat "$DEMO_BASE/testing-context.md" 2>/dev/null || echo "NOT_FOUND"
```

Compare what the testing context says against what actually happened in the evidence. Look for:
- Routes listed in context that returned 404s in evidence
- Dev server commands that resulted in startup failures
- Test commands that don't exist or have changed
- Missing pages/endpoints that were needed during demos

## Deduplicate Against Knowledge Index (optional)

If a knowledge index is configured, check whether it already covers these learnings:

```bash
KNOWLEDGE_INDEX=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-knowledge-index.sh" 2>/dev/null) || true
echo "${KNOWLEDGE_INDEX:-NO_KNOWLEDGE_INDEX}"
```

**If NO_KNOWLEDGE_INDEX** — skip deduplication entirely. All learnings are treated as `new`.

**If a knowledge index exists**, read it and follow links to find existing testing knowledge. For each learning you collected, check if the knowledge base already documents it:
- If it already says "auth required on /admin routes" and you just learned the same thing → mark the learning as `already_known` and skip it
- If it has partial knowledge that this learning expands → mark it as `update`
- If the learning is genuinely new → mark it as `new`

Only include `new` and `update` learnings in the output document. Mention `already_known` items in the summary to confirm existing knowledge is accurate.

## Classify Learnings

Read `${CLAUDE_SKILL_DIR}/references/learning-types.md` for the classification taxonomy.

Classify each learning into one of these categories:
- **navigation** — correct routes, page locations, URL patterns
- **auth** — authentication flows, credentials, session requirements
- **timing** — wait conditions, server startup, async operations
- **interaction** — CSS selectors, click targets, form inputs, browser automation steps
- **data** — test data, seed commands, expected values, fixtures
- **environment** — env vars, ports, prerequisites, setup steps
- **workflow** — ordering of operations, dependencies between steps
- **tooling** — which tools work, which don't, workarounds

## Write Learnings Document

Write the learnings to `$DEMO_BASE/learnings/<date>-introspect.md` (or `$DEMO_BASE/learnings/<date>-<feature>-introspect.md` if scoped to a feature).

Read the template at `${CLAUDE_SKILL_DIR}/references/learnings-template.md`.

The document must be structured so that `/wiki-ingest` can process it:
- Obsidian frontmatter with type, date, repo, tags
- Each learning is a self-contained section with category, what happened, what was learned, and the concrete fix
- Wikilinks to related demos, verification reports, and testing context

## Update Testing Context

For each learning that reveals a gap in the testing context, **update `testing-context.md` directly**:

- Wrong route → fix the route in Pages & Routes
- Missing auth step → add it to the page's verification criteria
- Wrong dev server command → fix it in Environment Setup
- New verification pattern → add to Common Verification Patterns
- New feature-specific knowledge → add to Feature-Specific Testing

Use `Edit` to make targeted changes. Do not rewrite the file.

This is the direct feedback loop — introspect fixes the testing playbook so the next `/showboat-demo` gets it right.

## Append to Learnings Index

Check if `$DEMO_BASE/learnings/index.md` exists:
- **If yes:** add the new learnings document to the index
- **If no:** create it:

```markdown
---
tags:
  - showboat/learnings
  - MOC
---

# Learnings Index: <repo-name>

Accumulated testing knowledge from introspection sessions.

```dataview
TABLE date, feature, categories
FROM "showboat/<repo>/learnings"
WHERE contains(tags, "showboat/learning")
SORT date DESC
```

## Recent

| Learnings | Date | Feature | Categories |
|-----------|------|---------|------------|
| [[<filename>]] | <date> | <feature or "general"> | <categories> |
```

## Suggest Knowledge Base Ingestion

After writing learnings, suggest adding them to a knowledge base if available:

```
Learnings written to: $DEMO_BASE/learnings/<filename>.md
Testing context updated with <N> corrections.

To add these learnings to a knowledge base (e.g., via the wiki plugin):
  /wiki-ingest $DEMO_BASE/learnings/<filename>.md

Or manually add a link to this file from your knowledge index so
showboat can reference it in future testing sessions.
```

## Done

Report:

```
Introspection complete.

Learnings extracted: <count>
  - <N> from evidence failures
  - <N> from verification regressions
  - <N> from user corrections
  - <N> from testing context gaps

Categories:
  - navigation: <count>
  - auth: <count>
  - timing: <count>
  - interaction: <count>
  - data: <count>
  - environment: <count>
  - workflow: <count>
  - tooling: <count>

Written to: $DEMO_BASE/learnings/<filename>.md
Testing context updated: <N> corrections applied

<wiki suggestion if applicable>
```
