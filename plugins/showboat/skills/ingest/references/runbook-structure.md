# Runbook Structure

The runbook is a **graph**, not a document. It has one slim entry point and many focused sub-docs, linked to each other.

The entry point is whatever `.md` file the user configured in `~/.showboat/config.json` as `runbook` — the filename is user-chosen (`runbook.md`, `index.md`, `testing-guide.md`, ...). The `references/` folder always sits alongside it.

## The shape

```
<runbook-dir>/
  <configured>.md       — always loaded; slim index + task→doc routing table
  references/
    environment.md      — load when authenticating or starting the app
    testing.md          — load when running tests or type-checks
    rodney-patterns.md  — load when interacting with the browser
    pages.md            — load when navigating a specific route
    showboat.md         — load when running verify / authoring demos
    api-admin.md        — load when hitting admin APIs
    <other topics>.md
```

Sub-docs can (and should) link to **other sub-docs**. Example: a drawer-navigation section in `pages.md` links to the anchor-selector pattern in `rodney-patterns.md#anchors--special-char-aria-labels`. Agents traverse the graph by following only the links relevant to their current task.

## Rules for the main index

Keep it slim. The index is always loaded into context, so every line competes for attention.

- **Quick constants**: a short list of values an agent needs before doing anything (test org ID, base URL, cwd rules for directory-bound commands).
- **Always-apply standards** (optional): a tight bullet list of rules that should apply to every demo/test run (e.g., QA standards, demo preferences). These live in the index because the agent must read them regardless of which sub-doc it loads next. Keep to ~6 bullets max; anything longer or topic-specific goes in a sub-doc.
- **Task → Reference map**: a table with two columns, `Task` and `Load`. One row per sub-doc. Each row describes a situation the agent might be in, not the content of the doc.
- **No command snippets, no error tables, no patterns, no diffs.** Those live in sub-docs.
- **Pointer to per-feature introspections** if the layout uses them.

Target length for the main index: under ~40 lines. If it grows past that, push content into sub-docs — but never push out the always-apply standards block if one exists.

## Rules for sub-docs (`references/*.md`)

Each sub-doc has one topic and one reason-to-load.

- **First line after the title**: a `Load when: ...` sentence. This is the contract — it tells the agent when to pull this doc in.
- **Single responsibility**: one sub-doc = one topic. If two topics show up in one doc, split them.
- **Cross-link liberally**: when content touches another sub-doc's topic, link to the exact section (use anchors like `rodney-patterns.md#anchors--special-char-aria-labels`), not to the file top.
- **Headings are anchor points**: write headings that are durable and linkable. Keep them short and specific.
- **Tables for symptom→fix** when the content is a lookup. Prose otherwise.

Target length for sub-docs: under ~80 lines. Past that, split into two sub-docs linked to each other.

## Cross-linking patterns

Prefer specific over general:

- ✅ `see [anchor patterns](rodney-patterns.md#anchors--special-char-aria-labels)`
- ❌ `see [rodney-patterns.md](rodney-patterns.md)`

Bidirectional links are fine when both ends add context. But avoid redundant back-and-forth for the same fact — pick the canonical home for the content and link one-way to it from related docs.

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
