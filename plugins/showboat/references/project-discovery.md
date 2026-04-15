# Project Discovery

Follow these steps to resolve the showboat project (repo-level output directory). Each skill that references this file will specify any skill-specific overrides.

## 1. Resolve Base Directory

Run:

```bash
BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh")
```

This returns the base directory path for the current repo (e.g., `<configured_path>/<repo-name>/`). All artifact reads and writes use `BASE_DIR` as the root.

## 2. Resolve Project

Check if a showboat project session is already active:

1. **`SHOWBOAT_PROJECT` env variable is set** -> use it, then ensure directories exist:

   ```bash
   DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh")
   echo "$SHOWBOAT_PROJECT" > "/tmp/.showboat_session_${PPID}"
   ```

2. **`SHOWBOAT_PROJECT` is not set** -> check the session file:

   ```bash
   SESSION_FILE="/tmp/.showboat_session_${PPID}"
   if [ -f "$SESSION_FILE" ]; then
     SHOWBOAT_PROJECT=$(cat "$SESSION_FILE")
     DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh")
   fi
   ```

   If the session file exists and contains a project name, use it -- skip asking the user.

3. **Neither env var nor session file** -> derive from git. The project name is the repo name, resolved automatically by `resolve-basedir.sh`. Just ensure directories exist:

   ```bash
   DEMO_BASE=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-demo.sh")
   ```

   Showboat always knows its project -- it is the current repo (derived automatically from git).

## 3. Verify Configuration

If `~/.showboat/config.json` does not exist, tell the user:

> Showboat is not configured yet. Run `/showboat:init` to set your output directory.
>
> I can proceed using the default location (`~/.showboat/<repo-name>/`) for now.

Then continue with the default path. Do not block on missing configuration.
