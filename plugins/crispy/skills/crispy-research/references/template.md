# Research Document Template

```markdown
---
task: <ticket-id-kebab-description>
type: research
---

# Research: <Topic>

## Research Questions
<List the original questions that were answered>

## Summary
<2–4 sentences describing what was found at a high level>

## Detailed Findings

### <Question or Component Area 1>
- What exists at [`file.ts:line`](permalink) and what it does
- How it connects to other parts of the system
- Include a code snippet only when it clarifies behavior that prose alone cannot explain:
  ```ts
  // relevant snippet
  ```

### <Question or Component Area 2>
- ...

## Code References
- [`path/to/file.ts:123`](permalink) — description of what's there
- [`path/to/file.ts:45-67`](permalink) — description of the code block

## Architecture Notes
<Patterns, conventions, and design decisions found in this area of the codebase>

## Open Questions
<Anything that could not be answered from the codebase alone>
```

## Permalink Format

Generate GitHub permalinks using the current commit hash so references survive future changes:

```
https://github.com/{owner}/{repo}/blob/{commit_sha}/{file_path}#L{line}
```

For line ranges use `#L{start}-L{end}`.

To resolve the values, run:
- `gh repo view --json owner,name --jq '"\(.owner.login)/\(.name)"'`
- `git rev-parse HEAD`
