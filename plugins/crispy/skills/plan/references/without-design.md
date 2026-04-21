# Planning Without Design Document

No `4-design.md` exists — design decisions have not been made yet. Before writing a plan, you need to surface decision points and resolve them with the user.

## Step 1: Load Context and Explore

Read whatever exists:
1. The Intent Document or user's request arguments (acceptance criteria, scope, what we're not doing)
2. The Structure Outline Document (if it exists — phase names, goals, key finding)
3. The Research Document (if it exists — exact file paths, types, existing code patterns)

**Read all files completely** — no limit or offset parameters.

After reading, extract:
- **Phases**: From the structure outline if it exists, otherwise derive from intent.
- **File references**: From the research doc if it exists, otherwise resolve through codebase lookup.
- **Out of scope**: From the intent doc's "What we're NOT doing" — anything listed there must not appear in the plan.

## Step 1b: Codebase Exploration and Research

Explore the codebase to understand what exists. Look up exact file paths, function signatures, existing patterns, and test conventions. Use the Read tool for targeted file reads and spawn parallel sub-agents for independent lookups.

As you explore, identify design decision points — places where more than one reasonable approach exists. These typically include:
- Architecture choices (where to put new code, which patterns to follow)
- Data modeling decisions (schema changes, state shape)
- API design (endpoints, contracts, error handling)
- Integration points (how new code connects to existing systems)
- Trade-offs (performance vs simplicity, DRY vs explicit)

## Step 2: Present Decision Points

Before writing any plan, present the design decisions to the user. For each decision point:

```
### [Decision Topic]

**Context:** [What you found in the codebase that makes this a decision]

**Options:**
1. [Option A] — [brief description and trade-off]
2. [Option B] — [brief description and trade-off]

**Recommendation:** [Which option and why, based on codebase patterns]
```

Group related decisions together. Present all decision points at once so the user can see the full picture.

Then ask:

```
These are the key decisions I need resolved before writing the plan.
Pick options, combine ideas, or suggest different approaches — these are starting points for discussion, not a closed list.
```

**Wait for the user to respond.** Do not proceed until all decisions are resolved.

## Step 2b: Account for Prior Implementation

If `manifest.json` exists with phases that have status `"done"`, prior implementation work has been completed. Present this to the user:

```
Prior implementation found:
- [x] Phase 1: <title> (done)
- [x] Phase 2: <title> (done)
- [ ] Phase 3: <title> (pending)

Which completed phases are still valid? Should any be re-done given the refined intent?
```

**Wait for the user to confirm** which completed work is still valid before writing the plan. Factor their answer into the phase breakdown — phases the user considers still valid can be referenced as done, while invalidated phases need to be re-planned.

If no `manifest.json` exists, skip this step.

## Step 2c: Scope Verification

Per-phase file-level research (exact function signatures, prop types, import lists, test patterns, data shapes) is delegated to each phase's subagent — do not do broad codebase exploration here.

Only do a narrow targeted lookup if a resolved design decision depends on knowing a specific API shape or if a phase's scope remains structurally ambiguous after the exploration in Step 1b. Resolve those gaps, then proceed.
