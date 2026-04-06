# Plan Template

````markdown
---
task: <ticket-id-kebab-description>
type: plan
repo: <repository name>
branch: <current branch>
sha: <full git SHA>
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

## Success Criteria

### Automated Verification
- [ ] `npm run lint` passes
- [ ] `npm run type-check` passes
- [ ] `npm test` passes
- [ ] <any feature-specific test commands>

### Manual Verification
- [ ] <specific behavior visible to a human>
- [ ] <edge case confirmed>

---

- [ ] **Phase 1: <Title from structure outline if available, otherwise a descriptive phase name>**

### Overview
<What this phase accomplishes — expand on the structure outline's summary if available, otherwise write from scratch>

### Design Decisions Applied
<List the resolved design questions relevant to this phase — from the design doc if available, otherwise document the decisions you made during planning and why.
For each: state the decision and why — so the implementer doesn't re-open the question.>

### Changes Required

- [ ] **1. <File or component group>**
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

- [ ] **2. <Next file or component group>**
  ...

### Success Criteria

#### Automated Verification
- [ ] <command>: `<exact command to run>`

#### Manual Verification
- [ ] <what a human must confirm before the next phase begins>

**Implementation Note**: After all automated checks pass for this phase, pause for manual confirmation before proceeding to Phase 2.

---

- [ ] **Phase 2: <Title from structure outline if available, otherwise a descriptive phase name>**

<Same structure — each phase header and each change within it uses `- [ ]` checkboxes>

---

## References
- Intent: <path>
- Design: <path>
- Structure Outline: <path>
- Research: <path>
- Key patterns: `<file:line>`
````

## Guidelines for each step entry

- Name the exact file to change or create — use the path from the research doc or a direct codebase lookup, not a guess
- Describe the change precisely enough that someone unfamiliar with the codebase could execute it
- Include TypeScript types, field names, function signatures, and SQL details where relevant
- Include before/after code blocks for any step that wraps, reorders, or modifies multi-line JSX/logic — prose descriptions of wrapping are ambiguous and lead to incorrect implementations. For simple prop additions (adding a field to an interface, passing a prop), prose is sufficient.
- When referencing a location in a file, include both the approximate line number AND a textual anchor (e.g., "at line ~407, inside the `renderItems` map callback" or "after the `<ItemContent>` closing tag"). Line numbers drift; textual anchors let the implementer find the correct location even if lines have shifted.
- For every step, identify which resolved design decision it implements — reference it explicitly. If no design doc exists, document the decision inline with rationale.
- Flag any step that touches auth, permissions, billing, or migrations
- Do not introduce patterns not established in the design doc (if one exists) or not verified in the codebase
