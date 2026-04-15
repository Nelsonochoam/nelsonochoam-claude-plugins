---
name: demo
description: Assemble a demo document from captured evidence — proves that a feature works with real command outputs, screenshots, and test results.
argument-hint: '<feature-name>'
model: opus
---

User's request: $ARGUMENTS

# Assemble Demo

You are creating a demo document that proves a feature works. This document combines real evidence (command outputs, screenshots, HTTP responses) with a narrative explaining what was built and how it was verified.

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved base directory as `$DEMO_BASE`.

## Parse Arguments

Extract the feature name from `$ARGUMENTS` (e.g., `add-user-search`). If missing, use `AskUserQuestion` to ask for it.

Ensure directories exist:

```bash
DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "<feature-name>")
```

## Read Testing Context

```bash
cat "$DEMO_BASE/testing-context.md" 2>/dev/null || echo "NOT_FOUND"
```

**If NOT found:** Warn the user:

> No testing context found for this repo. I can proceed with a partial demo using git diff and any evidence you've captured, but the demo will be marked as `partial`.
>
> Run `/showboat:context` first for a more complete demo.

Use `AskUserQuestion` to offer: `Proceed with partial demo` / `Run /showboat:context first`

If proceeding without context, set `status: partial` in the demo frontmatter.

**If found:** Read it and extract:
- App type, dev server command, URL, ready signal
- Relevant test commands
- Pages/routes related to the feature
- API endpoints related to the feature
- Common verification patterns

## Read Existing Evidence

```bash
cat "$DEMO_BASE/evidence/<feature-name>.jsonl" 2>/dev/null || echo "NO_EVIDENCE"
```

Parse the JSONL into a list of evidence items. For duplicate labels, keep only the most recent entry.

## Understand What Changed

Run these to understand the scope of changes:

```bash
git diff --stat HEAD~1
git log --oneline -5
```

<!-- If using crispy, intent docs may exist at $DEMO_BASE/../<feature>/1-intent.md -->

## Consult Prior Learnings and Wiki

Before capturing evidence, check what we already know about testing this repo and feature. This prevents repeating past mistakes.

### Read Learnings History

```bash
cat "$DEMO_BASE/learnings/index.md" 2>/dev/null || echo "NO_LEARNINGS"
```

If learnings exist, read the most recent learnings file(s). Extract any corrections that apply to this feature or the repo in general:
- Navigation corrections (correct routes, URL patterns)
- Auth requirements (login steps, credentials, tokens)
- Timing issues (wait conditions, startup delays)
- Interaction patterns (selectors, click sequences for Rodney)
- Data prerequisites (seed commands, fixtures)
- Environment requirements (env vars, services to start)

Apply these corrections when auto-capturing evidence below. For example, if learnings say "dashboard requires auth — log in at /auth/login first," then start a Rodney session, navigate to login, authenticate, THEN screenshot the dashboard.

### Query Knowledge Index (optional)

Check if a knowledge index is configured:

```bash
KNOWLEDGE_INDEX=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-knowledge-index.sh" 2>/dev/null) || true
echo "${KNOWLEDGE_INDEX:-NO_KNOWLEDGE_INDEX}"
```

**If NO_KNOWLEDGE_INDEX** — skip this section entirely. The knowledge index is optional. Showboat works fine with just the testing context and learnings history.

**If a knowledge index exists**, read it. The index is an entry point to testing knowledge — it may contain links to other files, patterns, runbooks, or wiki pages. Follow its links progressively:

1. Read the index file itself
2. Scan for links or references related to this feature, app type, or testing patterns
3. Read only the linked files that seem relevant (do not read everything — load progressively)

Look for:
- Known testing patterns for this type of feature
- Environment or auth knowledge
- Known pitfalls or timing issues

Incorporate this knowledge into your testing approach. For example, if the knowledge index says "search index updates are async — wait 2 seconds after writes," follow that when capturing search screenshots.

### Use Inline Details from User

If `$ARGUMENTS` contains testing details beyond just the feature name (e.g., `/showboat:demo add-search "app runs on port 8080, login at /auth with admin@test.com"`), use those details directly. Inline details take highest priority — they override testing context, learnings, and wiki.

### Merge Knowledge

Combine what you learned from (in priority order — highest first):
1. Inline details from user arguments (if provided)
2. Learnings history (past corrections)
3. Testing context (the playbook)
4. Knowledge index (accumulated knowledge, if configured)

Use this merged understanding to inform all evidence capture below. When there's a conflict, prefer the higher-priority source.

## Auto-Capture Missing Evidence

If the evidence log is sparse (fewer than 3 items) and a testing context exists, automatically capture critical evidence.

Only now read `${CLAUDE_PLUGIN_ROOT}/references/evidence-guidelines.md` — skip this if evidence is already sufficient.

At minimum, capture:

1. **Test suite results** (if test commands exist in the context):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/capture-command.sh" "<test-command>" "Test suite" "$DEMO_BASE/evidence/<feature>.jsonl"
   ```

2. **Build verification** (if build command exists):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/capture-command.sh" "<build-command>" "Build succeeds" "$DEMO_BASE/evidence/<feature>.jsonl"
   ```

3. **Lint/type check** (if commands exist):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/capture-command.sh" "<lint-command>" "Lint passes" "$DEMO_BASE/evidence/<feature>.jsonl"
   ```

4. **Screenshots** of affected pages (if the app is a web-app and browser tools are available):
   - Check capabilities: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-capabilities.sh"`
   - If the dev server needs to be started, start it and wait for the ready signal
   - If **Rodney** is available, start a browser session and reuse it for all screenshots:
     ```bash
     rodney start
     rodney open "<url>"
     rodney screenshot "$DEMO_BASE/evidence/assets/<name>.png"
     # Navigate to each page, capture each screenshot
     rodney open "<next-url>"
     rodney screenshot "$DEMO_BASE/evidence/assets/<name>.png"
     # Use rodney click/js for interactive elements before capturing
     rodney stop   # stop the session when all screenshots are done
     ```
   - If Rodney is not available, fall back to shot-scraper or Chrome headless (one-shot per page)
   - For each page related to the feature, attempt a screenshot

5. **API responses** for affected endpoints:
   - Use curl to hit each relevant endpoint
   - Capture response status and body

## Link Knowledge Sources in Demo

If you found relevant pages via the knowledge index during "Consult Prior Learnings and Wiki," link them in the demo document's Links and "Knowledge Used" sections. Use `[[wikilinks]]` for files in the same vault, or relative paths otherwise.

## Assemble the Demo Document

Read the template at `${CLAUDE_SKILL_DIR}/references/demo-template.md` and assemble the document.

**Key rules:**
- Every piece of evidence in the JSONL is included in the document
- Command evidence: show the command and output in code blocks
- Screenshot evidence: embed as `![label](../evidence/assets/<filename>)`
- HTTP evidence: show curl command and response
- `screenshot_unavailable` entries: render as a placeholder note
- `startup_failure` entries: render as a warning
- The Verification Commands JSON block at the bottom must contain only re-runnable commands
- All wikilinks, frontmatter, and tags follow Obsidian conventions

Write the demo to: `$DEMO_BASE/demos/<feature-name>.md`

## Update the Demo Index

Read the index template at `${CLAUDE_SKILL_DIR}/references/index-template.md`.

Check if `$DEMO_BASE/demos/index.md` exists:
- **If yes:** Add the new demo to the existing index (use `Edit`, don't rewrite)
- **If no:** Create the index from the template

## Update Testing Context (Feature-Specific Section)

If `testing-context.md` exists, append a new entry to the "Feature-Specific Testing" section:

```markdown
### <Feature Name> (added <YYYY-MM-DD>)
- **Route/Command**: <primary route or command>
- **Verification**: <brief description>
- **Related demo**: [[demos/<feature-name>]]
```

Use `Edit` to append — do not rewrite the file.

## Done

After writing, say:

```
Demo written: $DEMO_BASE/demos/<feature-name>.md

Evidence included:
  - <count> command outputs
  - <count> screenshots
  - <count> HTTP responses
  - Status: <verified | partial>

Open in Obsidian to see the full demo with embedded images and wikilinks.

Run /showboat:verify <feature-name> to re-run all verification steps and check for regressions.
```
