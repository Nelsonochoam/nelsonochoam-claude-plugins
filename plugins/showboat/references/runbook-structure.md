# Runbook Structure

The runbook is a **graph**, not a document. It has one slim entry point and many focused sub-docs, linked to each other.

The entry point is whatever `.md` file the user configured in `~/.showboat/config.json` as `runbook` — the filename is user-chosen (`runbook.md`, `index.md`, `testing-guide.md`, ...). The `references/` folder always sits alongside it.

## The shape

```
<runbook-dir>/
  <configured>.md       — always loaded; slim index + task→doc routing table
  references/
    environment.md      — load when authenticating or starting the app
    testing.md          — load when running tests, or when unsure how to test something
    browser-tool.md     — load when taking screenshots or interacting with the browser
    pages.md            — load when navigating a specific route
    showboat.md         — load when running verify / authoring demos
    api.md              — load when hitting API endpoints or unsure how to call them
    <other topics>.md
```

Sub-docs can (and should) link to **other sub-docs**. Example: a login-required section in `pages.md` links to the auth-token pattern in `environment.md#obtaining-a-session-token`. Agents traverse the graph by following only the links relevant to their current task.

## Rules for the main index

Keep it slim. The index is always loaded into context, so every line competes for attention.

- **Quick constants**: a short list of values an agent needs before doing anything (base URL, test-account identifier, cwd rules for directory-bound commands).
- **Always-apply standards** (optional): a tight bullet list of rules that should apply to every demo/test run (e.g., QA standards, demo preferences). These live in the index because the agent must read them regardless of which sub-doc it loads next. Keep to ~6 bullets max; anything longer or topic-specific goes in a sub-doc.
- **Task → Reference map**: a table with two columns, `Task` and `Load`. One row per sub-doc. Each row describes a situation the agent might be in, not the content of the doc.
- **No command snippets, no error tables, no patterns, no diffs.** Those live in sub-docs.
- **Pointer to per-feature introspections** if the layout uses them.

Target length for the main index: under ~40 lines. If it grows past that, push content into sub-docs — but never push out the always-apply standards block if one exists.

## Rules for sub-docs (`references/*.md`)

Each sub-doc has one topic and one reason-to-load.

- **First line after the title**: a `Load when: ...` sentence. This is the contract — it tells the agent when to pull this doc in.
- **Single responsibility**: one sub-doc = one topic. If two topics show up in one doc, split them.
- **Cross-link liberally**: when content touches another sub-doc's topic, link to the exact section (use anchors like `browser-tool.md#waiting-for-page-stability`), not to the file top.
- **Headings are anchor points**: write headings that are durable and linkable. Keep them short and specific.
- **Tables for symptom→fix** when the content is a lookup. Prose otherwise.

Target length for sub-docs: under ~80 lines. Past that, split into two sub-docs linked to each other.

## Cross-linking patterns

Prefer specific over general:

- ✅ `see [wait strategies](browser-tool.md#waiting-for-page-stability)`
- ❌ `see [browser-tool.md](browser-tool.md)`

Bidirectional links are fine when both ends add context. But avoid redundant back-and-forth for the same fact — pick the canonical home for the content and link one-way to it from related docs.

## What sub-docs should teach

Sub-docs are not just configuration lookups — they should tell an agent **how to test**, not just what exists. An agent reading `api.md` shouldn't have to figure out auth from first principles; the doc should say "use a service token from X" or "use cookie auth obtained from Y". An agent reading `testing.md` shouldn't guess which suite to run; the doc should say "run only the file closest to the change."

### api.md — endpoints + how to call them

Include for each endpoint (or resource group):
- Method + path
- Auth required: which token type, how to obtain it, which header to set
- Request body shape (real example, not schema)
- What a passing response looks like (status + key fields)
- A ready-to-run `curl` example — copy-paste, not a template

If the API has a common auth pattern shared across endpoints, document it once at the top and cross-link from each endpoint.

### testing.md — test commands + project-specific strategies

Include:
- How to run the full suite, a single file, and a single test
- Which suite is relevant for which part of the codebase
- Any setup required before tests can run (seed data, env vars, services)
- Known slow tests and how to skip them
- When to run the full suite vs. a targeted subset
- Project-specific gotchas (e.g., "tests must run from the `backend/` directory", "flaky test X — retry once before escalating")

### testing.md vs api.md for API testing

`testing.md` covers automated test commands. `api.md` covers live HTTP calls with curl. Both are needed: test commands verify code paths, curl calls verify the running server. Neither replaces the other.

## browser-tool.md — the screenshot and interaction contract

`browser-tool.md` is the one place that describes *how* to drive the browser in this project. The demo skill reads this file before any browser interaction, so the skill itself stays tool-agnostic.

Every `browser-tool.md` must cover these capabilities in tool-specific syntax:

| Capability | What to document |
|---|---|
| **Start session** | How to launch a browser session (or note if stateless/no session) |
| **Navigate** | How to open a URL and wait for it to load |
| **Take a screenshot** | Exact command + output path convention (`/tmp/sb-<name>.png`) |
| **Record video** | How to start/stop recording, output path — or note if unavailable |
| **Interact** | Click, type, select, hover |
| **Wait for stability** | How to wait after navigation or interaction before asserting |
| **Assert** | How to check element existence, text content, or page state |
| **Stop session** | How to close the browser (or note if stateless) |

If a capability is not available for the tool (e.g., no video support), say so explicitly so agents don't waste time looking for a command.

See `plugins/showboat/docs/example-runbooks/` for complete `browser-tool.md` examples for rodney, playwright, and webreel.

## Bootstrapping a new runbook

If the configured index file does not exist yet, create it with this skeleton (the filename is whatever `$RUNBOOK` resolves to):

```markdown
# <Repo> Testing Runbook

Navigation index for LLMs testing this app. Load only the sub-docs you need for the current task — do not read them all upfront.

## Quick constants

- <top-level fact 1>
- <top-level fact 2>

## Task → Reference map

| Task | Load |
|---|---|
| <situation> | [`references/<topic>.md`](references/<topic>.md) |

## When you hit something new

Capture gotchas in the relevant `references/*.md` file (not here). Keep this index slim — it is always loaded; sub-docs are loaded on demand.

Per-feature introspections live under `<per-feature-path>/introspection.md`.
```
