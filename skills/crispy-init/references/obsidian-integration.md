# Obsidian Integration

Follow these steps when the user has opted in to Obsidian integration.

## Ask for Vault Path

Use `AskUserQuestion` to ask:

> What is the full path to your Obsidian vault?
>
> Example: `/Users/you/Documents/MyVault`

## Verify the Path

```bash
ls "<vault-path>" 2>/dev/null || echo "NOT_FOUND"
```

If not found, use `AskUserQuestion` to ask again — tell the user the path was not found and ask for a corrected path. Repeat until a valid path is confirmed.

## Set Values

Once the path is confirmed:

- `base_dir` = `<vault-path>/crispy`
- `obsidian` = `true`
- `obsidian_vault` = `<vault-path>`

## Apply

Run the setup script. Resolve the script path first, then execute — do **not** inline `CLAUDE_PLUGIN_ROOT` as a prefix assignment, as the shell expands `${...}` before the assignment takes effect:

```bash
_script="${CLAUDE_PLUGIN_ROOT}/skills/crispy-init/scripts/setup-obsidian.sh"
bash "$_script" "<vault-path>"
```

The script creates `<vault>/crispy/`, writes the config there, and symlinks `~/.crispy` → `<vault>/crispy/`. It will error if `~/.crispy` is a non-empty directory — in that case, tell the user to back it up and remove it first.

## Confirmation Summary Line

Include in the Step 3 summary:

```
  Obsidian mode: yes
  Vault:         <vault-path>
  Symlink:       ~/.crispy → <vault-path>/crispy/
```
