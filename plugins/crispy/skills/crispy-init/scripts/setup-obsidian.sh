#!/usr/bin/env bash
# setup-obsidian.sh — Create the crispy directory inside an Obsidian vault,
# write the config file, and symlink ~/.crispy to the vault location.
#
# Usage:
#   bash "${CLAUDE_PLUGIN_ROOT}/skills/crispy-init/scripts/setup-obsidian.sh" "<vault-path>"

VAULT_PATH="$1"

if [ -z "$VAULT_PATH" ]; then
  echo "Usage: setup-obsidian.sh <vault-path>" >&2
  exit 1
fi

# Create the crispy directory inside the vault
mkdir -p "$VAULT_PATH/crispy"

# Write config into the vault (before symlinking so the file exists there)
printf '{"base_dir":"%s/crispy","obsidian":true,"obsidian_vault":"%s"}\n' \
  "$VAULT_PATH" "$VAULT_PATH" > "$VAULT_PATH/crispy/config.json"

# Remove an existing ~/.crispy symlink or abort if it is a non-empty directory
if [ -L "$HOME/.crispy" ]; then
  rm "$HOME/.crispy"
elif [ -d "$HOME/.crispy" ] && [ "$(ls -A "$HOME/.crispy")" ]; then
  echo "ERROR: ~/.crispy is a non-empty directory. Back it up and remove it first." >&2
  exit 1
elif [ -d "$HOME/.crispy" ]; then
  rmdir "$HOME/.crispy"
fi

# Create the symlink
ln -s "$VAULT_PATH/crispy" "$HOME/.crispy"

# Verify
ls -la "$HOME/.crispy/config.json"
