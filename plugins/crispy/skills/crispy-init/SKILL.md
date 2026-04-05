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

Use `AskUserQuestion` to ask:

> Where should crispy store feature artifacts?

Options:
- `Default (~/.crispy/)` — recommended
- `Custom path`

If the user picks **Custom path**, use `AskUserQuestion` to ask for the full path (the base directory where artifacts will be stored).

Store the result as `base_dir` (absolute path, `~` expanded using `$HOME`).

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

```bash
mkdir -p "<base_dir>"
printf '{"base_dir":"%s"}\n' "<base_dir>" > "$HOME/.crispy/config.json"
cat "$HOME/.crispy/config.json"
```

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
