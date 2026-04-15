# Page Conventions

All wiki pages follow these conventions. If a vault's `CLAUDE.md` schema defines overrides, those take precedence.

## Frontmatter (Required)

Every wiki page must have YAML frontmatter:

```yaml
---
type: entity | concept | source | synthesis
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: ["[[sources/source-name]]"]
tags:
  - wiki/<type>
  - <domain-specific-tag>
---
```

### Required fields:
- `type` — page category (entity, concept, source, synthesis)
- `created` — date the page was first created
- `updated` — date of the most recent modification
- `tags` — must include `wiki/<type>` plus relevant domain tags

### Optional fields:
- `sources` — wikilinks to source pages that inform this page
- `aliases` — alternative names for Obsidian search
- `status` — `stub | draft | complete` for tracking completeness

## Wikilinks

- Use `[[page-name]]` for all cross-references between wiki pages
- Use `[[page-name|display text]]` when the link text should differ from the page name
- Use `[[folder/page-name]]` when linking across directories (e.g., `[[concepts/attention-mechanism]]`)
- Every page must have at least one outbound link to another wiki page
- Orphan pages (no inbound links) should be linked from related pages or the index

## File Naming

- Use kebab-case: `transformer-architecture.md`, `andrej-karpathy.md`
- One concept per file — if a page covers multiple distinct ideas, split it
- Prefer specific names: `attention-mechanism.md` over `attention.md`
- Source pages mirror source names: if the article is "Why RAG is Dead", the source page is `sources/why-rag-is-dead.md`

## Page Structure

### Entity Pages

```markdown
---
type: entity
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [wiki/entity]
---

# <Entity Name>

<2-3 sentence overview>

## Key Facts

- **Role**: ...
- **Affiliation**: [[entities/org-name]]
- **Known for**: [[concepts/concept-name]]

## Timeline

- **YYYY**: <event>
- **YYYY**: <event>

## Related

- [[concepts/related-concept]]
- [[sources/source-mentioning-entity]]
```

### Concept Pages

```markdown
---
type: concept
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [wiki/concept]
---

# <Concept Name>

<Clear definition in 1-2 sentences>

## Explanation

<Detailed explanation with examples>

## Key Points

- ...
- ...

## Related Concepts

- [[concepts/related-1]]
- [[concepts/related-2]]

## Sources

- [[sources/source-1]]
- [[sources/source-2]]
```

### Source Pages

```markdown
---
type: source
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: <author name>
url: <original URL if applicable>
date_published: YYYY-MM-DD
tags: [wiki/source]
---

# <Source Title>

## Key Takeaways

1. ...
2. ...
3. ...

## Summary

<3-5 paragraph summary of the source>

## Notable Quotes

> "Quote from the source" — <context>

## Entities Mentioned

- [[entities/person-or-org]]

## Concepts Discussed

- [[concepts/concept-name]]
```

### Synthesis Pages

```markdown
---
type: synthesis
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: ["[[sources/source-1]]", "[[sources/source-2]]"]
tags: [wiki/synthesis]
---

# <Synthesis Title>

## Thesis

<One paragraph stating the insight or connection>

## Analysis

<Detailed analysis connecting multiple sources and concepts>

## Evidence

- [[sources/source-1]] shows that...
- [[sources/source-2]] argues that...

## Implications

<What this means, practical consequences>

## Related

- [[concepts/concept-1]]
- [[entities/entity-1]]
```

## Update Rules

- Always update the `updated` date when modifying a page
- Add new `sources` links when incorporating information from new sources
- Add new wikilinks when connections are discovered
- Never remove existing links unless the referenced page is deleted
- Keep the index updated with every new page
