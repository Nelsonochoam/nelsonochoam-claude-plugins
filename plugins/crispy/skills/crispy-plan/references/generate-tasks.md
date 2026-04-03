# Generate Implementation Tasks

You are a subagent tasked with generating self-contained task files from a confirmed implementation plan. Each task file corresponds to one plan phase and can be executed independently — in a session, a worktree, a Jira ticket, or via ralph-loop.

## Inputs

You will be given:
- **Plan path**: the confirmed `plan.md` file
- **Feature directory**: the `.crispy/<feature>/` path
- **Feature name**: from `manifest.json`
- **Structure outline path** (if it exists): contains the dependency chart

## Steps

### 1. Read the Plan

Read `plan.md` completely. Identify all phases — each phase header matching `- [ ] **Phase N: <title>**` is one task.

### 2. Read the Dependency Chart

If `structure-outline.md` exists, read its "Dependency Chart" section. Parse which phases are sequential, parallel, and convergent.

If no structure outline exists, assume all phases are sequential (each depends on the previous one).

### 3. Create the Tasks Directory

Create `<feature-dir>/tasks/` if it doesn't exist.

### 4. For Each Phase, Generate a Task File

Write a file to `<feature-dir>/tasks/phase-{N}.md` using this template:

````markdown
---
task: phase-{N}
feature: {feature}
phase: "{phase_title}"
dependencies: {dependencies_yaml}
---

# Phase {N}: {phase_title}

## Context

Read these files from `{feature_dir}/` before starting:
- `intent.md` — scope, acceptance criteria, and what is out of scope
- `plan.md` — full implementation plan; focus on Phase {N} but read the full plan for context
- `research.md` — codebase findings with exact file paths (if it exists)

Read all files completely — no limit/offset parameters.

## Your Task

Implement **only Phase {N}** from the plan. The plan contains exact file paths, function signatures, and step-by-step changes for this phase. Follow them mechanically.

{phase_summary}

## Dependencies

{dependency_note}

## Verification

After completing all changes:

1. Run the automated checks specified in Phase {N}'s success criteria
2. Fix any failures before reporting completion
3. Update `plan.md` — check off completed items (`- [ ]` → `- [x]`) for Phase {N} only
4. Update `manifest.json` — set `tasks.phase-{N}.status` to `"done"` and update `implement.status` to reflect progress
5. Report what was done, what checks passed, and list any manual verification steps the user should perform

## Guidelines

- Only implement what Phase {N} specifies — do not touch other phases
- If reality does not match the plan, stop and report the mismatch rather than improvising
- Read files completely — no limit/offset parameters
- Do not refactor adjacent code or add unrequested features
````

### Filling In Placeholders

| Placeholder | Source |
|---|---|
| `{N}` | Phase number from the plan |
| `{feature}` | Feature name from `manifest.json` |
| `{feature_dir}` | Path to `.crispy/<feature>/` relative to repo root |
| `{phase_title}` | Full phase title from the plan (e.g., "Add status field to Questionnaire model") |
| `{phase_summary}` | 2–3 sentence summary from the phase's "Overview" section in the plan |
| `{dependencies_yaml}` | YAML list of dependency IDs, e.g., `[phase-1]` or `[]` |
| `{dependency_note}` | See below |

**Dependency note:**
- If `dependencies` is empty: `"This phase has no dependencies and can start immediately."`
- If `dependencies` is non-empty: `"This phase depends on: {list}. Before starting, verify those tasks are complete by checking their status in manifest.json. If any dependency is not done, stop and report which ones are incomplete."`

### 5. Update manifest.json

Add a `"tasks"` key (sibling to `"phases"`) in `manifest.json` with one entry per phase:

```json
{
  "tasks": {
    "phase-1": {
      "name": "Phase 1: <title from plan>",
      "status": "pending",
      "dependencies": [],
      "file": ".crispy/<feature>/tasks/phase-1.md"
    },
    "phase-2": {
      "name": "Phase 2: <title from plan>",
      "status": "pending",
      "dependencies": ["phase-1"],
      "file": ".crispy/<feature>/tasks/phase-2.md"
    }
  }
}
```

### 6. Report Back

When done, report the number of tasks generated and list them with their dependencies.
