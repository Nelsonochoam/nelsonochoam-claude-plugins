# Direct Execution

No `plan.md` exists — work directly from the intent and whatever other artifacts are available or information the user might have
provided, follow codebase conventions and common patterns you find.

## Setup

Read `$FEATURE_PATH/intent.md` and whatever other artifacts are available (`design.md`, `research.md`).

## Execution

1. Understand what needs to be built from the intent and any available artifacts
2. Explore the codebase to understand the current state and identify what needs to change
3. Break the work into logical chunks internally
4. Implement chunk by chunk, pausing between chunks to present what was done and what comes next — give the user a chance to steer

Do not create plan.md, manifest.json, or phase docs. Work in a condensed, iterative style guided by the available artifacts.

## Resuming Work

When resuming (new session or continuing), ask the user where they left off. Trust that completed work is done; verify previous work only if something seems off.

## Verification

After completing each chunk:

1. **Run relevant checks** — lint, type-check, tests — fix any failures before proceeding
2. **Pause for review**:

```
Chunk Complete — Ready for Review

What was done:
- [summary of changes]

What's next:
- [upcoming chunk description]

Let me know if this looks good or if you'd like to adjust direction.
```

## Completion

When all chunks are done:

1. Present a completion summary:
   ```
   Implementation Complete

   Automated verification:
   - [x] [checks that passed]

   Manual verification recommended:
   - [ ] [key behaviors to verify]
   ```
