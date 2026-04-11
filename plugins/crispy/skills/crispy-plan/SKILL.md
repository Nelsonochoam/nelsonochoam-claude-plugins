---
name: crispy-plan
description: Create a detailed, mechanical implementation plan with exact file paths and success criteria. Works best with prior crispy artifacts (intent, research, design, structure outline) but can also be called directly with an intent or ticket description.
disable-model-invocation: true
model: opus
---

User's request: $ARGUMENTS

# Create Implementation Plan

You are tasked with creating a precise, mechanical implementation plan. A good plan leaves nothing to interpretation — when implementation begins, every decision has already been made.

When all prior artifacts are available, the **structure outline drives the phases**, the **design document drives the decisions**, and the **research document provides the exact file paths, types, and code references**. When some are missing, you derive what you need through codebase exploration and user collaboration.

## Input Resolution

Run feature-discovery (`${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`) with current phase `plan` to resolve `$FEATURE_PATH`.

**After feature discovery**, run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `plan`. If the check halts, stop here.

**Auto-advance**: If `$ARGUMENTS` contains `--autoadvance`, follow the auto-advance protocol in the prerequisite check reference before proceeding. Strip `--autoadvance` from arguments before using them as context.

If `$ARGUMENTS` contains additional context alongside feature folder artifacts, incorporate it as supplementary input.

## Check for Existing Plan

After resolving `$FEATURE_PATH`, check if `$FEATURE_PATH/plan.md` already exists.

- **Existing plan**: If `plan.md` exists, ask the user whether they want to **re-plan from scratch** (deletes existing `plan.md`, `manifest.json`, and `phases/` directory) or **edit the existing plan** (read the current plan and phase docs, make targeted edits based on what changed). If the user chooses to edit, read the existing plan and phase docs, discuss changes with the user, apply edits, and skip to "Iterate Until Confirmed." If re-planning, delete the old artifacts and continue below.

## Load Context Based on Available Artifacts

Check whether `design.md` exists and read the matching reference:

- **`design.md` exists** → read and follow `${CLAUDE_SKILL_DIR}/references/with-design.md`
- **No `design.md`** → read and follow `${CLAUDE_SKILL_DIR}/references/without-design.md`

Read **only** the reference that matches — do not read the other.

Follow the steps in that reference through context loading, research, and (if applicable) design decision resolution. Then continue with the steps below.

## Gather Metadata

Before writing, collect:
- Task/ticket identifier from the intent or design doc (e.g. `tn-3459`). If none exists, derive a kebab-case name from the request (e.g. `add-dark-mode-toggle`).

## Self-Review Before Writing

Read and run through `${CLAUDE_SKILL_DIR}/references/self-review-checklist.md`. If any item fails, do more research or tighten the step.

## Write the Plan and Phase Docs (Single Pass)

This step produces **all plan artifacts at once**: the master index (`plan.md`) and individual phase docs (`phases/phase-N.md`).

### Create the phases directory

Create `$FEATURE_PATH/phases/` if it doesn't exist.

### Write the phase docs first

Read the phase template from `${CLAUDE_SKILL_DIR}/references/phase-template.md`. For each phase, write a self-sufficient phase doc to `$FEATURE_PATH/phases/phase-{N}.md`.

Each phase doc must contain:
- All implementation details for that phase (exact file paths, code blocks, function signatures, design decisions applied)
- References linking back to `plan.md`, `intent.md`, `research.md`, `design.md`
- Dependency references as file paths to other phase docs (e.g., `[Phase 1: <title>](phases/phase-1.md)`)
- Per-phase success criteria (automated + manual)

**An agent reading only the phase doc must have everything it needs to implement the phase.**

### Write the master plan index

Read the plan template from `${CLAUDE_SKILL_DIR}/references/template.md`. Write the plan to `$FEATURE_PATH/plan.md`.

The plan is a **lightweight master index** — it contains the overview, dependency graph, phase summary table with links to phase docs, and global success criteria. It does **not** contain implementation details or checkboxes.

Then say:

```
Written to $FEATURE_PATH/plan.md and {N} phase docs in $FEATURE_PATH/phases/ — please review.
```

## Iterate Until Confirmed

If the user requests changes:
- Do a targeted lookup if more detail is needed, then edit the relevant file (plan.md or the specific phase doc) with the Edit tool.
- If a step is added, check it against "What We're NOT Doing" — flag if it conflicts with a resolved decision.
- If phases are reordered, flag any dependency that makes the reorder unsafe.
- Re-prompt for review after each change. Do not reprint the full plan to the conversation.

Once the user explicitly confirms, proceed to Create Manifest.

## Create Manifest

Once the user confirms the plan, create (or replace) `$FEATURE_PATH/manifest.json` with only the implementation phases:

```json
{
  "implementation": {
    "phase-1": {
      "name": "Phase 1: <title>",
      "status": "pending",
      "dependencies": [],
      "file": "<FEATURE_PATH>/phases/phase-1.md"
    },
    "phase-2": {
      "name": "Phase 2: <title>",
      "status": "pending",
      "dependencies": ["phase-1"],
      "file": "<FEATURE_PATH>/phases/phase-2.md"
    }
  }
}
```

Dependencies come from the structure outline's dependency chart (if it exists), otherwise assume sequential.

Then say:

```
════════════════════════════════════════
✓ Plan confirmed. {N} phase docs generated in $FEATURE_PATH/phases/.

Recommended next: /crispy-implement
Any phase can follow — each works with whatever artifacts exist.
════════════════════════════════════════
```

## Important Guidelines

1. **Phases come from the structure outline when it exists**: Do not invent a different breakdown. If the outline has 3 phases, the plan has 3 phases. If you believe a phase should be split, flag it and ask before doing so. When no structure outline exists, derive phases yourself.
2. **Decisions come from the design doc when it exists**: Every resolved design question is closed. Reflect it in the plan; do not re-open it or substitute an alternative. When no design doc exists, surface decisions and resolve them with the user before writing the plan.
3. **File paths must be verified**: Never guess a path. Use the research doc when available; otherwise do a direct codebase lookup. Every path in the plan must come from a verified source.
4. **No gaps in the final plan**: Every step must be concrete enough to execute without opening another file. If something is unresolved, do a deep research pass or ask the user. Do not write a plan with placeholders like "update the component" or "add the necessary props."
5. **Read files completely**: Never use limit/offset when reading files for this plan.
6. **Separate automated from manual verification**: Every phase must have both categories.
7. **Scope the targeted research**: Use sub-agents for gaps only — do not re-research what prior phases already covered.
8. **Confirm structure before details**: If the phase structure has changed from the structural outline (or if you derived it yourself), flag it and get alignment before writing step-level detail.
