---
name: crispy-implement
description: Implement an approved plan phase by phase, with verification after each phase and explicit stops when reality does not match the plan.
argument-hint: '<optional: phase-N to target a specific phase>'
disable-model-invocation: true
---

User's request: $ARGUMENTS

# Implement Plan

You are tasked with implementing an approved implementation plan from the Plan phase. The plan is a master index; the actual implementation details live in self-sufficient phase docs under `phases/`.

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `implement`
- **No-args fallback**: ask the user to provide a plan document to implement.
- **Manifest handling**: Run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `implement`. If the check halts, stop here.

Once resolved, read `$FEATURE_PATH/plan.md` for an overview of the feature and its phases. The plan is a lightweight index — the detailed implementation steps are in the phase docs.

## Getting Started

When starting implementation:

- Read `plan.md` for the overview, dependency graph, and phase summary table
- Read `manifest.json` and check for an `implementation` key
- Determine which phase to work on (see Execution Mode below)
- Read that phase's doc from `$FEATURE_PATH/phases/phase-N.md` — it contains all implementation details
- Read all files the phase doc says you will modify, completely
- Think deeply about how the pieces fit together
- Create a todo list to track your progress through the phase's changes

## Execution Mode

Determine the execution mode from the user's arguments:

### Default (no arguments) — Sequential, one phase at a time

Use `next-phase.sh` to determine the next workable phase:

```bash
NEXT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/next-phase.sh" "$FEATURE_PATH")
```

The script returns JSON with `found`, `id`, `name`, `file`, and `reason` fields.

If `found` is `true`:
1. Set that phase's status to `"in-progress"` in `manifest.json` (`implementation.phase-N.status`)
2. Read the phase doc from the `file` path — it is self-sufficient with all implementation details
3. Implement **only that phase**
4. After verification, set the phase's status to `"done"`
5. **Stop and wait for the user** — do not automatically proceed to the next phase

If `found` is `false`:
- `reason: "all_done"` — all phases are complete, proceed to Completion
- `reason: "blocked"` — report which dependencies are blocking and stop
- `reason: "no_implementation_key"` — fall back: read `plan.md` and implement the next unchecked phase

This is the ralph-loop style: one phase per invocation, clean context boundaries. The user decides whether to continue in this session, start a fresh session, or do something else entirely.

### Targeted (`phase-N` argument)

When the user passes a specific phase (e.g., `/crispy-implement phase-2`):
1. Read the matching entry from `manifest.json` (`implementation.phase-2`)
2. Verify all its `dependencies` have status `"done"`. If not, report which dependencies are incomplete and **stop**.
3. Read the phase doc from `implementation.phase-2.file` — it contains all implementation details
4. If dependencies are met, implement only that phase
5. After verification, set the phase's status to `"done"`

This is the mode an agent working from a phase doc — in a separate session, worktree, or from a ticket — would use.

## Implementation Philosophy

Plans are carefully designed, but reality can be messy. Your job is to:
- Follow the phase doc's intent while adapting to what you find in the codebase
- Implement each phase fully before moving to the next
- Verify your work makes sense in the broader codebase context

The phase doc is your guide, but your judgment matters too. When things don't match exactly, think about why and communicate clearly rather than silently improvising.

If you encounter a mismatch, stop and present it:

```
Issue in Phase [N]:
Expected: [what the phase doc says]
Found: [actual situation in the codebase]
Why this matters: [explanation]

How should I proceed?
```

## Verification Approach

After completing each phase:

1. **Run the success criteria checks** specified in the phase doc — fix any failures before proceeding
2. **Update the manifest**:
   - Set `implementation.phase-N.status` to `"done"` in `manifest.json`
   - Update the `implement` phase status to reflect progress (e.g., `in-progress (Phase 2/4)`)
3. **Pause for manual verification**:

```
Phase [N] Complete — Ready for Manual Verification

Automated verification passed:
- [list checks that passed]

Please verify manually:
- [ ] [manual step from the phase doc]
- [ ] [manual step from the phase doc]

Let me know when manual testing is complete so I can proceed to Phase [N+1].
```

Do not check off manual items until the user confirms them. If instructed to execute multiple phases consecutively, skip the pause until the last phase.

## Resuming Work

When resuming (new session or continuing):
- Run `next-phase.sh` to determine which phase to work on next — `manifest.json` is the source of truth
- If a phase is `"in-progress"`, resume it — review the codebase state to determine what was already done
- Trust that completed work is done; verify previous work only if something seems off

## If You Get Stuck

When something isn't working as expected:
- Make sure you've read and understood all relevant code
- Consider if the codebase has evolved since the plan was written
- Present the mismatch clearly and ask for guidance

Use sub-agents sparingly — mainly for targeted debugging or exploring unfamiliar territory.

## Completion

When all phases are complete (all entries in `manifest.json` `implementation` have status `"done"`):

1. Present a completion summary:
   ```
   Implementation Complete

   Automated verification:
   - [x] [checks that passed]

   Manual verification required:
   - [ ] <from plan>
   ```

2. **Update the manifest**: Set the `implement` phase to `done` with today's date.


## Guidelines

- **Do not add unrequested features**: Only implement what the phase doc specifies
- **Do not clean up adjacent code**: Resist the urge to refactor surrounding code while implementing
- **Read files completely**: Never use limit/offset when reading files
- **Keep forward momentum**: The goal is working software, not perfect process adherence
- **Verify after each phase**: Catch issues at the phase boundary where they are easiest to diagnose
