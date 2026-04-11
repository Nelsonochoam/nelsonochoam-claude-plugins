# Plan-Only Execution

`plan.md` exists but no `manifest.json` — execute from the plan and phase docs directly.

## Setup

Read `plan.md` for the overview. Check if phase docs exist under `$FEATURE_PATH/phases/`. Track progress in the conversation rather than in a manifest file.

## Execution

For each phase doc, sequentially:
1. Read the phase doc completely
2. Implement the changes described
3. Run verification checks from the phase doc
4. Report what was done and pause for user review before the next phase

## Resuming Work

When resuming (new session or continuing), ask the user where they left off. Trust that completed work is done; verify previous work only if something seems off.

## Verification

After completing each phase:

1. **Run the success criteria checks** specified in the phase doc — fix any failures before proceeding
2. **Pause for manual verification**:

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

When all phase docs have been implemented:

1. Present a completion summary:
   ```
   Implementation Complete

   Automated verification:
   - [x] [checks that passed]

   Manual verification required:
   - [ ] <from plan>
   ```
