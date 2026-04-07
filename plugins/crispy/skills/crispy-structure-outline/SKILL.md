---
name: crispy-structure-outline
description: Break the approved design into phases and write a structure outline document.
disable-model-invocation: true
model: opus
---

User's request: $ARGUMENTS

# Structure the Work

You are tasked with reading the design document and breaking the work into clear phases — each one a coherent chunk of work with a specific goal. This is not a detailed plan. It is a breakdown of the order and shape of the work before implementation details are written.

## Input Resolution

Run feature-discovery (`${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`) with current phase `structure` to resolve `$FEATURE_PATH`.

Collect context from both sources, then merge:

**Before reading artifacts**, run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `structure`. If the check halts, stop here.

1. **Feature folder** — read any available artifacts from `$FEATURE_PATH/`: `design.md`, `intent.md`, `research.md`.
   - `design.md` is the primary input. `intent.md` and `research.md` provide supporting context — include them when present.
2. **Arguments** — if `$ARGUMENTS` contains file paths or additional context, read and incorporate them.
   - Treat arguments as supplementary context that extends or clarifies what is in the feature folder.

## Steps

### 1. Identify the Phases

Read all three documents:
- **Intent**: use the acceptance criteria to understand what "done" looks like and what's explicitly out of scope
- **Research**: use the file references and codebase findings to identify which files are actually involved and how they connect — this determines the realistic shape of each phase
- **Design**: use the resolved decisions and patterns to understand what approach each phase must follow

Determine the natural breakdown of work. Each phase should:
- Represent a coherent, focused chunk of work with a single goal
- Be completable and reviewable before the next phase starts
- Include its own tests — unit or integration tests for the behavior introduced in that phase belong in the same phase, not in a separate testing phase
- Be independently shippable to production as a vertical slice of functionality

Avoid horizontal layers ("all DB changes", "all UI changes"). Prefer phases that deliver one complete piece of behavior, including the tests that cover it. Never create a standalone "Tests" phase — tests for a phase belong inside that phase.

**Parallelization**: After identifying phases, look for opportunities where two or more phases have no dependency on each other and can be worked on simultaneously. Group these into a parallel set. Phases within a parallel set can be started at the same time by different developers or sequentially by one developer in any order — they must not depend on each other's output. Phases outside the parallel set must be sequenced.

Think of the structure outline as the **C header file** to the plan's implementation. For each phase:
- List the files that change with bullet points describing *what* changes — name the functions, props, and identifiers involved, but not the full implementation
- Include the automated check command and numbered manual steps a developer would run to verify the phase

The right level of detail: "Update `continueSession` action to pass `interrupt: false` to the unified endpoint" — not "modify the action" (too vague) and not the full function body (too detailed).

### 2. Identify the Key Finding

Look across all three documents for the most important orienting fact — the thing that most changes how you think about the scope or approach. This might be:
- Existing infrastructure that reduces the work significantly
- A dependency or constraint that shapes the phases
- A risk or unknown that needs to be resolved early

### 3. Gather Metadata

Collect:
- Ticket/task identifier from the design document (e.g. `ticket-1234`)

### 4. Write the Structure Outline

Read the template from `${CLAUDE_SKILL_DIR}/references/template.md`. Write the outline to `$FEATURE_PATH/structure-outline.md` (create the directory if needed).

Then say:

```
Written to $FEATURE_PATH/structure-outline.md — please review.
Do these phases look right? Anything to reorder, split, or collapse before planning?
```

Wait for the user's response.

### 5. Iterate Until Confirmed

If the user requests changes, edit the file directly using the Edit tool. Re-prompt for review. Do not reprint the full outline to the conversation.

Then say:

```
Structure confirmed. Run /crispy-plan to write the detailed implementation plan.
```

## Guidelines

Before presenting the outline, read `${CLAUDE_SKILL_DIR}/references/guidelines.md` for the full set of quality guidelines to follow.
