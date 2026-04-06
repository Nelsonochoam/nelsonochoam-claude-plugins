---
name: crispy-implement
description: Implement an approved plan phase by phase, with verification after each phase and explicit stops when reality does not match the plan.
argument-hint: '<optional: phase-N to target a specific phase>'
disable-model-invocation: true
---

User's request: $ARGUMENTS

# Implement Plan

You are tasked with implementing an approved implementation plan from the Plan phase. These plans contain phases with specific changes and success criteria.

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `implement`
- **No-args fallback**: ask the user to provide a plan document to implement.
- **Manifest handling**: Confirm the previous phase (`plan`) is done. If not, stop and tell the user — implementation without a confirmed plan is high risk.

Once resolved, read `$FEATURE_PATH/plan.md` as the plan to implement. If the user also provided a path as an argument, use that instead.

## Getting Started

When given a plan:

- Read the plan completely — never use limit/offset parameters, you need full context
- Read `manifest.json` and check for a `tasks` key
- Read all files the plan says you will modify, also completely
- Think deeply about how the pieces fit together
- Create a todo list to track your progress through the phases

If no plan is provided, ask for one.

## Execution Mode

Determine the execution mode from the user's arguments:

### Default (no arguments) — Sequential, one phase at a time

If `manifest.json` has a `tasks` key, use it to determine the next phase:
1. Find the first task where `status` is `"pending"` and all entries in `dependencies` have status `"done"`
2. Set that task's status to `"in-progress"` in `manifest.json`
3. Implement **only that phase**
4. After verification, set the task's status to `"done"`
5. **Stop and wait for the user** — do not automatically proceed to the next phase

This is the ralph-loop style: one phase per invocation, clean context boundaries. The user decides whether to continue in this session, start a fresh session, or do something else entirely.

If `manifest.json` has no `tasks` key (older plans without task generation), fall back to checkpoint-based behavior: read `plan.md`, check for existing checkmarks (`- [x]`), and implement the next unchecked phase.

### Targeted (`phase-N` argument)

When the user passes a specific phase (e.g., `/crispy-implement phase-2`):
1. Read the matching task from `manifest.json`
2. Verify all its `dependencies` have status `"done"`. If not, report which dependencies are incomplete and **stop**.
3. Read the task file from the path in `tasks.phase-N.file` for additional context
4. If dependencies are met, implement only that phase
5. After verification, set the task's status to `"done"`

This is the mode an agent working from a task file — in a separate session, worktree, or from a ticket — would use.

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:
- Follow the plan's intent while adapting to what you find in the codebase
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context
- Update checkboxes in the plan as you complete sections using the Edit tool

The plan is your guide, but your judgment matters too. When things don't match exactly, think about why and communicate clearly rather than silently improvising.

If you encounter a mismatch, stop and present it:

```
Issue in Phase [N]:
Expected: [what the plan says]
Found: [actual situation in the codebase]
Why this matters: [explanation]

How should I proceed?
```

## Verification Approach

After completing each phase:

1. **Run the success criteria checks** specified in the plan — fix any failures before proceeding
2. **Check off completed items** in the plan file using the Edit tool — update `- [ ]` to `- [x]` for each completed item, then check off the phase header once everything passes
3. **Update the manifest**:
   - Set `tasks.phase-N.status` to `"done"` in `manifest.json` (if tasks exist)
   - Update the `implement` phase status to reflect progress (e.g., `in-progress (Phase 2/4)`)
4. **Pause for manual verification**:

```
Phase [N] Complete — Ready for Manual Verification

Automated verification passed:
- [list checks that passed]

Please verify manually:
- [ ] [manual step from the plan]
- [ ] [manual step from the plan]

Let me know when manual testing is complete so I can proceed to Phase [N+1].
```

Do not check off manual items until the user confirms them. If instructed to execute multiple phases consecutively, skip the pause until the last phase.

## Resuming Work

When resuming (new session or continuing):
- Read `manifest.json` tasks to determine which phases are complete — this is the source of truth
- Cross-reference with checkboxes in `plan.md` for consistency
- Pick up from the first eligible pending task (all dependencies met)
- If a task is `"in-progress"`, resume it — check existing checkboxes in `plan.md` for that phase to see what was already done
- Trust that completed work is done; verify previous work only if something seems off

## If You Get Stuck

When something isn't working as expected:
- Make sure you've read and understood all relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-agents sparingly — mainly for targeted debugging or exploring unfamiliar territory.

## Completion

When all phases are complete and all verifications pass (all tasks in `manifest.json` have status `"done"`, or all checkboxes in `plan.md` are checked if no tasks exist):

1. Present a completion summary:
   ```
   Implementation Complete

   Automated verification:
   - [x] [checks that passed]

   Manual verification required:
   - [ ] <from plan>
   ```

2. **Update the manifest**: Set the `implement` phase to `done` with today's date.

3. Hand off:
   ```
   Implementation complete. Ready to ship when manual verification passes.
   Use /ship to commit and create a PR.
   ```

## Guidelines

- **Do not add unrequested features**: Only implement what the plan specifies
- **Do not clean up adjacent code**: Resist the urge to refactor surrounding code while implementing
- **Read files completely**: Never use limit/offset when reading files
- **Keep forward momentum**: The goal is working software, not perfect process adherence
- **Verify after each phase**: Catch issues at the phase boundary where they are easiest to diagnose
