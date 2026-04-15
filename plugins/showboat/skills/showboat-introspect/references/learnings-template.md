# Learnings Template

Use this template when writing introspection learnings documents. The format is designed to be ingestible by `/wiki-ingest`.

---

```markdown
---
date: <YYYY-MM-DD>
type: learnings
feature: <feature-name or "general">
repo: <repo-name>
categories:
  - <category-1>
  - <category-2>
source_demos: ["[[demos/<feature>]]"]
source_verifications: ["[[verifications/<feature>-<date>]]"]
tags:
  - showboat/learning
  - showboat/introspect
---

# Learnings: <Title>

> Introspection from testing session on <YYYY-MM-DD>.
> Repo: <repo-name> | Feature: <feature or "general">

## Summary

<2-3 sentences describing what was learned. What went wrong, what the user corrected, what gaps were found.>

## Learnings

<!-- Each learning is a self-contained section. The category tag enables filtering and wiki classification. -->

### 1. <Short description>

- **Category**: `navigation` | `auth` | `timing` | `interaction` | `data` | `environment` | `workflow` | `tooling`
- **What happened**: <What the agent attempted or assumed>
- **What was wrong**: <Why it failed or was incorrect>
- **Correct approach**: <The fix — specific route, command, selector, timing, etc.>
- **Source**: <Where this was discovered: evidence failure, verification regression, user correction>

**Apply to testing context:**
> <The specific change to make in testing-context.md, or "Already applied" if done>

---

### 2. <Short description>

- **Category**: `<category>`
- **What happened**: <...>
- **What was wrong**: <...>
- **Correct approach**: <...>
- **Source**: <...>

**Apply to testing context:**
> <...>

---

<!-- Continue for each learning -->

## Patterns

<!-- Optional section. If multiple learnings share a pattern, note it here. These are especially valuable for wiki ingestion — they become concept pages. -->

### <Pattern name>

<Description of a recurring pattern across learnings. For example: "This app requires auth for all /admin/* routes" or "API endpoints return 503 for 5 seconds after server restart.">

**Related learnings**: #1, #3, #5

## Testing Context Changes

<!-- Summary of all changes made to testing-context.md -->

| Section | Change | Learning |
|---------|--------|----------|
| <section> | <what was changed> | #<N> |
| <section> | <what was changed> | #<N> |

## Links

- Testing context: [[testing-context]]
- Demo index: [[demos/index]]
- Learnings index: [[learnings/index]]
<!-- Link to specific demos and verifications that sourced these learnings -->
- [[demos/<feature>]]
- [[verifications/<feature>-<date>]]
```

## Writing Rules

1. **Be concrete** — "The login page is at /auth/login not /login" is useful. "Authentication might be different" is not.
2. **Include the fix** — Every learning must have a "Correct approach" that someone (or an agent) can follow next time.
3. **Cite the source** — Was this from a failed evidence capture, a verification regression, or a user correction? This helps judge reliability.
4. **Update the context** — If a learning reveals a gap in testing-context.md, fix it immediately and note "Already applied" in the learning.
5. **Extract patterns** — If three learnings all involve auth, note the pattern. Patterns become wiki concept pages.
6. **Use wikilinks** — Link to demos, verifications, and the testing context. This creates a traceable graph in Obsidian.
