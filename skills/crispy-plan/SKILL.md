---
name: crispy-plan
description: Create a detailed, mechanical implementation plan with exact file paths and success criteria. Works best with prior crispy artifacts (intent, research, design, structure outline) but can also be called directly with an intent or ticket description.
argument-hint: '<paths to crispy feature docs, an intent description, or a ticket reference>'
model: opus
---

User's request: $ARGUMENTS

# Create Implementation Plan

You are tasked with creating a precise, mechanical implementation plan. A good plan leaves nothing to interpretation — when implementation begins, every decision has already been made.

When prior artifacts exist, lean on them: the **structure outline drives the phases**, the **design document drives the decisions**, and the **research document provides the exact file paths, types, and code references**. When some or all are missing, you fill those gaps yourself through codebase research and surface your assumptions explicitly (see "Initial Response" below).

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `plan`
- **No-args fallback**: ask the user what they want to build.
- **Manifest handling**: Note which phases are complete but **do not stop** if prior phases are missing — work with what's available.

Once resolved, read **all** existing artifacts from `<BASE_DIR>/<feature>/`:
- `intent.md` — scope, acceptance criteria, what we're NOT doing
- `research.md` — codebase findings, exact file paths, types, patterns
- `design.md` — resolved design decisions, patterns to follow
- `structure-outline.md` — phase breakdown, dependency chart, key finding

None are strictly required — when called with just a request as the argument, that request IS the intent. Work with whatever is available and surface assumptions where prior work is missing. If the user provided arguments alongside existing artifacts, use the arguments as supplementary context.
## Initial Response

When this command is invoked:

1. **Read whatever artifacts exist** from the feature folder and/or arguments.

2. **If no feature folder exists** (user called with just a request/description):
   - Treat the arguments as the intent
   - Do a full codebase research pass to understand the relevant code
   - Derive design decisions and phase breakdown yourself
   - Surface all assumptions explicitly as "Assumed Decisions" and "Assumed Phase Breakdown"
   - Determine the feature name (ticket ID → kebab-case from request), then run `FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "<feature-name>")` to create the folder and write the plan there
   - Proceed to Step 1

3. **If a feature folder exists but some documents are missing**, present what's available and what's missing before proceeding:
   ```
   Found: [list of documents that exist]
   Missing: [list of documents that don't exist]

   Without [missing doc], I'll need to [what you'll do instead — e.g., "derive phases from the intent and design", "assume file paths and flag them", "make design decisions and surface them as Assumed Decisions"].

   Want me to proceed, or would you prefer to run [relevant phase] first?
   ```
   If the user says proceed, continue to Step 1. Adapt as follows:
   - **No structure outline** → derive phases from design or intent; flag assumptions about phase breakdown
   - **No design doc** → derive decisions from research and intent; flag as "Assumed Decisions"
   - **No research doc** → do a targeted codebase research pass before planning
   - **Only intent** (doc or arguments) → do research, derive design assumptions, and propose a phase breakdown; surface all assumptions explicitly

4. **If all four documents exist** → read them completely and proceed to Step 1.

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

Read `references/deep-research-triggers.md` for the full list of triggers and research methods. Do not proceed to Step 2 until every phase has enough concrete detail to write without placeholders.

### Step 2: Gather Metadata

Before writing, collect:
- Current git branch: `git branch --show-current`
- Current git SHA: `git rev-parse HEAD`
- Repo name: `git remote get-url origin`
- Task/ticket identifier from the intent or design doc (e.g. `tn-3459`). If none exists, derive a kebab-case name from the request (e.g. `add-dark-mode-toggle`).

### Step 3: Self-Review Before Writing

Read and run through `references/self-review-checklist.md`. If any item fails, do more research (Step 1b) or tighten the step. If decisions were assumed (due to missing prior phase artifacts), list them clearly as "Assumed Decisions" at the top of the plan.

### Step 4: Write the Plan to File

Read the template and step entry guidelines from `references/template.md`. Write the plan to `$FEATURE_PATH/plan.md` (the directory is already created via `ensure-feature.sh`).

Then say:

```
Written to <BASE_DIR>/<feature>/plan.md — please review.
Does this look correct and complete? Any steps that need more detail,
anything to add or remove, or phases to reorder?
```

Wait for the user's response.

### Step 5: Iterate Until Confirmed

If the user requests changes:
- Do a targeted lookup if more detail is needed, then edit the file with the Edit tool.
- If a step is added, check it against "What We're NOT Doing" — flag if it conflicts with a resolved decision.
- If phases are reordered, flag any dependency that makes the reorder unsafe.
- Re-prompt for review after each change. Do not reprint the full plan to the conversation.

Once the user explicitly confirms, update the manifest's `plan` phase to `done` with today's date and the file path. Then proceed to Step 6.

### Step 6: Generate Implementation Tasks

Spawn a **subagent** to generate the task files and update the manifest. This keeps the main context focused on the plan while the subagent handles the mechanical task breakdown.

**Subagent instructions:**

> Read `references/generate-tasks.md` and follow its instructions exactly. Use these inputs:
> - Plan path: `<BASE_DIR>/<feature>/plan.md`
> - Feature directory: `<BASE_DIR>/<feature>/`
> - Feature name: `<feature>` (from manifest.json)
> - Structure outline: `<BASE_DIR>/<feature>/structure-outline.md` (if it exists)

Wait for the subagent to complete, then say:

```
Plan confirmed. {N} implementation tasks generated in <BASE_DIR>/<feature>/tasks/.

Run /implement to execute the next ready phase, or:
- `/implement phase-N` to target a specific phase

Each task file is a self-contained prompt with its own dependencies.
Use them however you prefer: sequential /implement calls, separate sessions,
worktrees, Claude tasks, or as Jira ticket descriptions.
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
