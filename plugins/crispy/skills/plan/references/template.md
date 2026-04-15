# Plan Template (Master Index)

The plan document is a lightweight master index. All detailed implementation specifics (exact file changes, code blocks, function signatures) belong in individual phase docs under `phases/`.

````markdown
---
task: <ticket-id-kebab-description>
type: plan
---

# <Feature/Task Name> Implementation Plan

## Overview
<2–3 sentence summary of what this plan accomplishes and why>

## Current State
<What exists now, what's missing, key constraints — drawn from the research doc if available, otherwise from your own codebase research>

## Desired End State
<What will be true when this plan is complete — drawn from the design doc if available, otherwise from the intent>

## What We're NOT Doing
<Copy directly from the intent/design doc's out-of-scope list if available — do not paraphrase. If no prior docs exist, derive from user-provided context and flag as assumed.>

## Key Finding
<The most important orienting fact from the structure outline's Key Finding section, or from your own research if no structure outline exists>

## Phase Summary

| Phase | Title | Dependencies | Doc |
|-------|-------|-------------|-----|
| 1 | <title> | — | [phases/phase-1.md](phases/phase-1.md) |
| 2 | <title> | Phase 1 | [phases/phase-2.md](phases/phase-2.md) |
| 3 | <title> | Phase 1 | [phases/phase-3.md](phases/phase-3.md) |

## Dependency Graph

<ASCII dependency diagram from structure outline — shows which phases can run in parallel vs. sequentially>

## Success Criteria

### Automated Verification
- `npm run lint` passes
- `npm run type-check` passes
- `npm test` passes
- <any feature-specific test commands>

### Manual Verification
- <specific behavior visible to a human>
- <edge case confirmed>

## References
- Intent: `<path>`
- Design: `<path>`
- Structure Outline: `<path>`
- Research: `<path>`
- Key patterns: `<file:line>`
````

## Guidelines

- The plan document contains **no implementation details** — no file paths to change, no code blocks, no function signatures. Those all live in phase docs.
- The plan document contains **no checkboxes** — progress tracking is done exclusively via `manifest.json`.
- Phase titles must match the structure outline verbatim (if one exists). If you believe a phase should be split or renamed, flag it and ask.
- The dependency graph should make it clear which phases can be executed in parallel.
- Success criteria are global (full-feature) — per-phase criteria live in the phase docs.
