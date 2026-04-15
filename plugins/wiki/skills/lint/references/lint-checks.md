# Lint Checks

Detailed specification for each wiki health check.

## 1. Orphan Pages

**Severity**: Warning

**What**: Pages with no inbound links from other wiki pages.

**How to check**: For each page, search all other pages for a wikilink `[[page-name]]` or `[[folder/page-name]]`. The index and log don't count as inbound links (they're meta-pages, not knowledge).

**Why it matters**: Orphan pages are invisible in the knowledge graph. If no one links to them, they'll never be discovered through navigation.

**Fix**: Link from the most related existing page. If no related page exists, the orphan might be unnecessary.

## 2. Dead Links

**Severity**: Critical

**What**: Wikilinks pointing to pages that don't exist.

**How to check**: Extract all `[[...]]` patterns from each page. For each link, check if the target file exists at `$VAULT/wiki/<link-target>.md`. Handle links with display text: `[[target|display]]` — only check the target part.

**Why it matters**: Dead links break navigation and indicate incomplete work.

**Auto-fix**: Create a stub page with minimal frontmatter and a note: "This page was created as a stub by wiki:lint. Please add content."

## 3. Missing Frontmatter

**Severity**: Critical

**What**: Pages missing required frontmatter fields (`type`, `created`, `updated`, `tags`).

**How to check**: Parse YAML frontmatter from each page. Check for required fields.

**Why it matters**: Missing frontmatter breaks Dataview queries and makes the page type ambiguous.

**Auto-fix**: Infer type from directory (`entities/` → entity, etc.), set dates from file modification time, add `wiki/<type>` tag.

## 4. Missing Outbound Links

**Severity**: Warning

**What**: Pages with no `[[wikilinks]]` to other wiki pages.

**How to check**: Count wikilinks in each page. Pages with zero outbound links are flagged.

**Why it matters**: "A note without links is a bug." Isolated pages don't contribute to the knowledge graph.

**Fix**: Read the page content and identify concepts, entities, or sources that should be linked.

## 5. Stale Pages

**Severity**: Suggestion

**What**: Pages with `updated` date older than a threshold (default: 90 days).

**How to check**: Parse `updated` from frontmatter. Calculate days since last update.

**Why it matters**: Stale pages may contain outdated information, especially for rapidly evolving topics.

**Note**: Some pages are intentionally stable (e.g., historical entities, established concepts). Use judgment.

## 6. Missing Concepts

**Severity**: Warning

**What**: Terms that appear in 3+ wiki pages but don't have a dedicated concept page.

**How to check**: Extract notable terms from pages (capitalized multi-word phrases, technical terms in code blocks or bold). Count occurrences across pages. Flag terms that appear in 3+ pages without a matching `concepts/<term>.md`.

**Why it matters**: Frequently referenced concepts deserve their own page for centralized knowledge.

**Note**: Not all recurring terms need concept pages. Use judgment — `JavaScript` probably needs one, `the` does not.

## 7. Index Gaps

**Severity**: Warning

**What**: Wiki pages that exist as files but are not listed in `wiki/index.md`.

**How to check**: List all `.md` files in `wiki/`. Check if each has a corresponding entry (wikilink) in `index.md`.

**Why it matters**: The index is the primary navigation tool. Missing entries make pages harder to discover.

**Auto-fix**: Add missing pages to the appropriate category section in the index.

## 8. Tag Inconsistencies

**Severity**: Warning

**What**: Pages whose `type` field doesn't match their `wiki/<type>` tag, or pages in the wrong directory for their type.

**How to check**: Compare `type` frontmatter with tags and directory location.

**Why it matters**: Dataview queries rely on consistent tagging. Mismatches cause pages to appear in wrong views.

**Auto-fix**: Update tags to match the `type` field.

## 9. Empty Sections

**Severity**: Suggestion

**What**: Pages with section headers (`##`, `###`) followed by no content before the next header or end of file.

**How to check**: Parse markdown structure. Flag sections with no content between their header and the next header.

**Why it matters**: Empty sections indicate incomplete pages that should either be filled or removed.

## 10. Contradictions

**Severity**: Warning

**What**: Conflicting claims across different pages.

**How to check**: This requires careful reading and is the most judgment-intensive check. Look for:
- Entity pages claiming different roles, dates, or affiliations
- Concept pages giving conflicting definitions
- Source pages summarizing the same source differently
- Synthesis pages drawing conclusions that contradict source pages

**Why it matters**: Contradictions erode trust in the knowledge base. They may indicate stale information, misinterpretation, or genuinely contested claims.

**Note**: Some contradictions are legitimate (different sources disagree). The lint report should flag them for human review, not auto-fix.
