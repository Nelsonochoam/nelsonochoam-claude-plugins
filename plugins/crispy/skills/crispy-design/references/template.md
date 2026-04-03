# Design Document Template

```markdown
---
task: <ticket-id-kebab-description>
type: design-discussion
repo: <repository name>
branch: <current branch>
sha: <full git SHA>
---

### Summary of change request

<What the user wants to build and why — 2–4 sentences drawn from the intent>

### Current State

- <Factual bullet from research, with `file:line` reference where relevant>
- ..

### Desired End State

- <What will be true when this is done>
- <User-facing framing where helpful: "A user can now...">
- ..

### What we're not doing

- <Explicit out-of-scope item>
- ..

### Patterns to follow

#### <Pattern title>

<One sentence describing the pattern and why it applies> — `path/to/file.ts:line`

```ts
// succinct code example
```

### Design Questions

**1. <Decision Title>**

<question>

- **Option A**: ...
  ```ts
  // example
  ```
- **Option B**: ...
  ```ts
  // example
  ```

**Recommendation**: Option X — <why>

---

**2. <Next question>**
...

### Resolved Design Questions

#### <Decision Title>
<What was chosen and why>

#### <Next decision>
<resolution>

### Validation

- <How we'll know it works>
- ..
```
