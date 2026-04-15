# Page Templates

Use these templates when creating new wiki pages. Adapt the structure to the content — not every section is required for every page.

## Source Page Template

```markdown
---
type: source
created: YYYY-MM-DD
updated: YYYY-MM-DD
author: "<author name>"
url: "<original URL>"
date_published: YYYY-MM-DD
tags:
  - wiki/source
  - <domain-tag>
---

# <Source Title>

## Key Takeaways

1. <Most important point>
2. <Second most important point>
3. <Third most important point>

## Summary

<3-5 paragraphs summarizing the source. Focus on ideas and arguments, not just restating facts.>

## Notable Quotes

> "<Significant quote>" — <brief context>

> "<Another quote>" — <brief context>

## Entities Mentioned

- [[entities/<entity-name>]] — <brief context of mention>

## Concepts Discussed

- [[concepts/<concept-name>]] — <brief context of discussion>
```

## Entity Page Template

```markdown
---
type: entity
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: ["[[sources/<source-name>]]"]
tags:
  - wiki/entity
  - <domain-tag>
aliases:
  - <alternative name>
---

# <Entity Name>

<2-3 sentence overview: who/what this is and why they matter.>

## Key Facts

- **Type**: Person | Organization | Product | Project
- **Role/Description**: <primary role or description>
- **Affiliation**: [[entities/<org>]] (if applicable)
- **Known for**: [[concepts/<concept>]]

## Details

<Paragraph with more context, background, contributions.>

## Timeline

- **YYYY**: <significant event>
- **YYYY**: <significant event>

## Related

- [[concepts/<related-concept>]]
- [[entities/<related-entity>]]
- [[sources/<source-mentioning-entity>]]
```

## Concept Page Template

```markdown
---
type: concept
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: ["[[sources/<source-name>]]"]
tags:
  - wiki/concept
  - <domain-tag>
aliases:
  - <alternative name or acronym>
---

# <Concept Name>

<Clear, concise definition in 1-2 sentences.>

## Explanation

<Detailed explanation. Include how it works, why it matters, and where it applies. Use examples.>

## Key Points

- <Important aspect 1>
- <Important aspect 2>
- <Important aspect 3>

## Examples

<Concrete examples or use cases.>

## Related Concepts

- [[concepts/<related-1>]] — <how they relate>
- [[concepts/<related-2>]] — <how they relate>

## Sources

- [[sources/<source-1>]]
- [[sources/<source-2>]]
```

## Synthesis Page Template

```markdown
---
type: synthesis
created: YYYY-MM-DD
updated: YYYY-MM-DD
sources: ["[[sources/<source-1>]]", "[[sources/<source-2>]]"]
tags:
  - wiki/synthesis
  - <domain-tag>
---

# <Synthesis Title>

## Thesis

<One paragraph stating the key insight or connection that emerged from combining multiple sources.>

## Analysis

<Detailed analysis. Walk through the evidence from each source, explain how they connect, and build toward the conclusion.>

### From [[sources/<source-1>]]

<What this source contributes to the synthesis.>

### From [[sources/<source-2>]]

<What this source contributes.>

### Connection

<How these pieces fit together. What new understanding emerges.>

## Evidence

- [[sources/<source-1>]]: <specific evidence>
- [[sources/<source-2>]]: <specific evidence>

## Implications

<What this synthesis means practically. How should this insight inform decisions or understanding?>

## Open Questions

<What remains unclear or needs further investigation?>

## Related

- [[concepts/<concept>]]
- [[entities/<entity>]]
```
