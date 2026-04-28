---
name: init
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

## Step 2: Folder Organization

Use `AskUserQuestion` to ask how features should be organized:

> Should crispy group feature folders by git repository?
>
> - **Yes** (default) — `<base_dir>/<repo-name>/<feature>/` — keeps each repo's work separate
> - **No** — `<base_dir>/<feature>/` — flat layout, useful when features span multiple repos

Store the result as `folders_git` (`true` or `false`).

**Logic:**
- If the user selects "Yes" (or provides no answer), set `folders_git` to `true`.
- If the user selects "No", set `folders_git` to `false`.

## Step 3: Confirm

Use `AskUserQuestion` to show a summary and ask for confirmation:

If `folders_git` is `true`:
> Ready to configure crispy:
>
>   Base directory: `<base_dir>/<repo-name>/` (one folder per repo)
>   Config file:    `~/.crispy/config.json`
>
> Proceed?

If `folders_git` is `false`:
> Ready to configure crispy:
>
>   Base directory: `<base_dir>/` (flat, features written directly here)
>   Config file:    `~/.crispy/config.json`
>
> Proceed?

Options: `Yes, apply` / `No, cancel`

If the user cancels, exit with "Configuration cancelled. Nothing was changed."

## Step 4: Apply

Call the helper script to handle all setup deterministically:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/setup-crispy.sh" "<base_dir>" "<folders_git>"
```

This script will:
- Create `~/.crispy` directory
- Create the artifact base directory
- Write `config.json` with `base_dir` and `folders.git`
- Validate everything succeeded

If it fails, it exits with code 1 and prints an error.

## Step 5: Done

Once the command succeeds, say:

If `folders_git` is `true`:
```
Crispy initialized.

  Artifacts stored at: <base_dir>/<repo-name>/<feature>/
  Config file: ~/.crispy/config.json

Run /crispy:intent to start your first feature.
```

If `folders_git` is `false`:
```
Crispy initialized.

  Artifacts stored at: <base_dir>/<feature>/
  Config file: ~/.crispy/config.json

Run /crispy:intent to start your first feature.
```

## Notes

- `base_dir` in config stores the root path. The `resolve-basedir.sh` script appends the repo name at runtime only when `folders.git` is `true`.
- `folders.git` defaults to `true` — existing installs without this key in config behave exactly as before.
- The config file is always written to `~/.crispy/config.json` for consistency across repos, but artifacts can be stored anywhere.
