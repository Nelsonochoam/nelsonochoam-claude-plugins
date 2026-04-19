# Project Discovery

Follow these steps to resolve the showboat output directory. Each skill that references this file will specify any skill-specific overrides.

## 1. Resolve Base Directory

Run:

```bash
BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh")
```

This returns the repo-level base directory (e.g., `<configured_path>/<repo-name>`).

## 2. Resolve Feature

Determine which feature is active. All artifact reads and writes are scoped to the feature:

1. **`FEATURE` env variable is set** → use it as the feature name:

   ```bash
   DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "$FEATURE")
   ```

2. **`FEATURE` is not set** → check the session file:

   ```bash
   SESSION_FILE="/tmp/.showboat_feature_${PPID}"
   if [ -f "$SESSION_FILE" ]; then
     FEATURE=$(cat "$SESSION_FILE")
     DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "$FEATURE")
   fi
   ```

   If the session file exists, use it — skip asking the user.

3. **Neither env var nor session file** → if the skill requires a feature name, use `AskUserQuestion` to ask: *"Which feature are you working on? (e.g., `add-user-search` or a ticket ID like `TICKET-1234`)"*

   Once the feature name is known, persist and resolve:

   ```bash
   DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh" "<feature-name>")
   ```

   The session file is keyed to the current `claude` process PID (`$PPID`), so it is automatically scoped to this session and ignored by future `claude` invocations.

Two variables are now set:
- **`$BASE_DIR`** — repo-level directory (`<base_dir>/<repo-name>`). Use this for any repo-wide artifact a skill needs.
- **`$DEMO_BASE`** — feature-scoped directory (`<base_dir>/<repo-name>/<feature>`). Demo documents are written directly here (e.g., `$DEMO_BASE/demo.md`). The runbook graph lives wherever the user configured in `/showboat:init`, not under `$BASE_DIR`.

## 3. Verify Configuration

If `~/.showboat/config.json` does not exist, tell the user:

> Showboat is not configured yet. Run `/showboat:init` to set your output directory.
>
> I can proceed using the default location (`~/.showboat/<repo-name>/`) for now.

Then continue with the default path. Do not block on missing configuration.
