---
name: init
description: Initialize showboat configuration — set where demo artifacts are stored. Run once per machine; config is shared across all repos.
argument-hint: '[--reset to reconfigure]'
disable-model-invocation: true
---

User's request: $ARGUMENTS

# Initialize Showboat

You are setting up showboat's artifact storage for this machine. Run this wizard step by step. **Use the `AskUserQuestion` tool for every question** — do not ask questions in plain text.

## Step 0: Check Prerequisites

Run the prerequisites check to verify required and recommended tools are installed:

```bash
PREREQ=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-prerequisites.sh" 2>/dev/null) || true
echo "$PREREQ"
```

Parse the JSON output. Report results to the user:

### If required tools are missing (`ok: false`)

Stop and show install instructions. Do not proceed with configuration until required tools are installed.

```
Showboat requires the following tools that are not installed:

  jq     — JSON processor (used for config and evidence capture)
           Install: brew install jq

  curl   — HTTP client (used for API evidence capture)
           Install: brew install curl

  git    — Version control (used for diff evidence and repo detection)
           Install: brew install git
```

Only list the tools that are actually missing. After showing instructions, stop.

### If required tools are present but recommended tools are missing

Show a warning but continue with setup:

```
Prerequisites check:

  Required (installed):
    ✓ jq
    ✓ curl
    ✓ git

  Recommended (for screenshots and browser automation):
    <✓ or ✗> rodney     — Browser automation CLI (multi-turn sessions: navigate, click, screenshot)
                          Install: uvx rodney
                          Docs: https://simonwillison.net/2026/Feb/10/showboat-and-rodney/

    <✓ or ✗> shot-scraper — Single-shot screenshot CLI
                            Install: pip install shot-scraper && shot-scraper install
                            Docs: https://shot-scraper.datasette.io/

  Browser automation: <available / not available>
    Without Rodney or shot-scraper, showboat can still capture command outputs,
    test results, and API responses — but cannot take screenshots of web pages.
```

Only list recommended tools that are missing. If both Rodney and shot-scraper are installed, skip the warning entirely.

### If everything is installed

Show a brief confirmation:

```
Prerequisites: all required and recommended tools installed.
```

Then proceed to check existing configuration.

## Check Existing Configuration

Run:

```bash
cat "$HOME/.showboat/config.json" 2>/dev/null || echo "NOT_CONFIGURED"
```

**If config exists and `--reset` was NOT passed:**

Use `AskUserQuestion` to ask:

> Showboat is already configured:
>
>   Base directory: `<base_dir>`
>
> Do you want to reconfigure?

Options: `Yes, reconfigure` / `No, keep current config`

If the user chooses to keep the current config, exit and say "Configuration unchanged."

**If NOT configured (or user chose to reconfigure):** proceed to Step 1.

## Step 1: Storage Location

Use `AskUserQuestion` to ask for the storage location. Present the choices clearly but allow for direct input:

> Where should showboat store demo artifacts?
>
> This can be an Obsidian vault path, a notes directory, or any folder.
> All output uses Obsidian-compatible format (YAML frontmatter, wikilinks, tags).
>
> 1. **Default** (`~/.showboat/`)
> 2. **Custom path** (Please provide the full absolute path below)

**Logic:**
- If the user selects "Default", set `base_dir` to `$HOME/.showboat/`.
- If the user selects "Custom path" or provides a path directly, use that input.
- If the path is provided but not absolute, or contains `~`, expand it using `$HOME`.

Store the final result as `base_dir`.

## Step 2: Knowledge Index (optional)

Use `AskUserQuestion` to ask if the user has an existing knowledge base showboat should read from:

> Do you have an existing knowledge base or index file that showboat should use for testing context?
>
> This is a markdown file that serves as an entry point to testing knowledge —
> it could be a wiki index, an Obsidian MOC, a runbook, or any markdown file
> with links to relevant docs. Showboat will progressively load from it when
> it needs context about how to test your applications.
>
> 1. **No knowledge index** (showboat will learn from scratch via introspect)
> 2. **I have one** (Please provide the full absolute path below)

**Logic:**
- If the user selects "No knowledge index", set `knowledge_index` to `null` (omit from config).
- If the user provides a path, validate it exists and is a `.md` file. Store as `knowledge_index`.
- If the path contains `~`, expand it using `$HOME`.

## Step 3: Confirm

Use `AskUserQuestion` to show a summary and ask for confirmation:

> Ready to configure showboat:
>
>   Base directory:    `<base_dir>/<repo-name>/` (one folder per repo)
>   Knowledge index:   `<knowledge_index path>` (or "none — will learn from scratch")
>   Config file:       `~/.showboat/config.json`
>
>   Output format: Obsidian-compatible markdown (frontmatter, wikilinks, Dataview properties)
>
> Proceed?

Options: `Yes, apply` / `No, cancel`

If the user cancels, exit with "Configuration cancelled. Nothing was changed."

## Step 4: Apply

Call the helper script to handle all setup deterministically:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/setup-showboat.sh" "<base_dir>" "<knowledge_index or empty>"
```

This script will:
- Create `~/.showboat` directory
- Handle existing symlinks at `~/.showboat`
- Create the artifact base directory
- Write `config.json` with `base_dir` and optionally `knowledge_index`
- Validate everything succeeded

If it fails, it exits with code 1 and prints an error.

## Step 5: Done

Once the command succeeds, say:

```
Showboat initialized.

  Artifacts stored at: <base_dir>/<repo-name>/
  Config file: ~/.showboat/config.json

  Output structure (per repo):
    testing-context.md   — app testing playbook
    demos/               — demo documents with evidence
    evidence/            — raw capture logs + screenshots
    verifications/       — re-verification reports
    learnings/           — introspection learnings

Run /showboat:context to create a testing playbook for this repo.
```

If Rodney or shot-scraper were missing during the prerequisites check, add a reminder:

```
Note: Screenshot capture is not available. To enable it, install one of:
  uvx rodney                                        (recommended — full browser automation)
  pip install shot-scraper && shot-scraper install   (simpler — single-shot screenshots)
```

## Notes

- `base_dir` in config stores the root WITHOUT the repo-name segment. The `resolve-basedir.sh` script appends the current repo name at runtime.
- The config file is always written to `~/.showboat/config.json` for consistency across repos, but artifacts can be stored anywhere (Obsidian vault, Dropbox, etc.).
