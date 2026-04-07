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
2. **`CRISPY_FEATURE` is not set** → use `AskUserQuestion` to ask: *"Which feature do you want to work on? Provide an existing feature name or a new one (use kebab-case or a ticket ID — e.g. `add-dark-mode-toggle` or `ticket-1234`)."*

   Once the feature name is known, create or resolve the folder and **persist it for this session** so subsequent skills (after `/clear`) don't ask again:

   ```bash
   FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "$CRISPY_FEATURE")
   echo "$CRISPY_FEATURE" > "/tmp/.crispy_session_${PPID}"
   ```

   The session file is keyed to the current `claude` process PID (`$PPID`), so it is automatically scoped to this session and ignored by any future `claude` invocation.

3. **Read `$FEATURE_PATH/manifest.json`** (if it exists) to understand phase status. Follow any **manifest handling** instructions in the skill file.

4. **If the user provided no task description** (only a feature name, or nothing at all), follow the skill's **no-args fallback** now.
