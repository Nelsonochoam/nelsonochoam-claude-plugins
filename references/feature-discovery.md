# Feature Discovery

Follow these steps to resolve which crispy feature you are working on. Each skill that references this file will specify its `<phase>` name and any skill-specific overrides.

## 1. Resolve Base Directory

Run:

```bash
BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/get-config.sh")
```

This returns the crispy output base directory for the current repo (e.g., `~/.crispy/<repo-name>/`). All feature folder references use `BASE_DIR` as the base path.

## 2. Resolve Feature Folder

1. **Check the `CRISPY_FEATURE` env variable** — if set, use `<BASE_DIR>/$CRISPY_FEATURE/` as the feature folder.
2. **If not set**, scan `<BASE_DIR>/` for feature folders:
   - If **one folder** exists → use it automatically.
   - If **multiple folders** exist → check each `manifest.json` for the one where `<phase>` status is `pending`. If exactly one matches, use it. Otherwise, list the folders and ask the user which feature to continue.
   - If **no folders** exist → determine the feature name from the user's arguments:
     1. If a ticket is mentioned, use it as the feature name
     2. Otherwise derive a kebab-case name from the description (e.g. `add-dark-mode-toggle`)

     Then create the folder:
     ```bash
     FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "<feature-name>")
     ```
     If no arguments were provided, follow the **no-args fallback** described in the skill file.
3. **Read `manifest.json`** from the resolved feature folder (if it exists) to understand phase status. Follow any **manifest handling** instructions in the skill file.
