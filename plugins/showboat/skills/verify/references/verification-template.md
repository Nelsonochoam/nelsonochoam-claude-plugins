# Verification Report Template

Use this template when writing verification reports.

---

```markdown
---
date: <YYYY-MM-DD>
feature: <feature-name>
repo: <repo-name>
original_demo: "[[demos/<feature-name>]]"
result: <pass | fail>
passed: <count>
failed: <count>
skipped: <count>
tags:
  - showboat/verification
  - showboat/<pass|fail>
---

# Verification: <Feature Title>

> Re-verification of [[demos/<feature-name>]] on <YYYY-MM-DD>

## Summary

| Metric | Count |
|--------|-------|
| Passed | <count> |
| Failed | <count> |
| Skipped | <count> |
| Total | <count> |

## Results

<!-- One subsection per verification step -->

### <label> — PASS

> Original: <date of original capture>
> Verified: <current date>

**Command**: `<command>`
**Expected exit code**: <code> | **Actual**: <code>

<If stdout comparison relevant:>
Output matches expected pattern.

---

### <label> — FAIL

> Original: <date of original capture>
> Verified: <current date>

**Command**: `<command>`
**Expected exit code**: <code> | **Actual**: <code>

**Difference:**

```diff
- <original relevant output>
+ <current relevant output>
```

**Possible cause**: <brief analysis of what might have changed>

---

### <label> — SKIP

> Reason: <why this step was skipped, e.g., "No browser tools available">

---

## Recommendations

<!-- Only if there are failures -->

<For each failure, suggest what to investigate or fix.>

## Links

- Original demo: [[demos/<feature-name>]]
- Demo index: [[demos/index]]
```
