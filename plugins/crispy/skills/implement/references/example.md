# Example Interaction Flow

```
User: /crispy:implement
Assistant: Running next-phase.sh to find the next workable phase...

Next phase: phase-1 — "Add status field to Questionnaire model"

Reading phases/phase-1.md for implementation details...

[Reads phase doc — it contains exact file paths, code changes, and success criteria]
[Reads all files the phase doc says to modify]

Starting Phase 1, Step 1: Add status field to the Questionnaire model...

[Implements steps, runs lint + type-check]
[Updates manifest.json: implementation.phase-1.status = "done"]

Phase 1 Complete — Ready for Manual Verification

Automated verification passed:
- [x] yarn workspace @sb/server lint
- [x] yarn workspace @sb/server run type-check

Please verify manually:
- [ ] Migration applies cleanly in your local dev database

Let me know when ready and I'll proceed to Phase 2.
```

## Targeted Phase Example

```
User: /crispy:implement phase-3
Assistant: Reading manifest.json for phase-3...

Checking dependencies: phase-1 (done), phase-2 (done) — all met.

Reading phases/phase-3.md for implementation details...

[Phase doc is self-sufficient — contains all file paths, code blocks, design decisions]
[Implements the phase, runs verification]
[Updates manifest.json: implementation.phase-3.status = "done"]

Phase 3 Complete — Ready for Manual Verification
...
```
