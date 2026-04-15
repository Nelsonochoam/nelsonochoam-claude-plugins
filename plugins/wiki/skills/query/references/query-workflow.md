# Query Workflow

Detailed process for searching the wiki and synthesizing answers.

## Phase 1: Understand the Question

Before searching, decompose the question:
- **What type of answer is needed?** (factual, comparative, analytical, historical)
- **What page types are likely relevant?** (entities for "who", concepts for "what/how", sources for "where did we learn", synthesis for "what's the connection")
- **What keywords to search for?** (derive 3-5 search terms from the question)

## Phase 2: Broad Search

Search across all wiki directories:

```bash
# Find pages that mention key terms
grep -rl "<keyword>" "$VAULT/wiki/" 2>/dev/null | head -20
```

Also check the index for relevant categories and pages.

## Phase 3: Deep Read

For the most relevant pages (up to 10):
1. Read the full page content
2. Note key information that relates to the question
3. Identify wikilinks that might lead to additional relevant pages

## Phase 4: Follow Links

For each wikilink in the relevant pages that might be useful:
1. Read the linked page
2. Note any additional relevant information
3. Stop when you're no longer finding new information (diminishing returns)

Limit link-following to 2 hops from the initial results to prevent excessive reading.

## Phase 5: Synthesize

Combine information from all pages read:

1. **Identify the core answer** — what directly addresses the question
2. **Add supporting context** — related information that strengthens or nuances the answer
3. **Note contradictions** — if different sources disagree, present both views
4. **Cite everything** — every claim should trace back to a specific wiki page

## Phase 6: Evaluate Completeness

Ask yourself:
- Does the answer fully address the question?
- Are there aspects of the question the wiki doesn't cover?
- Is this answer better than what a single wiki page provides? (If not, just point to that page)

## Phase 7: Consider Synthesis Page

A synthesis page is warranted when:
- The answer combines insights from 3+ sources in a novel way
- The connection between concepts wasn't explicitly stated in any single page
- This question is likely to be asked again
- The answer represents accumulated understanding, not just facts

A synthesis page is NOT warranted when:
- The answer is a simple factual lookup
- One existing page already covers the answer
- The question is too specific or ephemeral to benefit from a persistent page
