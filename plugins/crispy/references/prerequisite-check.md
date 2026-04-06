# Prerequisite Check

Follow this protocol immediately after feature discovery resolves `$FEATURE_PATH`. Each skill specifies its `<phase>` name when referencing this file.

## 1. Run the Check

```bash
PREREQ_RESULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-prerequisites.sh" "$FEATURE_PATH" "<phase>")
```

The script reads `manifest.json` and returns a JSON object:

```json
{
  "ok": true|false,
  "intent_missing": true|false,
  "missing": ["phase-key", ...],
  "done": ["phase-key", ...],
  "current_phase": "<phase>",
  "manifest_exists": true|false
}
```

## 2. Interpret the Result

### If `manifest_exists` is false or `intent_missing` is true → HARD STOP

Intent is required before any other phase can proceed. It cannot be auto-advanced because it requires human input (scope, motivation, acceptance criteria, constraints).

Respond with exactly:

```
Intent is required before any other phase can proceed.
Run `/crispy-intent` to capture the intent first.
```

**Do not offer to continue. Do not offer auto-advance. Stop completely.**

### If `ok` is true → PROCEED

All prerequisites are met. Continue with the skill's normal workflow.

### If `ok` is false and `missing` is non-empty → OFFER OPTIONS

Prerequisites are missing. Present the situation using `AskUserQuestion` and wait for the user's choice:

```
The following prerequisite phases are not yet complete:
- <phase-1>
- <phase-2>
- ...

Options:
1. **Auto-advance** — run missing phases automatically using `claude -p` (each phase runs as a separate agent, no human review between them)
2. **Stop** — I'll run the missing phases manually: /crispy-<phase-1>, /crispy-<phase-2>, ...

⚠️ **Auto-advance warning**: Auto-advance will make decisions on your behalf for each missing phase (research focus areas, design choices, structure breakdown). This is faster but produces lower quality results than running each phase manually, where you can review and guide each step. Use auto-advance for well-scoped work where you trust the defaults.
```

Wait for the user to choose before doing anything else. **Do not proceed without their explicit choice.** There is no "proceed anyway" option — prerequisites are required.

## 3. Auto-Advance Execution

When the user chooses auto-advance, use the Bash tool to run the auto-advance script and wait for it to finish:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/auto-advance.sh" "$FEATURE_PATH" "<phase>" "${CLAUDE_PLUGIN_ROOT}"
```

**CRITICAL: Do NOT perform any research, writing, or skill work yourself.** Your only action is to run this one bash command and wait for it to complete. The script handles everything — it spawns a separate `claude -p` process for each missing phase, waits for each to finish, then moves to the next.

This script:
1. Determines which phases are missing (using `check-prerequisites.sh`)
2. Runs each missing phase in pipeline order via `claude -p` with the crispy plugin loaded
3. Each phase runs as a separate `claude -p` invocation with `--permission-mode auto`
4. Verifies each phase completed (artifact written + manifest updated)
5. Reports progress and exits 0 on success, 1 on failure

After the script completes successfully, continue with the current skill's normal workflow.

If the script fails, report the error and suggest the user run the failed phase manually.

### Phase pipeline order

```
research-questions → research → design → structure-outline → plan
```

Each phase requires all previous phases. The auto-advance script respects this order and only runs phases that are actually missing.
