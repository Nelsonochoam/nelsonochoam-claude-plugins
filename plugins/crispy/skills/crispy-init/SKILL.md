---
name: crispy-init
description: Initialize crispy configuration — set where artifacts are stored. Run once per machine; config is shared across all repos and worktrees.
argument-hint: '[--reset to reconfigure]'
disable-model-invocation: true
---

User's request: $ARGUMENTS

# Initialize Crispy

You are setting up crispy's artifact storage for this machine. Run this wizard step by step. **Use the `AskUserQuestion` tool for every question** — do not ask questions in plain text.

## Step 0: Check Existing Configuration

Run:

```bash
cat "$HOME/.crispy/config.json" 2>/dev/null || echo "NOT_CONFIGURED"
```

**If config exists and `--reset` was NOT passed:**

Use `AskUserQuestion` to ask:

> Crispy is already configured:
>
>   Base directory: `<base_dir>`
>
> Do you want to reconfigure?

Options: `Yes, reconfigure` / `No, keep current config`

If the user chooses to keep the current config, exit and say "Configuration unchanged."

**If NOT configured (or user chose to reconfigure):** proceed to Step 1.

## Step 1: Storage Location

Use `AskUserQuestion` to ask for the storage location. Present the choices clearly but allow for direct input:

> Where should crispy store feature artifacts?
> 1. **Default** (`~/.crispy/`)
> 2. **Custom path** (Please provide the full absolute path below)

**Logic:**
- If the user selects "Default", set `base_dir` to `$HOME/.crispy/`.
- If the user selects "Custom path" or provides a path directly, use that input. 
- If the path is provided but not absolute, or contains `~`, expand it using `$HOME`.

Store the final result as `base_dir`.

## Step 2: Confirm

Use `AskUserQuestion` to show a summary and ask for confirmation:

> Ready to configure crispy:
>
>   Base directory: `<base_dir>/<repo-name>/` (one folder per repo)
>   Config file:    `~/.crispy/config.json`
>
> Proceed?

Options: `Yes, apply` / `No, cancel`

If the user cancels, exit with "Configuration cancelled. Nothing was changed."

## Step 3: Apply

Call the helper script to handle all setup deterministically:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/setup-crispy.sh" "<base_dir>"
```

This script will:
- Create `~/.crispy` directory
- Handle existing symlinks at `~/.crispy`
- Create the artifact base directory
- Write `config.json` with proper JSON escaping
- Validate everything succeeded

If it fails, it exits with code 1 and prints an error.

## Step 4: Done

Once the command succeeds, say:

```
Crispy initialized.

  Artifacts stored at: <base_dir>/<repo-name>/<feature>/
  Config file: ~/.crispy/config.json

Run /crispy-intent to start your first feature.
```

## Notes

- `base_dir` in config stores the root WITHOUT the repo-name segment. The `get-config.sh` script appends the current repo name at runtime.
- The config file is always written to `~/.crispy/config.json` for consistency across repos, but artifacts can be stored anywhere.
