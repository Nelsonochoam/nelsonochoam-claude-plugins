# Phase Document Template

Each phase document is self-sufficient — an agent should be able to read **only** this file and implement the phase without opening the full plan. It includes references to all relevant artifacts so the agent (or a human reader) can navigate to broader context when needed.

````markdown
---
task: phase-{N}
feature: {feature}
phase: "{phase_title}"
dependencies: {dependencies_yaml}
---

# Phase {N}: {phase_title}

## Overview
<What this phase accomplishes — expand on the structure outline's summary if available, otherwise write from scratch>

## References
- [Plan](6-plan.md) — master index with dependency graph and global success criteria
- [Intent](1-intent.md) — scope, acceptance criteria, and what is out of scope
- [Research](3-research.md) — codebase findings with exact file paths
- [Design](4-design.md) — resolved design decisions and rationale

## Design Decisions Applied
<List the resolved design questions relevant to this phase — from the design doc if available, otherwise document the decisions you made during planning and why.
For each: state the decision and why — so the implementer doesn't re-open the question.>

## Dependencies

{dependency_section}

## Changes Required

- **1. <File or component group>**
  **File**: `path/to/file.ts` ← use exact path from research doc or direct lookup
  **Change**: <Precise description of what to add, modify, or delete>
  **Details**: <Specific field names, types, function signatures, logic>
  **Code** (required when the change involves wrapping, reordering, or multi-line edits):
  ```tsx
  // Before:
  <ExistingComponent prop1={value1} prop2={value2} />

  // After:
  {condition && (
    <ExistingComponent prop1={value1} prop2={value2} />
  )}
  ```
  **Pattern**: <Reference the matching pattern from the design doc, e.g., "follows `TrustCenterNavigationList.tsx:74` product count guard">

- **2. <Next file or component group>**
  ...

## Success Criteria

### Automated Verification
- `<exact command>`: <what it checks>

### Manual Verification
- <what a human must confirm before the next phase begins>

## Implementation Note
After all automated checks pass for this phase, pause for manual confirmation before proceeding to the next phase.
````

## Filling in placeholders

| Placeholder | Source |
|---|---|
| `{N}` | Phase number from the structure outline |
| `{feature}` | Feature name from `manifest.json` |
| `{phase_title}` | Full phase title (e.g., "Add status field to the Order model") |
| `{dependencies_yaml}` | YAML list of dependency IDs, e.g., `[phase-1]` or `[]` |
| `{dependency_section}` | See below |

**Dependency section content:**
- If `dependencies` is empty: `"This phase has no dependencies and can start immediately."`
- If `dependencies` is non-empty: list each dependency with its file path, e.g.:
  ```
  This phase depends on:
  - [Phase 1: <title>](phases/phase-1.md)
  - [Phase 2: <title>](phases/phase-2.md)

  Before starting, verify those phases are complete by checking their status in `manifest.json`.
  If any dependency is not done, stop and report which ones are incomplete.
  ```

## Guidelines for each step entry

- Name the exact file to change or create — use the path from the research doc or a direct codebase lookup, not a guess
- Describe the change precisely enough that someone unfamiliar with the codebase could execute it
- Include TypeScript types, field names, function signatures, and SQL details where relevant
- Include before/after code blocks for any step that wraps, reorders, or modifies multi-line JSX/logic — prose descriptions of wrapping are ambiguous and lead to incorrect implementations. For simple prop additions (adding a field to an interface, passing a prop), prose is sufficient.
- When referencing a location in a file, include both the approximate line number AND a textual anchor (e.g., "at line ~407, inside the `renderItems` map callback"). Line numbers drift; textual anchors let the implementer find the correct location even if lines have shifted.
- For every step, identify which resolved design decision it implements — reference it explicitly. If no design doc exists, document the decision inline with rationale.
- Flag any step that touches auth, permissions, billing, or migrations
- Do not introduce patterns not established in the design doc (if one exists) or not verified in the codebase
