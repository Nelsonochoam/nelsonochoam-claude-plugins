# Planned Execution

`plan.md` and `manifest.json` exist — follow the planned execution path.

## Setup

1. Read `plan.md` for the overview, dependency graph, and phase summary table
2. Read `manifest.json` and check for an `implementation` key
3. Determine which phase to work on (see below)
4. Read that phase's doc from `$FEATURE_PATH/phases/phase-N.md` — it contains all implementation details
5. Read all files the phase doc says you will modify, completely
6. Think deeply about how the pieces fit together
7. Create a todo list to track your progress through the phase's changes

## Default (no arguments) — Sequential, one phase at a time

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
- `reason: "no_implementation_key"` — read `plan.md` and phase docs from `$FEATURE_PATH/phases/` directly, executing them sequentially. Track progress in the conversation rather than in a manifest file.

This is the ralph-loop style: one phase per invocation, clean context boundaries. The user decides whether to continue in this session, start a fresh session, or do something else entirely.

## Targeted (`phase-N` argument)

When the user passes a specific phase (e.g., `/crispy-implement phase-2`):
1. Read the matching entry from `manifest.json` (`implementation.phase-2`)
2. Verify all its `dependencies` have status `"done"`. If not, report which dependencies are incomplete and **stop**.
3. Read the phase doc from `implementation.phase-2.file` — it contains all implementation details
4. If dependencies are met, implement only that phase
5. After verification, set the phase's status to `"done"`

## Resuming Work

When resuming (new session or continuing):
- Run `next-phase.sh` to determine which phase to work on next — `manifest.json` is the source of truth
- If a phase is `"in-progress"`, resume it — review the codebase state to determine what was already done
- Trust that completed work is done; verify previous work only if something seems off

## Verification

After completing each phase:

1. **Run the success criteria checks** specified in the phase doc — fix any failures before proceeding
2. **Update the manifest**: set `implementation.phase-N.status` to `"done"` in `manifest.json`
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

## Completion

When all entries in `manifest.json` `implementation` have status `"done"`:

1. Present a completion summary:
   ```
   Implementation Complete

   Automated verification:
   - [x] [checks that passed]

   Manual verification required:
   - [ ] <from plan>
   ```
