---
name: ingest
description: Take an introspection file and incorporate its learnings into the testing runbook — merging into a graph of cross-linked reference docs that agents can progressively load.
argument-hint: '<optional: path to introspection file>'
model: opus
---

User's request: $ARGUMENTS

# Ingest: Merge Learnings Into the Runbook

You are taking learnings from an introspection document and incorporating them into the shared testing runbook. The runbook is a **graph of reference documents** — a slim index at the top, focused sub-docs in `references/`, cross-linked to each other. The core principle is **progressive loading**: the main file is always loaded, but sub-docs are only read when relevant to the current task.

Your job is to generalize per-feature learnings into the shared graph without bloating the index or duplicating existing knowledge.

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved base directory as `$DEMO_BASE`.

## Resolve Inputs

Parse `$ARGUMENTS` for an explicit introspection path (may be empty), then run:

```bash
DEMO_BASE="$DEMO_BASE" bash "${CLAUDE_SKILL_DIR}/scripts/resolve-ingest-inputs.sh" "$ARG_PATH"
```

Prints three key=value lines: `INTROSPECTION_FILE`, `RUNBOOK`, `REFS_DIR`. Hard-exits if the introspection file is missing. `RUNBOOK` and `REFS_DIR` may be empty — the runbook is optional in showboat's init and not every user configures one.

### If `RUNBOOK` is empty

No runbook is configured. Use `AskUserQuestion` to ask the user where to put it:

> Showboat has no runbook configured. Where should the main index file live?
>
> The runbook is an entry point that agents load before each demo. Keep it slim — sub-docs go in a `references/` folder alongside it. The file can be named anything (`runbook.md`, `index.md`, `testing-guide.md`, etc.).
>
> Provide the full absolute path to a `.md` file.

Persist the answer and get the final paths:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/set-runbook.sh" "<user-provided-path>"
```

That script writes the path into `~/.showboat/config.json`, creates the `references/` directory alongside it, and prints the resolved `RUNBOOK` and `REFS_DIR`.

### If the configured runbook file does not exist on disk

Treat this as bootstrapping — create it using the skeleton in [`runbook-structure.md`](references/runbook-structure.md). The filename is whatever the user configured; the file's role is the slim top-level index.

## Understand the Current Graph

Read the file at `$RUNBOOK` (the main index, whatever filename the user configured) and every file under `$REFS_DIR/`. You must hold the whole graph in working memory to:

- Know which sub-doc a new learning belongs in
- Detect duplicates (do not add a learning that restates existing content)
- Add cross-links when a new entry in doc A relates to existing content in doc B

Read [`references/runbook-structure.md`](references/runbook-structure.md) for the canonical shape of the graph and the rules that keep the main index slim.

## Categorize Learnings

Read the introspection file in full. For each entry under `Stuck Points`, `Corrections`, and `Runbook Tips`, classify it by topic. Topics map 1:1 to sub-docs in `references/`.

Read [`references/merge-rules.md`](references/merge-rules.md) for:
- The category → sub-doc mapping
- Deduplication rules
- Section placement heuristics
- Cross-linking patterns

## Merge Per Learning

Apply these rules (detailed in `merge-rules.md`):

1. **Matching sub-doc exists** → merge under the most relevant heading. If the learning restates existing content, skip it or tighten the existing text instead of duplicating.
2. **No matching sub-doc** → create `$REFS_DIR/<topic>.md` with a `Load when:` header, write the content, and register a row in the main index's task→doc table.
3. **Cross-link aggressively** → when a new entry in doc A naturally touches doc B, link to the specific section in B (e.g., `references/b.md#anchor`). Links are the edges of the graph.
4. **Too feature-specific to generalize** → skip and list it in the report. Keep the shared runbook general.

## Update the Main Index (only if needed)

The file at `$RUNBOOK` (the main index) should change **only** when:

- A new reference document was created → add it to the task→doc table
- A top-level constant (test org ID, base URL, cwd rule) was corrected

Do not push content into the main index. Details belong in sub-docs. The index exists to route agents to the right sub-doc.

## Report

Print a concise summary:

```
Ingested: <introspection-file>
Runbook: <runbook-path>

Updated:
  - references/<topic>.md — <what was added, one line>
  - ...

Created:
  - references/<topic>.md — <what it covers, one line>
  - ...

Skipped (duplicates or too feature-specific):
  - <brief description>
  - ...

Index changes: <none | "added <topic> row" | "fixed <constant>">
```
