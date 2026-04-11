# Prerequisite Check

Follow this protocol immediately after feature discovery resolves `$FEATURE_PATH`. Each skill specifies its `<phase>` name when referencing this file.

## 1. Run the Check

```bash
PREREQ_RESULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-prerequisites.sh" "$FEATURE_PATH" "<phase>")
```

The script checks whether intent exists and reports which artifacts are available:

```json
{
  "ok": true|false,
  "intent_missing": true|false,
  "available": ["intent", "research-questions", "research", "design", "structure", "plan"],
  "current_phase": "<phase>"
}
```

## 2. Interpret the Result

### If `intent_missing` is true → HARD STOP

Intent is required before any other phase can proceed.

Respond with exactly:

```
Intent is required before any other phase can proceed.
Run `/crispy-intent` to capture the intent first.
```

**Do not offer to continue. Do not offer auto-advance. Stop completely.**

### Otherwise → PROCEED

All other phases are optional. Proceed with the current skill's normal workflow — it will work with whatever artifacts are available. Do not warn about missing phases, do not offer to fill gaps.

## 3. Auto-Advance (--autoadvance flag only)

Auto-advance is triggered **only** when the user explicitly passes `--autoadvance` as part of their command (e.g., `/crispy-design --autoadvance`). It is never triggered automatically.

When `--autoadvance` is active, run the auto-advance script before proceeding with the current skill's work:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/auto-advance.sh" "$FEATURE_PATH" "<phase>" "${CLAUDE_PLUGIN_ROOT}"
```

**CRITICAL: Do NOT perform any research, writing, or skill work yourself.** Your only action is to run this one bash command and wait for it to complete. The script handles everything — it spawns a separate `claude -p` process for each missing phase, waits for each to finish, then moves to the next.

This script:
1. Determines which phases are missing
2. Runs each missing phase in pipeline order via `claude -p` with the crispy plugin loaded
3. Each phase runs as a separate `claude -p` invocation with `--permission-mode auto`
4. Verifies each phase completed (artifact file written)
5. Reports progress and exits 0 on success, 1 on failure

After the script completes successfully, continue with the current skill's normal workflow.

If the script fails, report the error and suggest the user run the failed phase manually.

### Phase pipeline order

```
research-questions → research → design → structure-outline → plan
```

The auto-advance script respects this order and only runs phases that are actually missing.
