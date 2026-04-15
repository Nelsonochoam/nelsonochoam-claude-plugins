# Vault Discovery

Follow these steps to resolve the wiki vault path. Each skill that references this file will specify any skill-specific overrides.

## 1. Parse Wiki Name

Check if `$ARGUMENTS` contains a `--wiki <name>` flag. If present, extract the wiki name.

```
Example: /wiki:ingest --wiki testing article.md
         → wiki_name = "testing", remaining args = "article.md"
```

If no `--wiki` flag, set `wiki_name` to empty (use default wiki).

## 2. Resolve Base Directory

Run:

```bash
BASE_DIR=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-basedir.sh" "<wiki_name or empty>")
```

This returns the vault root path for the requested wiki. If `wiki_name` is empty, it returns the default wiki. If the config has multiple wikis, it resolves the named one.

If the script exits with an error (wiki name not found), show the error message (which lists available wikis) and stop.

## 3. Resolve Vault

Check if a wiki vault session is already active:

1. **`WIKI_VAULT` env variable is set** -> use it:

   ```bash
   echo "$WIKI_VAULT" > "/tmp/.wiki_session_${PPID}"
   ```

2. **`WIKI_VAULT` is not set** -> check the session file:

   ```bash
   SESSION_FILE="/tmp/.wiki_session_${PPID}"
   if [ -f "$SESSION_FILE" ]; then
     WIKI_VAULT=$(cat "$SESSION_FILE")
   fi
   ```

   If the session file exists and contains a vault path, use it.

3. **Neither env var nor session file** -> use the path from config (`$BASE_DIR`).

## 4. Verify Vault Structure

Check that the vault has the expected structure:

```bash
ls "$BASE_DIR/wiki/index.md" 2>/dev/null && echo "VAULT_OK" || echo "VAULT_MISSING"
```

**If vault structure is missing:** Tell the user:

> Wiki vault not initialized. Run `/wiki:init` to set up the three-layer structure.

Then stop. Do not proceed without a properly initialized vault.

## 5. Read Schema

If a `CLAUDE.md` exists at the vault root, read it for vault-specific conventions:

```bash
cat "$BASE_DIR/CLAUDE.md" 2>/dev/null || echo "NO_SCHEMA"
```

If found, the schema overrides default page conventions. Follow the schema's rules for page formats, frontmatter, and wikilink conventions.
