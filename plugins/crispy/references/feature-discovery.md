# Feature Discovery

Follow these steps to resolve which crispy feature you are working on. Each skill that references this file will specify its `<phase>` name and any skill-specific overrides.

## 1. Resolve Base Directory

Run:

```bash
BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/get-config.sh")
```

This returns the crispy output base directory for the current repo (e.g., `~/.crispy/<repo-name>/`). All feature folder references use `BASE_DIR` as the base path.

## 2. Resolve Feature Folder

Resolve the feature folder. All subsequent artifact reads and writes use `$FEATURE_PATH`.

1. **`CRISPY_FEATURE` env variable is set** → set `FEATURE_PATH` to `$BASE_DIR/$CRISPY_FEATURE`
2. **`CRISPY_FEATURE` is not set** → scan `$BASE_DIR/` for feature folders:
   - **One folder found** → set `FEATURE_PATH` to that folder's absolute path
   - **Multiple folders found** → check each folder's `manifest.json` for the one where `<phase>` status is `pending` (skip folders with no manifest or no matching phase key). If exactly one matches, set `FEATURE_PATH` to it. If zero or multiple match, use `AskUserQuestion` to list the folders and ask which feature to continue.
   - **No folders found** → determine the feature name:
     1. If the user's arguments contain a ticket ID (e.g. `tn-3459`) or an explicit feature name, derive from it (convert description to kebab-case, e.g. `add-dark-mode-toggle`)
     2. Otherwise use `AskUserQuestion` to ask: *"What should this feature be named? Use kebab-case or a ticket ID — e.g. `add-dark-mode-toggle` or `tn-3459`."*

     Remember the feature name as `CRISPY_FEATURE` for this session, then create the folder:
     ```bash
     FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "$CRISPY_FEATURE")
     ```

3. **Read `$FEATURE_PATH/manifest.json`** (if it exists) to understand phase status. Follow any **manifest handling** instructions in the skill file.

4. **If the user provided no task description** (only a feature name, or nothing at all), follow the skill's **no-args fallback** now.
