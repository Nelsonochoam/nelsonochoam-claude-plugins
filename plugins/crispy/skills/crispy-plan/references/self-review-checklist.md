# Self-Review Checklist

Before presenting the plan and phase docs, run this checklist. Detail lives in the **phase docs** (`phases/phase-N.md`), not in `plan.md`. Validate each phase doc individually.

**Master plan (`plan.md`):**
- [ ] Every phase title matches the structure outline verbatim (or deviation is flagged inline) — skip if no structure outline exists
- [ ] Nothing in "What We're NOT Doing" appears as a phase
- [ ] Phase summary table links to every phase doc
- [ ] Dependency graph is present and consistent with phase doc dependency sections
- [ ] No implementation details (file paths, code blocks, function signatures) in `plan.md` — those belong in phase docs
- [ ] No checkboxes in `plan.md` — progress tracking is done via `manifest.json`

**Each phase doc (`phases/phase-N.md`):**
- [ ] Every resolved design question relevant to this phase is reflected in at least one step — skip if no design doc exists
- [ ] Every file path came from the research doc, a deep research lookup, or direct codebase verification — not inference
- [ ] Every step has enough detail that an engineer unfamiliar with the codebase could execute it without opening another file
- [ ] No step says "update the component" or "modify the function" without naming the exact change
- [ ] Phase has both automated and manual verification criteria
- [ ] Every code snippet or inline code reference uses the correct data structure (array vs object, field names) — cross-check any collection access (e.g., `Object.keys(x)`, `x[0].id`) against the verified type definition (from research doc or direct lookup)
- [ ] Every test step names a specific existing test file as its reference pattern, and specifies the test runner, assertion library, and any shared helpers
- [ ] Every step that wraps, reorders, or modifies multi-line JSX/logic includes a before/after code block — prose-only wrapping instructions are insufficient
- [ ] References section links back to plan.md, intent.md, research.md, design.md
- [ ] Dependencies section lists other phase doc file paths (if any)

If any item fails, do more research (Step 1b) or tighten the step — do not present a plan with known gaps.
