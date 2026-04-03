---
name: crispy-init
description: Initialize crispy configuration — set where artifacts are stored and optionally link to an Obsidian vault. Run once per machine; config is shared across all repos and worktrees.
argument-hint: '[--reset to reconfigure]'
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
>   Obsidian mode:  `<yes/no>`  
>   Vault:          `<obsidian_vault or N/A>`
>
> Do you want to reconfigure?

Options: `Yes, reconfigure` / `No, keep current config`

If the user chooses to keep the current config, exit and say "Configuration unchanged."

**If NOT configured (or user chose to reconfigure):** proceed to Step 1.

## Step 1: Storage Location

Use `AskUserQuestion` to ask:

> Where should crispy store feature artifacts?
>
> Features are organized as `<base>/<repo-name>/<feature>/` so artifacts from different repos stay separate.

Options:
- `Default (~/.crispy/)` — recommended, shared across all worktrees
- `Custom path`

If the user picks **Custom path**, use `AskUserQuestion` to ask for the full path.

Store the result as `base_dir` (absolute path, `~` expanded using `$HOME`).

## Step 2: Obsidian Integration

Use `AskUserQuestion` to ask:

> Would you like to link crispy to an Obsidian vault?
>
> If yes, `~/.crispy` will be symlinked into your vault so all artifacts appear inside Obsidian automatically — graph view, search, and backlinks all work out of the box.

Options: `Yes` / `No`

**If Yes:** read `references/obsidian-integration.md` and follow those instructions to collect the vault path, verify it, set the Obsidian values, and note the apply command for Step 4.

**If No:**
- `obsidian` = `false`
- `obsidian_vault` = `null`

## Step 3: Confirm

Use `AskUserQuestion` to show a summary and ask for confirmation:

> Ready to configure crispy:
>
>   Base directory: `<base_dir>/<repo-name>/`  (one folder per repo)  
>   Config file:    `~/.crispy/config.json`  
>   <Lines from obsidian-integration.md "Confirmation Summary Line" if Obsidian mode>
>
> Proceed?

Options: `Yes, apply` / `No, cancel`

If the user cancels, exit with "Configuration cancelled. Nothing was changed."

## Step 4: Apply

**If Obsidian mode:** the apply command was already noted in Step 2 — run it now.

**If NOT Obsidian mode:**

```bash
mkdir -p "<base_dir>"
printf '{"base_dir":"%s","obsidian":false,"obsidian_vault":null}\n' "<base_dir>" > "$HOME/.crispy/config.json"
cat "$HOME/.crispy/config.json"
```

## Step 5: Done

Once the commands succeed, say:

```
Crispy initialized.

  Artifacts stored at: <base_dir>/<repo-name>/<feature>/
  <If Obsidian: "Visible in Obsidian at: <vault>/crispy/<repo-name>/<feature>/">
  Config: ~/.crispy/config.json

Run /crispy-intent to start your first feature.
```

## Notes

- `base_dir` in config stores the root WITHOUT the repo-name segment. The `get-config.sh` script appends the current repo name at runtime.
- In Obsidian mode, the symlink makes `~/.crispy/` point into the vault, so all skills continue to work via `~/.crispy/<repo-name>/` without path changes.
