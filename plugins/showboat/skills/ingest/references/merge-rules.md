# Merge Rules

How to turn introspection entries into graph updates without bloating the runbook.

## Category → sub-doc mapping

The introspection categorizes each entry with a tag like `[interaction]` or `[environment]`. Map the tag to a sub-doc:

| Introspection tag | Default sub-doc | What belongs here |
|---|---|---|
| `environment` | `references/environment.md` | Login, auth, secret-manager setup, required cwd, env vars, service health |
| `auth` | `references/environment.md` | Login flows, token injection, session cookies |
| `commands` | `references/testing.md` | Test commands, type-check, build, path conventions |
| `interaction` | `references/rodney-patterns.md` | Clicks, typing, selectors, DOM manipulation |
| `navigation` | `references/pages.md` | Routes, modal/dialog flows, per-page specifics |
| `timing` | `references/rodney-patterns.md` | Wait strategies, race conditions, stability checks |
| `data` | `references/pages.md` or `references/environment.md` | Feature flags, seed data, account state (pick based on where the agent hits it) |
| `workflow` | `references/showboat.md` | Demo authoring, verify limitations, session state |

If a category does not map to any existing sub-doc, create a new one. Pick a name that describes the topic, not the feature.

## Deduplication

Before adding any content, check:

1. **Exact duplicate** — same fact already written somewhere in the graph → skip.
2. **Weaker restatement** — existing content says the same thing but less clearly → tighten the existing text; do not add a second copy.
3. **Stronger restatement** — new entry explains the same fact better → replace the old text; do not leave both.
4. **Orthogonal but related** — new entry adds a new angle on an existing topic → add it as a new bullet / row / section under the same heading, and consider linking to the related existing content.

Search for duplicates by keyword (command name, error text, symptom). Do not trust your memory of what you just read — grep the graph.

## Section placement inside a sub-doc

When a sub-doc exists and you know the new content belongs in it, pick the placement:

- **Symptom/error lookup** → add a row to the `Symptom → Fix` table if one exists. If the fix is long, add a row that links to a new subsection below the table.
- **Command or pattern** → add a new subsection under the relevant heading. Use a level-2 heading (`##`) unless the doc already uses level-3 for similar items.
- **Critical rule / gotcha** → add to the "Critical rules" bullet list at the top of the doc. If no such list exists and the rule is load-bearing, create one.
- **Everything else** → append under the most specific existing heading. Avoid creating new headings unless the content is clearly its own topic.

## Cross-linking

When writing a new entry, ask: *does this touch another sub-doc's topic?* If yes, link.

Link to the specific section using an anchor, not the file. GitHub/Obsidian anchors are lowercased headings with spaces replaced by `-` and special chars stripped. For example, a heading `## Waiting for network idle` has the anchor `#waiting-for-network-idle`.

Examples:

- New `pages.md` section describes a login-gated route → link to `environment.md#obtaining-a-session-token`.
- New `showboat.md` note about flag-gated branches → link to `testing.md#when-to-rely-on-tests-vs-browser`.

Prefer one canonical home for content, with one-way links from related docs.

## When to create a new sub-doc

Create a new sub-doc when:

- The introspection introduces a topic that does not fit any existing sub-doc, **and**
- The topic is general enough that it will come up again (not tied to one feature).

Do not create a sub-doc for one-off observations. If content is too feature-specific to generalize, skip it — that's what per-feature `introspection.md` files are for.

When creating a new sub-doc:

1. Write the file in `references/<topic>.md` with a `Load when: ...` header on line 2.
2. Add a row to the task→doc table in the main index file (at `$RUNBOOK`).
3. Add cross-links from/to related existing sub-docs.

## What to skip entirely

- Per-feature details (selector IDs, UUIDs, screenshot filenames) that won't recur.
- Observations specific to one branch of the codebase.
- Restatements of content already in the graph.
- "Lessons" that reduce to "read the docs" or "follow the runbook" — not actionable.
