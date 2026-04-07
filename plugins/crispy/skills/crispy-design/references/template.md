# Design Document Template

```markdown
---
task: <ticket-id-kebab-description>
type: design
---

### Summary

<What we're building and the approach at a glance — 2–4 sentences drawn from the intent>

### Motivation

<Why this change matters — what problem exists today, who is affected, and what is the cost of not doing it. Frame for an engineering audience: what breaks, what's slow, what's impossible without this change.>

### Current State

- <Factual bullet from research, with `file:line` reference where relevant>
- ..

### Desired End State

- <What will be true when this is done>
- <User-facing framing where helpful: "A user can now...">
- ..

### What we're not doing

- <Explicit out-of-scope item — and why it's out of scope if not obvious>
- ..

### Proposed Approach

<The narrative core of this document. 2–5 paragraphs describing HOW the solution works. An engineer should be able to picture the full solution after reading this section alone.>

<Include:>
<- High-level architecture or component interaction>
<- Data or control flow — use pseudo-code for sequences, real code for interfaces/APIs/config>
<- Which existing patterns and code this builds on, referenced inline with `file:line`>
<- Key technical details an implementer needs to understand>

<Example structure:>

We'll create a new `FooService` that wraps the existing `BarClient` (`src/clients/bar.ts:12`), following the service pattern established in `BazService` (`src/services/baz.ts:1-15`). The service exposes a single `process()` method that:

1. Validates the input against the schema at `src/schemas/foo.ts:8`
2. Calls `BarClient.fetch()` to retrieve the upstream data
3. Transforms the response using the existing `normalize()` utility (`src/utils/transform.ts:42`)
4. Writes the result to the feature's output directory

```ts
interface FooService {
  process(input: FooInput): Promise<FooResult>;
}
```

The flow looks like:

```
User invokes /foo
  → FooService.process(input)
    → BarClient.fetch(input.id)
    → normalize(response)
    → write to $FEATURE_PATH/output.json
```

<Use this section to tell the story of how the solution works. Reference existing code inline to show you're building on what exists, not inventing from scratch.>

### Design Questions

<Questions about decisions where the approach could meaningfully diverge. See questions-format.md for the exact format.>

**1. <Decision Title>**

<Why this decision matters — what depends on it>

- **Option A**: <description>
  ```ts
  // code showing what this looks like
  ```
  - **Pros**: <what you gain>
  - **Cons**: <what you lose or accept>

- **Option B**: <description>
  ```ts
  // code showing what this looks like
  ```
  - **Pros**: <what you gain>
  - **Cons**: <what you lose or accept>

**Recommendation**: Option X — <why, referencing specific tradeoffs>

---

**2. <Next question>**
...

### Resolved Design Questions

#### 1. <Decision Title>
**Chosen**: Option X — <rationale and any deviations from recommendation>

#### 2. <Next decision>
**Chosen**: <resolution>

### Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| <what could go wrong> | Low / Med / High | <what happens if it does> | <how we prevent or handle it> |
| <assumption that might be wrong> | Low / Med / High | <consequence> | <fallback or validation step> |

### Validation

- <How we verify the solution works end-to-end — not just pass/fail, but what to check and how>
- ..
```
