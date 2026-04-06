# Deep Research Triggers

Before writing a single step, walk through each phase in the structure outline and ask: *"Can I write every step in this phase with exact file paths, function signatures, prop names, and type definitions — without guessing?"*

For each phase, identify what you do **not** yet know concretely:
- Exact component prop signatures
- Exact function signatures for methods you will call or modify
- Current import structure for files you will edit
- Existing test file structure and factory patterns for tests you will add
- Any intermediate components in a prop-threading chain not yet identified (via research doc or your own lookup)

## Trigger deep research for any of the following:
- A step would need to say "update the component" without specifying which props/fields change
- A prop or type is named but its current definition is unknown
- A threading chain passes through a component not yet identified
- A test needs to be added but the test file's existing factory/setup pattern is unknown (see "Test pattern requirements" below)
- A file is referenced but its current import list is unknown (affects where new imports go)
- A step accesses a data structure (array vs object, field names) that hasn't been verified — e.g., using `Object.keys(x)` on what might be an array, or accessing `.id` without confirming the field exists in the type. Check the research doc first if available; otherwise look up the type definition directly.
- A step derives a value from a collection (first element, key lookup) without confirming the collection's type and shape

## Test pattern requirements:
When adding tests, the plan MUST specify:
- An existing test file to use as a reference pattern (find the nearest sibling test or one in the same feature area)
- The test runner and assertion library (e.g., Jest + RTL, Vitest, etc.)
- Any shared test utilities, factories, or mock helpers used in neighboring tests
- The file naming convention for test files in this area of the codebase

If any of these are unknown, trigger a deep research pass to discover them before writing the plan.

## How to research:
- Read the specific file sections directly using the Read tool with `offset`/`limit` to avoid loading entire large files
- Use the LSP tool (`definition`, `hover`, `references`) to resolve types and find usages — prefer this over grep for navigating code
- Spawn parallel sub-agents for independent lookups:
  - **codebase-analyzer**: understanding a specific method, hook, or data flow
  - **codebase-locator**: finding a file or symbol the research doc did not identify

Do not proceed until every phase has enough concrete detail to write without placeholders. If a gap cannot be resolved through research (e.g., it requires a product decision), surface it to the user before writing the plan.
