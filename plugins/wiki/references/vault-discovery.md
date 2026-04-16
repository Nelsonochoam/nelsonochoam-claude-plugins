# Vault Discovery

Follow these steps to resolve the wiki vault path. Each skill that references this file will specify any skill-specific overrides.

## 1. Parse Wiki Name

Check if `$ARGUMENTS` contains a `--wiki <name>` flag. If present, extract the wiki name and remove it from the remaining arguments.

```
Example: /wiki:ingest --wiki testing article.md
         → wiki_name = "testing", remaining args = "article.md"
```

If no `--wiki` flag, set `wiki_name` to empty.

## 2. Resolve Vault

Resolve the vault path in this priority order:

**If `--wiki <name>` was provided** — named wiki takes highest priority:

```bash
VAULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh" "<wiki_name>")
```

**Else if `WIKI` env var is set** — supports both direct paths and wiki names:

```bash
# Direct path (starts with / or ~)
if [[ "$WIKI" == /* ]] || [[ "$WIKI" == ~* ]]; then
  VAULT="${WIKI/#\~/$HOME}"
else
  # Wiki name — look up in config
  VAULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh" "$WIKI")
fi
```

**Else check session file** — for persistence across `/clear` within the same session:

```bash
SESSION_FILE="/tmp/.wiki_session_${PPID}"
if [ -f "$SESSION_FILE" ]; then
  VAULT=$(cat "$SESSION_FILE")
fi
```

**Else use config default:**

```bash
VAULT=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh")
```

If `resolve-basedir.sh` exits with an error (wiki name not found in config), show the error and stop.

## 3. Persist Session

Write the resolved vault path to the session file so subsequent commands in this session (and recovery after `/clear`) use the same wiki:

```bash
echo "$VAULT" > "/tmp/.wiki_session_${PPID}"
```

## 4. Verify Vault Structure

Check that the vault has the expected structure:

```bash
ls "$VAULT/wiki/index.md" 2>/dev/null && echo "VAULT_OK" || echo "VAULT_MISSING"
```

**If vault structure is missing:** Tell the user:

> Wiki vault not initialized. Run `/wiki:init` to set up the three-layer structure.

Then stop. Do not proceed without a properly initialized vault.

## 5. Read Schema

If a `CLAUDE.md` exists at the vault root, read it for vault-specific conventions:

```bash
cat "$VAULT/CLAUDE.md" 2>/dev/null || echo "NO_SCHEMA"
```

If found, the schema overrides default page conventions. Follow the schema's rules for page formats, frontmatter, and wikilink conventions.
