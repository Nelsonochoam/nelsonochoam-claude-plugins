# Example Interaction Flow

```
User: /implement [confirmed plan for questionnaire status filtering]
Assistant: Reading the plan completely...

[Reads plan, identifies Phase 1 starts with the Prisma schema]
[Reads all files Phase 1 will touch before making any changes]

Starting from Phase 1, Step 1: Add status field to the Questionnaire model...

[Implements steps, runs lint + type-check]

Phase 1 Complete — Ready for Manual Verification

Automated verification passed:
- [x] yarn workspace @sb/server lint
- [x] yarn workspace @sb/server run type-check

Please verify manually:
- [ ] Migration applies cleanly in your local dev database

Let me know when ready and I'll proceed to Phase 2.
```
