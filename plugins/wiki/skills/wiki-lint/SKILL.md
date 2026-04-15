---
name: wiki-lint
description: Health-check the wiki — find orphan pages, missing cross-references, contradictions, and stale content. Optionally auto-fix issues.
argument-hint: '[--fix to auto-fix issues]'
model: opus
---

User's request: $ARGUMENTS

# Lint Wiki

You are running a health check on the wiki knowledge base. Your job is to find structural issues, missing connections, and content problems, then report (and optionally fix) them.

## Vault Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/vault-discovery.md`.

Store the resolved vault path as `$VAULT`.

## Read Schema

If `$VAULT/CLAUDE.md` exists, read it for vault-specific conventions and linting criteria.

## Read Lint Checks

Read and follow `${CLAUDE_SKILL_DIR}/references/lint-checks.md` for the detailed check list.

## Scan All Pages

Build a list of all wiki pages:

```bash
find "$VAULT/wiki" -name "*.md" ! -name "index.md" ! -name "log.md" -type f
```

For each page, read its content and extract:
- Frontmatter fields (type, created, updated, sources, tags)
- All outbound wikilinks (`[[...]]`)
- Page title (first `# ` heading)

## Run Checks

Execute each check from `lint-checks.md`:

1. **Orphan pages** — pages with no inbound links from other pages
2. **Dead links** — wikilinks pointing to pages that don't exist
3. **Missing frontmatter** — pages without required frontmatter fields
4. **Missing outbound links** — pages with no wikilinks to other pages
5. **Stale pages** — pages not updated for a long time (configurable, default: 90 days)
6. **Missing concepts** — important terms mentioned in multiple pages but without dedicated concept pages
7. **Index gaps** — pages that exist but aren't listed in the index
8. **Tag inconsistencies** — pages with types that don't match their `wiki/<type>` tag
9. **Empty sections** — pages with section headers but no content
10. **Contradictions** — conflicting claims across pages (requires careful reading)

## Report Findings

Present findings organized by severity:

```
Wiki Health Check — <date>

Pages scanned: <count>
Issues found: <count>

## Critical

<!-- Issues that break the knowledge graph -->

### Dead Links (<count>)
- [[page-name]] links to [[missing-page]] (line <N>)
- ...

### Missing Frontmatter (<count>)
- <page-path>: missing `type` field
- ...

## Warnings

<!-- Issues that degrade quality -->

### Orphan Pages (<count>)
- [[page-name]] — no inbound links. Consider linking from [[related-page]].
- ...

### Missing Concepts (<count>)
- "<term>" mentioned in <N> pages but has no concept page. Consider creating [[concepts/<term>]].
- ...

### Index Gaps (<count>)
- [[page-name]] exists but is not in the index.
- ...

## Suggestions

<!-- Nice-to-have improvements -->

### Stale Pages (<count>)
- [[page-name]] — last updated <date> (<N> days ago)
- ...

### Missing Cross-References
- [[page-a]] and [[page-b]] discuss similar topics but don't link to each other
- ...

## Summary

Total: <critical> critical, <warning> warnings, <suggestion> suggestions
```

## Auto-Fix (if `--fix` passed)

If `$ARGUMENTS` contains `--fix`:

1. **Dead links**: Create stub pages for missing link targets with a `status: stub` frontmatter
2. **Missing frontmatter**: Add required fields based on the page's directory (entities/ → type: entity, etc.)
3. **Index gaps**: Add missing pages to the index
4. **Tag inconsistencies**: Fix tags to match the page type
5. **Orphan pages**: Add links from the most relevant existing page

Do NOT auto-fix:
- Contradictions (requires human judgment)
- Stale pages (might be intentionally stable)
- Missing concepts (creating concept pages requires content, not just stubs)

Report what was fixed:

```
Auto-fixed:
  - Created <N> stub pages for dead links
  - Added frontmatter to <N> pages
  - Added <N> pages to index
  - Fixed tags on <N> pages
  - Added links to <N> orphan pages

Remaining (manual attention needed):
  - <count> contradictions
  - <count> stale pages
  - <count> missing concepts
```

## Log the Operation

Append to `$VAULT/wiki/log.md`:

```markdown
## [YYYY-MM-DD] lint | Health Check

Scanned <N> pages. Found <N> issues (<N> critical, <N> warnings, <N> suggestions).
<Fixed <N> issues automatically. | No auto-fixes applied.>
```
