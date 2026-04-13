# Feature Discovery

Follow these steps to resolve which crispy feature you are working on. Each skill that references this file will specify its `<phase>` name and any skill-specific overrides.

## 1. Resolve Base Directory

Run:

```bash
BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh")
```

This returns the base directory path for the current repo . All feature folder references use `BASE_DIR` as the base path.

## 2. Resolve Feature Folder

Resolve the feature folder. All subsequent artifact reads and writes use `$FEATURE_PATH`.

1. **`CRISPY_FEATURE` env variable is set** → use it as the feature name
2. **`CRISPY_FEATURE` is not set** → check the session file:

   ```bash
   SESSION_FILE="/tmp/.crispy_session_${PPID}"
   if [ -f "$SESSION_FILE" ]; then
     CRISPY_FEATURE=$(cat "$SESSION_FILE")
   fi
   ```

   If the session file exists and contains a feature name, use it — skip asking the user.

3. **Neither env var nor session file** → use `AskUserQuestion` to ask: *"Which feature do you want to work on? Provide an existing feature name or a new one (use kebab-case or a ticket ID — e.g. `add-dark-mode-toggle` or `ticket-1234`)."*

   Once the feature name is known, create or resolve the folder and **persist it for this session** so subsequent skills (after `/clear`) don't ask again:

   ```bash
   FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "$CRISPY_FEATURE")
   echo "$CRISPY_FEATURE" > "/tmp/.crispy_session_${PPID}"
   ```

   The session file is keyed to the current `claude` process PID (`$PPID`), so it is automatically scoped to this session and ignored by any future `claude` invocation.

3. **If the user provided no task description** (only a feature name, or nothing at all), follow the skill's **no-args fallback** now.
