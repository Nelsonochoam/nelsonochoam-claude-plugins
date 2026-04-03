# Self-Review Checklist

Before presenting the plan, run this checklist:

- [ ] Every phase title matches the structure outline verbatim (or deviation is flagged inline) — skip if no structure outline exists
- [ ] Every resolved design question from the design doc is reflected in at least one step — skip if no design doc exists
- [ ] Nothing in "What We're NOT Doing" appears as a step
- [ ] Every file path came from the research doc, a deep research lookup, or direct codebase verification — not inference
- [ ] Every step has enough detail that an engineer unfamiliar with the codebase could execute it without opening another file
- [ ] No step says "update the component" or "modify the function" without naming the exact change
- [ ] Every phase has both automated and manual verification criteria
- [ ] Every code snippet or inline code reference uses the correct data structure (array vs object, field names) — cross-check any collection access (e.g., `Object.keys(x)`, `x[0].id`) against the verified type definition (from research doc or direct lookup)
- [ ] Every test step names a specific existing test file as its reference pattern, and specifies the test runner, assertion library, and any shared helpers
- [ ] Every step that wraps, reorders, or modifies multi-line JSX/logic includes a before/after code block — prose-only wrapping instructions are insufficient

If any item fails, do more research (Step 1b) or tighten the step — do not present a plan with known gaps.
