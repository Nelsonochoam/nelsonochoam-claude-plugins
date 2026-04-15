---
name: wiki-ingest
description: Ingest a source document into the wiki — read it, create/update wiki pages (entities, concepts, sources), update index and log.
argument-hint: '<path to source file, URL, or topic to research>'
model: opus
---

User's request: $ARGUMENTS

# Ingest Source

You are ingesting a source document into the wiki knowledge base. This is the core operation — a single source may touch 10-15 wiki pages as you extract entities, concepts, and connections.

## Vault Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/vault-discovery.md`.

Store the resolved vault path as `$VAULT`.

## Read Schema

If `$VAULT/CLAUDE.md` exists, read it. It defines vault-specific conventions that override defaults. Follow the schema's rules for everything below.

If no schema exists, follow the default conventions in `${CLAUDE_PLUGIN_ROOT}/references/page-conventions.md`.

## Parse the Source

The user provides one of:
- **A file path** — read the file directly
- **A URL** — fetch the content using `WebFetch`
- **A topic/text** — treat the argument text as the source content itself

### For files:

Read the file. If it's in a supported format (markdown, text, PDF), process it directly.

Copy the raw source to `$VAULT/raw/`:
- Articles/blog posts → `$VAULT/raw/articles/<kebab-case-name>.md`
- Research papers → `$VAULT/raw/papers/<kebab-case-name>.md`
- Images/assets → `$VAULT/raw/assets/<original-name>`

### For URLs:

Use `WebFetch` to retrieve the content. Save the markdown output to `$VAULT/raw/articles/<kebab-case-name>.md`.

### For topics/text:

No raw file to save. Create pages directly from the provided content.

## Detect Showboat Learnings Files

Check if the source is a showboat learnings file (has `type: learnings` in frontmatter or lives in a `learnings/` directory):

```bash
head -10 "<source-file>" | grep -q "type: learnings" && echo "SHOWBOAT_LEARNINGS" || echo "REGULAR_SOURCE"
```

**If this is a showboat learnings file**, follow this specialized ingest path instead of the generic workflow:

1. **Parse the structured learnings** — each `### N. <description>` section is a self-contained learning with Category, What happened, What was wrong, Correct approach, and Source fields.

2. **Create/update testing pattern concept pages** — for each learning category that appears (navigation, auth, timing, interaction, data, environment, workflow, tooling):
   - Check if `wiki/concepts/<category>-testing-patterns.md` exists
   - If yes, append the new learning to the page
   - If no, create it as a concept page with examples from this learnings file
   - Example: `wiki/concepts/auth-testing-patterns.md` accumulates all auth-related learnings across repos

3. **Create repo-specific concept pages** — if multiple learnings relate to the same repo or feature:
   - Create `wiki/concepts/<repo-name>-testing-knowledge.md` with environment, auth, and workflow knowledge specific to that repo
   - This page becomes the go-to reference for testing that repo

4. **Extract the Patterns section** — if the learnings file has a `## Patterns` section, each pattern is a synthesis opportunity. Create `wiki/synthesis/<pattern-name>.md` pages.

5. **Link back to showboat artifacts** — use wikilinks to the original demos and verification reports cited in the learnings (from `source_demos` and `source_verifications` frontmatter).

6. **Update the index and log** as normal (see below).

After processing a learnings file, continue to the "Key Rules" section — skip the generic ingest workflow.

**If this is NOT a showboat learnings file**, proceed with the generic workflow below. Only now read these reference files — skip them entirely for learnings files:

## Read Ingest Workflow

Read `${CLAUDE_SKILL_DIR}/references/ingest-workflow.md` for the detailed step-by-step process.

## Read Page Templates

Read `${CLAUDE_SKILL_DIR}/references/page-templates.md` for the templates to use when creating pages.

## Key Rules

1. **Raw sources are immutable** — never modify files in `raw/`. Always create new files.
2. **Update, don't duplicate** — if an entity or concept page already exists, update it with new information rather than creating a duplicate.
3. **Every page must link** — every new page must have at least one outbound wikilink. Add inbound links from related existing pages.
4. **Update the index** — add every new page to `wiki/index.md`.
5. **Log the operation** — append to `wiki/log.md`.
6. **Check for synthesis opportunities** — if the new source connects to existing knowledge in interesting ways, create a synthesis page.

## Done

After ingesting, report:

```
Ingested: <source title>

Pages created/updated:
  Sources:   <list>
  Entities:  <list>
  Concepts:  <list>
  Synthesis: <list if any>

Index updated. Log entry added.

Total wiki pages: <count>
```

Count pages with:
```bash
find "$VAULT/wiki" -name "*.md" ! -name "index.md" ! -name "log.md" | wc -l
```
