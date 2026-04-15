# Demo Index Template

Use this template for `demos/index.md`. This is a Map of Content (MOC) for all demos in this repo.

---

```markdown
---
date: <YYYY-MM-DD>
tags:
  - showboat/index
  - MOC
---

# Demo Index: <repo-name>

## All Demos

```dataview
TABLE date, status, evidence_count
FROM "showboat/<repo-name>/demos"
WHERE contains(tags, "showboat/demo")
SORT date DESC
```

## Recent

<!-- Static list maintained by showboat-demo. Most recent first. -->

| Demo | Date | Status | Evidence |
|------|------|--------|----------|
| [[<feature-name>]] | <YYYY-MM-DD> | <status> | <count> items |

## By Status

### Verified

<!-- Demos where all checks passed -->

### Partial

<!-- Demos created without full evidence -->

### Regression

<!-- Demos where showboat-verify found issues -->

## Testing Context

- [[testing-context]]
```

## Update Rules

When adding a new demo to an existing index:

1. Add a row to the "Recent" table (keep sorted by date, most recent first)
2. Add a link under the appropriate status section
3. Update the `date` in frontmatter to today
4. Do NOT remove or modify existing entries
5. Use `Edit` to modify in place — do not rewrite the entire file
