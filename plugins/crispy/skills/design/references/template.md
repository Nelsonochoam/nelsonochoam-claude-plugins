# Design Document Template

````markdown
---
task: <ticket-id-kebab-description>
type: design
---

> [Intent](1-intent.md) — context, motivation, scope, and acceptance criteria.

### Current State

<!-- What exists now, what's missing, key constraints discovered -->

### Desired End State

<!-- A Specification of the desired end state after this plan is complete, and how to verify it -->

### Patterns to Follow

<!-- Structural conventions found in the codebase that the implementation should align with. Each entry is a pattern name, a source reference, a one-line description, and a representative snippet. Omit entries that aren't relevant to this feature. -->

**<Pattern Name>** — `file:line`
<What this pattern is and when it's used — one sentence.>

```ts
// representative snippet showing the pattern's shape
```
````

**<Pattern Name>** — `file:line`
<What this pattern is and when it's used — one sentence.>

```ts
// representative snippet
```

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

**D1. <Decision Title>**

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

- **Option C** _(only if a third genuinely distinct option exists — omit if not)_: <description>

  ```ts
  // code showing what this looks like
  ```

  - **Pros**: <what you gain>
  - **Cons**: <what you lose or accept>

**Recommendation**: Option X — <why, referencing specific tradeoffs>

---

**D2. <Next question>**
...

### Resolved Design Questions

#### D1. <Decision Title>

**Chosen**: Option X — <rationale and any deviations from recommendation>

#### D2. <Next decision>

**Chosen**: <resolution>

### AC Coverage

<!-- Use the format that matches the intent. If the intent defines explicit ACs (AC-1, AC-2, etc.), use the table. If not, use the inferred checklist. Delete the format you don't use. -->

#### When the intent has explicit ACs:

| AC   | Description              | Decisions |
| ---- | ------------------------ | --------- |
| AC-1 | <short name from intent> | D1, D3    |
| AC-2 | <short name from intent> | D2        |

- [ ] All acceptance criteria from the intent are covered
- [ ] No design section introduces behavior outside the stated ACs without justification

#### When the intent has no explicit ACs:

**What this design solves:**

- [ ] <Key outcome inferred from the intent's summary/motivation — e.g., "Users can filter results by date range"> → Proposed Approach, paragraph 2
- [ ] <Another outcome> → Proposed Approach, paragraph 4; Validation, item 1
- [ ] <Edge case or constraint addressed> → Risks & Mitigations, row 1

```

```
