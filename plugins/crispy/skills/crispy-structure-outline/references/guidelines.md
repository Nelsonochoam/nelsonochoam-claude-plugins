# Structure Outline Guidelines

- **Phases deliver behavior, not layers**: "Add product count guard to KB search and updates sections" not "all UI changes"
- **Header file, not implementation**: Name the specific functions, props, and identifiers that change, but not the full body. "Update `showProducts` prop on `KnowledgeBaseSearchTable` to derive from `isMultiProduct`" — not "update the component" (too vague) and not the full JSX diff (too detailed)
- **One sentence per phase header**: Describes what the phase delivers. The File Changes section fills in the shape.
- **Each phase is a shippable vertical slice**: It must include the tests for the behavior it introduces. Never defer tests to a later phase — a phase without tests is not independently shippable
- **Tests section is mandatory per phase**: List the test files (new or existing) and the specific cases they cover, at the same level of detail as File Changes
- **Validation has three parts**: An automated command (typecheck, lint, test — include the test run for this phase's tests) in a code block, then numbered manual steps describing user-facing behavior to verify
- **Parallelize when possible**: After sequencing phases, look for adjacent phases with no shared file or data dependency. Group them under a `## Phases N–M: <Group title> *(can be done in parallel)*` header with a one-line note explaining they are independent. Reflect this in the Status count: "4 phases (2 sequential, 2 parallel)".
- **Key Finding is opinionated**: It should tell the developer something that changes how they think about the work — not just restate the design
- **Open Questions belong here**: If something is unresolved that affects phasing, surface it — don't silently omit a phase
