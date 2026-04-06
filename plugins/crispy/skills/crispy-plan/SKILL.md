---
name: crispy-plan
description: Create a detailed, mechanical implementation plan with exact file paths and success criteria. Works best with prior crispy artifacts (intent, research, design, structure outline) but can also be called directly with an intent or ticket description.
disable-model-invocation: true
model: opus
---

User's request: $ARGUMENTS

# Create Implementation Plan

You are tasked with creating a precise, mechanical implementation plan. A good plan leaves nothing to interpretation — when implementation begins, every decision has already been made.

The **structure outline drives the phases**, the **design document drives the decisions**, and the **research document provides the exact file paths, types, and code references**. All prior artifacts are required.

## Input Resolution

Run feature-discovery (`${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`) with current phase `plan` to resolve `$FEATURE_PATH`.

**After feature discovery**, run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `plan`. If the check halts, stop here.

Once all prerequisites are confirmed, read all four artifacts completely:
- `$FEATURE_PATH/intent.md`
- `$FEATURE_PATH/research.md`
- `$FEATURE_PATH/design.md`
- `$FEATURE_PATH/structure-outline.md`

If `$ARGUMENTS` contains additional context alongside feature folder artifacts, incorporate it as supplementary input.

## Process Steps

### Step 1: Load All Context

Read whatever exists, in this order:
1. The Intent Document or user's request arguments (acceptance criteria, scope, what we're not doing)
2. The Design Document (resolved design questions, patterns to follow)
3. The Structure Outline Document (phase names, phase goals, key finding, open questions)
4. The Research Document (exact file paths, types, existing code patterns, test locations)

**Read all files completely** — no limit or offset parameters. If the intent is the user's arguments (no `intent.md`), treat the arguments as the source of truth for scope.

After reading, extract and hold in mind (skip items whose source doc doesn't exist):
- **Phases**: Take the phase list verbatim from the structure outline. Do not add, remove, or reorder phases without flagging it first. If no structure outline exists, derive phases from the design or intent and flag as "Assumed Phase Breakdown."
- **Resolved decisions**: From the design doc — every resolved question is a closed decision that must be reflected in the plan as-is. If no design doc exists, make design decisions through codebase research and flag as "Assumed Decisions."
- **Patterns**: From the design doc's "Patterns to follow" section — each step should mirror these patterns, not invent new ones. If no design doc exists, discover patterns from the codebase directly.
- **File references**: From the research doc — use these exact paths and line numbers in each step entry. If no research doc exists, resolve all file paths through direct codebase lookup before writing the plan.
- **Out of scope**: From the intent doc's "What we're NOT doing" — anything listed there must not appear in the plan.

### Step 1b: Deep Research Pass

Read `${CLAUDE_SKILL_DIR}/references/deep-research-triggers.md` for the full list of triggers and research methods. Do not proceed to Step 2 until every phase has enough concrete detail to write without placeholders.

### Step 2: Gather Metadata

Before writing, collect:
- Task/ticket identifier from the intent or design doc (e.g. `tn-3459`). If none exists, derive a kebab-case name from the request (e.g. `add-dark-mode-toggle`).

### Step 3: Self-Review Before Writing

Read and run through `${CLAUDE_SKILL_DIR}/references/self-review-checklist.md`. If any item fails, do more research (Step 1b) or tighten the step. If decisions were assumed (due to missing prior phase artifacts), list them clearly as "Assumed Decisions" at the top of the plan.

### Step 4: Write the Plan and Phase Docs (Single Pass)

This step produces **all plan artifacts at once**: the master index (`plan.md`) and individual phase docs (`phases/phase-N.md`).

#### 4a. Create the phases directory

Create `$FEATURE_PATH/phases/` if it doesn't exist.

#### 4b. Write the phase docs first

Read the phase template from `${CLAUDE_SKILL_DIR}/references/phase-template.md`. For each phase, write a self-sufficient phase doc to `$FEATURE_PATH/phases/phase-{N}.md`.

Each phase doc must contain:
- All implementation details for that phase (exact file paths, code blocks, function signatures, design decisions applied)
- References linking back to `plan.md`, `intent.md`, `research.md`, `design.md`
- Dependency references as file paths to other phase docs (e.g., `[Phase 1: <title>](phases/phase-1.md)`)
- Per-phase success criteria (automated + manual)

**An agent reading only the phase doc must have everything it needs to implement the phase.**

#### 4c. Write the master plan index

Read the plan template from `${CLAUDE_SKILL_DIR}/references/template.md`. Write the plan to `$FEATURE_PATH/plan.md`.

The plan is a **lightweight master index** — it contains the overview, dependency graph, phase summary table with links to phase docs, and global success criteria. It does **not** contain implementation details or checkboxes.

Then say:

```
Written to $FEATURE_PATH/plan.md and {N} phase docs in $FEATURE_PATH/phases/ — please review.
```

### Step 5: Iterate Until Confirmed

If the user requests changes:
- Do a targeted lookup if more detail is needed, then edit the relevant file (plan.md or the specific phase doc) with the Edit tool.
- If a step is added, check it against "What We're NOT Doing" — flag if it conflicts with a resolved decision.
- If phases are reordered, flag any dependency that makes the reorder unsafe.
- Re-prompt for review after each change. Do not reprint the full plan to the conversation.

Once the user explicitly confirms, proceed to Step 6.

### Step 6: Update Manifest

Update `manifest.json` directly:

1. Set the `plan` phase to `done` with today's date and file path.
2. Add (or replace) the `"implementation"` key with one entry per phase:

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
Plan confirmed. {N} phase docs generated in $FEATURE_PATH/phases/.

Run /crispy-implement to execute the next ready phase, or:
- `/crispy-implement phase-N` to target a specific phase
```

## Important Guidelines

1. **Phases come from the structure outline when it exists**: Do not invent a different breakdown. If the outline has 3 phases, the plan has 3 phases. If you believe a phase should be split, flag it and ask before doing so. When no structure outline exists, derive phases yourself and flag as "Assumed Phase Breakdown."
2. **Decisions come from the design doc when it exists**: Every resolved design question is closed. Reflect it in the plan; do not re-open it or substitute an alternative. When no design doc exists, make decisions through research and flag as "Assumed Decisions."
3. **File paths must be verified**: Never guess a path. Use the research doc when available; otherwise do a direct codebase lookup. Every path in the plan must come from a verified source.
4. **No gaps in the final plan**: Every step must be concrete enough to execute without opening another file. If something is unresolved, do a deep research pass (Step 1b) or ask the user. Do not write a plan with placeholders like "update the component" or "add the necessary props."
5. **Read files completely**: Never use limit/offset when reading files for this plan.
6. **Separate automated from manual verification**: Every phase must have both categories.
7. **Scope the targeted research**: Use sub-agents for gaps only — do not re-research what prior phases already covered.
8. **Confirm structure before details**: If the phase structure has changed from the structural outline (or if you derived it yourself), flag it and get alignment before writing step-level detail.
