# Structure Outline Template

```markdown
---
task: <ticket-id-kebab-description>
type: structure-outline
branch: <current branch>
sha: <short git SHA>
---

### Status
- Document: <base_dir>/<repo>/<feature>/structure-outline.md
- Ticket: <ticket id>
- Phases: <N> (<M> sequential, <K> parallel)
- Open Questions: <none, or list them>

### Key Finding

<2–4 sentences on the most important orienting fact from the design.
What does a developer most need to know before starting? What changes their mental model of the scope?>

---

## Phase 1: <Descriptive title>

<One sentence — what this phase delivers and why it comes first>

### File Changes

- **`path/to/file.ts`**: <one-line summary of the change>
  - <What changes — name the specific function/prop/identifier and what it does differently>
  - <Another change in the same file>
- **`path/to/other-file.ts`**: <one-line summary>
  - <What changes>

### Tests

- **`path/to/file.test.ts`** (new or existing): <what behavior this test covers>
  - <Specific case: e.g. "renders X when prop Y is false">
  - <Specific case>

### Validation

```
<automated check command, e.g. npm run type-check && npm test --runTestsByPath <path>
```

Manual testing:

1. <User-facing step to verify this phase works>
2. <Another verification step>
3. ...

---

<!-- Use this block when two or more phases have no dependency on each other -->
## Phases 2–3: <Group title> *(can be done in parallel)*

> These phases are independent and can be worked on simultaneously or in any order.

---

## Phase 2: <Descriptive title>

<One sentence — what this phase delivers; note it is independent of Phase 3>

### File Changes

- **`path/to/file.ts`**: <one-line summary>
  - <What changes>

### Tests

- **`path/to/file.test.ts`** (new or existing): <what behavior this test covers>
  - <Specific case>

### Validation

```
<automated check command>
```

Manual testing:

1. <Manual step>
2. ...

---

## Phase 3: <Descriptive title>

<One sentence — what this phase delivers; note it is independent of Phase 2>

### File Changes

- **`path/to/file.ts`**: <one-line summary>
  - <What changes>

### Tests

- **`path/to/file.test.ts`** (new or existing): <what behavior this test covers>
  - <Specific case>

### Validation

```
<automated check command>
```

Manual testing:

1. <Manual step>
2. ...

---

## Open Questions

<Any unresolved questions that could affect phasing — or "None — all design decisions resolved in the design discussion phase.">

## Dependency Chart

<ASCII diagram showing phase dependencies. Use arrows to show sequential flow and groupings to show parallelism.>

Example:

```
Phase 1 (DB schema) ──→ Phase 2 (API endpoints) ──→ Phase 4 (Integration tests)
                    ──→ Phase 3 (UI components)  ──↗
```

Legend:
- **Sequential**: <which phases depend on which, and why>
- **Parallel**: <which phases can run concurrently, and why they are independent>
- **Converge**: <which phases must wait for parallel work to complete>
```
