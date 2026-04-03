# Design Questions Format

Present the full set of questions at once in this format:

```markdown
## Design Questions

**1. <Decision Title>**

<The specific question — one sentence>

- **Option A**: <description>
  ```ts
  // code showing what this looks like
  ```
- **Option B**: <description>
  ```ts
  // code showing what this looks like
  ```

**Recommendation**: Option A — <why, grounded in the research or intent>

---

**2. <Decision Title>**

<question>

- **Option A**: <description>
- **Option B**: <description>

**Recommendation**: Option B — <why>

---
```

After presenting, ask:

```
Go through each question and tell me which option you want, or override with your own direction.
You can also just say "go with all recommendations" if they look right.
```

## Resolved Design Questions Format

Once the user has responded, confirm what was decided:

```markdown
## Resolved Design Questions

### <Decision Title>
<Chosen option and any relevant notes — if they deviated from the recommendation, note why>

### <Decision Title>
<resolution>
```

If anything is still ambiguous after their response, ask one follow-up before moving on.
