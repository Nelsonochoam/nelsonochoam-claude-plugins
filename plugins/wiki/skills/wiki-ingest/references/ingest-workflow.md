# Ingest Workflow

Follow these steps in order when ingesting a source.

## Step 1: Read and Understand the Source

Read the entire source document. Identify:
- **Title**: the source's title or a descriptive name
- **Author**: who wrote it (if known)
- **Date**: when it was published (if known)
- **URL**: original URL (if applicable)
- **Key entities**: people, organizations, products mentioned
- **Key concepts**: ideas, frameworks, technologies, patterns discussed
- **Key takeaways**: 3-5 most important points

## Step 2: Check Existing Pages

Before creating new pages, check what already exists:

```bash
ls "$VAULT/wiki/entities/" 2>/dev/null
ls "$VAULT/wiki/concepts/" 2>/dev/null
ls "$VAULT/wiki/sources/" 2>/dev/null
```

Also read `$VAULT/wiki/index.md` to see the current catalog.

For each entity and concept you identified, check if a page already exists. If it does, you'll update it rather than creating a duplicate.

## Step 3: Create Source Summary Page

Write `$VAULT/wiki/sources/<source-name>.md` using the source page template.

Include:
- Frontmatter with type, dates, author, URL, tags
- 3-5 key takeaways
- Summary (3-5 paragraphs)
- Notable quotes
- Wikilinks to entities mentioned and concepts discussed

## Step 4: Create or Update Entity Pages

For each significant entity (person, organization, product) mentioned in the source:

**If the entity page exists:** Read it, then use `Edit` to:
- Add new facts or timeline entries
- Add a wikilink to the new source in the Sources/Related section
- Update the `updated` date in frontmatter
- Add the new source to the `sources` frontmatter array

**If the entity page doesn't exist:** Create `$VAULT/wiki/entities/<entity-name>.md` using the entity template.

Only create entity pages for significant entities — people/orgs that are central to the source, not every name mentioned in passing.

## Step 5: Create or Update Concept Pages

For each key concept, framework, or technology discussed in the source:

**If the concept page exists:** Read it, then use `Edit` to:
- Add new information, nuances, or examples from the source
- Add a wikilink to the new source
- Update the `updated` date in frontmatter

**If the concept page doesn't exist:** Create `$VAULT/wiki/concepts/<concept-name>.md` using the concept template.

Only create concept pages for concepts that are substantively discussed — not every term mentioned.

## Step 6: Check for Synthesis Opportunities

Ask yourself: does this source connect to existing knowledge in an interesting way?

Look for:
- **Contradictions**: this source disagrees with an existing source
- **Confirmations**: this source provides new evidence for an existing concept
- **Connections**: this source links two previously unrelated concepts
- **Evolutions**: this source shows how a concept has changed over time

If you find a synthesis opportunity, create `$VAULT/wiki/synthesis/<synthesis-name>.md` using the synthesis template.

## Step 7: Cross-Link Existing Pages

For existing pages that should now link to the new content:
- Read the related page
- Add wikilinks to new pages in the Related/Sources section
- Update the `updated` date

This step prevents orphan pages and strengthens the knowledge graph.

## Step 8: Update Index

Read `$VAULT/wiki/index.md` and add entries for all new pages. Each entry should have:
- A wikilink to the page
- A one-line summary

Use `Edit` to add entries under the appropriate category section. Do not rewrite the entire index.

## Step 9: Update Log

Append to `$VAULT/wiki/log.md`:

```markdown
## [YYYY-MM-DD] ingest | <Source Title>

Ingested <source type> by <author>. Created <N> new pages, updated <M> existing pages.

New pages: [[sources/<name>]], [[entities/<name>]], [[concepts/<name>]]
Updated: [[entities/<name>]], [[concepts/<name>]]
```

Use `Edit` to append — do not rewrite the log.
