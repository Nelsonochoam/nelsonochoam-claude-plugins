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

## Step 2: Discuss with the User

**Do not start writing wiki pages yet.** Surface what you found and ask the user what to focus on.

Present a brief read-out:

> **[Source Title]** by [Author], [Date]
>
> Key takeaways I found:
> 1. ...
> 2. ...
> 3. ...
>
> Entities I'd create pages for: [list]
> Concepts I'd create pages for: [list]
>
> What do you want to emphasize? Anything to skip or go deeper on?

Wait for the user's response. They may:
- Say "looks good, proceed" — ingest with your current read
- Redirect emphasis ("focus more on X, skip Y")
- Add context you didn't have ("this contradicts what we read last week about Z")
- Ask you to pull a specific quote or section into the summary

Incorporate their guidance before writing anything. This is the step that makes the wiki reflect what *the user* cares about, not just what the document contains.

## Step 3: Check Existing Pages

Read `$VAULT/wiki/index.md` once. It is a flat catalog — every page in the wiki listed with a wikilink and a one-line summary. Use it as your lookup table for the rest of this ingest.

Do not scan wiki folders with `ls` or `find`, and do not read individual pages at this stage. The index tells you what exists; you open individual pages only when you are about to update them (Steps 5–8).

For each entity and concept from Step 1, scan the index:
- **Found** → mark it for update; you'll read and edit it in the relevant step below
- **Not found** → mark it for creation; you'll write a new page in the relevant step below

## Step 4: Create Source Summary Page

Write `$VAULT/wiki/sources/<source-name>.md` using the source page template.

Include:
- Frontmatter with type, dates, author, URL, tags
- 3-5 key takeaways (shaped by the user's guidance from Step 2)
- Summary (3-5 paragraphs)
- Notable quotes
- Wikilinks to entities mentioned and concepts discussed

## Step 5: Create or Update Entity Pages

For each significant entity (person, organization, product) mentioned in the source:

**If the entity page exists:** Read it, then use `Edit` to:
- Add new facts or timeline entries
- Add a wikilink to the new source in the Sources/Related section
- Update the `updated` date in frontmatter
- Add the new source to the `sources` frontmatter array

**If the entity page doesn't exist:** Create `$VAULT/wiki/entities/<entity-name>.md` using the entity template.

Only create entity pages for significant entities — people/orgs that are central to the source, not every name mentioned in passing.

## Step 6: Create or Update Concept Pages

For each key concept, framework, or technology discussed in the source:

**If the concept page exists:** Read it, then use `Edit` to:
- Add new information, nuances, or examples from the source
- Add a wikilink to the new source
- Update the `updated` date in frontmatter

**If the concept page doesn't exist:** Create `$VAULT/wiki/concepts/<concept-name>.md` using the concept template.

Only create concept pages for concepts that are substantively discussed — not every term mentioned.

## Step 7: Check for Synthesis Opportunities

Ask yourself: does this source connect to existing knowledge in an interesting way?

Look for:
- **Contradictions**: this source disagrees with an existing source
- **Confirmations**: this source provides new evidence for an existing concept
- **Connections**: this source links two previously unrelated concepts
- **Evolutions**: this source shows how a concept has changed over time

If you find a synthesis opportunity, create `$VAULT/wiki/synthesis/<synthesis-name>.md` using the synthesis template.

## Step 8: Cross-Link Existing Pages

For existing pages that should now link to the new content:
- Read the related page
- Add wikilinks to new pages in the Related/Sources section
- Update the `updated` date

This step prevents orphan pages and strengthens the knowledge graph.

## Step 9: Update Index

Read `$VAULT/wiki/index.md` and add entries for all new pages. Each entry should have:
- A wikilink to the page
- A one-line summary

Use `Edit` to add entries under the appropriate category section. Do not rewrite the entire index.

## Step 10: Update Log

Call the log-append script — never read or edit `log.md` directly:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/log-append.sh" "$VAULT" "ingest" "<Source Title>" "<raw source path or empty>"
```

The script appends a timestamped entry in the format `## [YYYY-MM-DD] ingest | <Title>`, which makes the log parseable with simple unix tools:

```bash
grep "^## \[" "$VAULT/wiki/log.md" | tail -5   # last 5 operations
```
