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

1. **`CRISPY_FEATURE` env variable is set** → set `FEATURE_PATH` to `$BASE_DIR/$CRISPY_FEATURE`
2. **`CRISPY_FEATURE` is not set** → use `AskUserQuestion` to ask: *"Which feature do you want to work on? Provide an existing feature name or a new one (use kebab-case or a ticket ID — e.g. `add-dark-mode-toggle` or `ticket-1234`)."*

   Remember the feature name as `CRISPY_FEATURE` for this session, then create or resolve the folder:

   ```bash
   FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "$CRISPY_FEATURE")
   ```

3. **Read `$FEATURE_PATH/manifest.json`** (if it exists) to understand phase status. Follow any **manifest handling** instructions in the skill file.

4. **If the user provided no task description** (only a feature name, or nothing at all), follow the skill's **no-args fallback** now.
