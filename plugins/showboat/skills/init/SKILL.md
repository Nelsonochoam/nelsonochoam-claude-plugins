---
name: init
description: Initialize showboat configuration — set where demo artifacts are stored, optionally point at (or auto-generate) a testing runbook. Run once per machine; config is shared across all repos.
argument-hint: '[--reset to reconfigure]'
disable-model-invocation: true
---

User's request: $ARGUMENTS

# Initialize Showboat

You are setting up showboat's artifact storage and (optionally) a testing runbook for this machine. Run this wizard step by step. **Use the `AskUserQuestion` tool for every question** — do not ask questions in plain text.

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

  showboat — the showboat CLI (https://github.com/simonw/showboat)
             Install: uv tool install showboat

  jq       — JSON processor (used for config and evidence capture)
             Install: brew install jq

  curl     — HTTP client (used for API evidence capture)
             Install: brew install curl

  git      — Version control (used for diff evidence and repo detection)
             Install: brew install git
```

Only list the tools that are actually missing. After showing instructions, stop.

### If required tools are present but recommended tools are missing

Show a warning but continue with setup:

```
Prerequisites check:

  Required (installed):
    ✓ showboat
    ✓ jq
    ✓ curl
    ✓ git

  Recommended (for screenshots and browser automation):
    <✓ or ✗> rodney     — Browser automation CLI (multi-turn sessions: navigate, click, screenshot)
                          Install: uv tool install rodney
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
>   Runbook:        `<runbook or "none">`
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

## Step 2: Runbook (optional)

Use `AskUserQuestion` to ask if the user has or wants a runbook:

> Do you have — or want — a runbook for this machine?
>
> A runbook is a small graph of markdown docs describing how to test your applications: a slim
> index plus focused sub-docs in `references/` (environment, testing, pages, api, ...). Agents
> load the index always and pull in sub-docs on demand.
>
> 1. **No runbook** (showboat will infer testing approach from the codebase each time)
> 2. **Use an existing file** (Please provide the full absolute path below)
> 3. **Auto-generate one** from the current repo (Please provide the full absolute path where the main index should live)

**Logic:**
- Option 1 → omit `runbook` from config. Skip to Step 4.
- Option 2 → validate the path exists and is a `.md` file. Store as `runbook`. Skip to Step 4.
- Option 3 → store the path as `runbook` and remember to auto-generate after the config is written. The file itself does not need to exist yet; its parent directory must either exist or be creatable.

If the path contains `~`, expand it using `$HOME`. If the path does not end in `.md`, reject it and re-ask.

If the user picks Option 3 but the current working directory is not a git repo, warn them — auto-generation pulls context from the current repo, so running init from outside a real project produces a low-value skeleton. Let them fall back to Option 1 or 2.

## Step 3: Inline testing details (only if auto-generating)

If the user chose Option 3, use `AskUserQuestion` to collect any details they already know that would otherwise have to be inferred:

> Anything you want to pin down before I explore the repo? These override anything I'd guess from the code.
>
> Examples: "app runs on port 8080", "login is `test@example.com` / `password123`", "use the staging URL https://staging.example.com".
>
> Leave blank to skip.

Store the answer as `inline_details` (may be empty).

## Step 4: Confirm

Use `AskUserQuestion` to show a summary and ask for confirmation:

> Ready to configure showboat:
>
>   Base directory:    `<base_dir>/<repo-name>/` (one folder per repo)
>   Runbook:           `<runbook path>` (or "none — will infer from codebase")
>   Auto-generate:     `<yes / no>`
>   Config file:       `~/.showboat/config.json`
>
>   Output format: Obsidian-compatible markdown (frontmatter, wikilinks, Dataview properties)
>
> Proceed?

Options: `Yes, apply` / `No, cancel`

If the user cancels, exit with "Configuration cancelled. Nothing was changed."

## Step 5: Apply Config

Call the helper script to handle all setup deterministically:

```bash
bash "${CLAUDE_SKILL_DIR}/scripts/setup-showboat.sh" "<base_dir>" "<runbook or empty>"
```

This script will:
- Create `~/.showboat` directory
- Handle existing symlinks at `~/.showboat`
- Create the artifact base directory
- Write `config.json` with `base_dir`, and optionally `runbook`
- Validate everything succeeded

If it fails, it exits with code 1 and prints an error.

## Step 6: Auto-Generate Runbook (only if user chose Option 3)

Skip this step if the user chose Option 1 or Option 2.

Read `${CLAUDE_SKILL_DIR}/references/initial-runbook.md`. It tells you exactly how to:

1. Classify the app type
2. Explore the repo (use sub-agents for parallel exploration on large repos)
3. Write the main index at `$RUNBOOK` and the sub-docs under `$RUNBOOK_DIR/references/`
4. Cross-link the graph

Use `inline_details` (from Step 3) to override anything the code would otherwise imply.

The graph shape is defined in `${CLAUDE_PLUGIN_ROOT}/references/runbook-structure.md` — read it before writing. Future `/showboat:ingest` runs will extend this graph with corrections from real testing sessions, so keep the initial docs accurate but not exhaustive.

Ensure the parent directory exists before writing:

```bash
RUNBOOK_DIR="$(dirname "<runbook path>")"
mkdir -p "$RUNBOOK_DIR/references"
```

## Step 7: Done

Once everything succeeds, say:

```
Showboat initialized.

  Artifacts stored at: <base_dir>/<repo-name>/
  Config file:         ~/.showboat/config.json

  Output structure (per feature):
    <feature>/demo/
      <feature>.md         — demo document (built by showboat CLI)
      introspection.md     — corrections and lessons from testing sessions

  Runbook: <path or "not configured — showboat will infer from codebase">
```

If the runbook was auto-generated, add:

```
  Initial graph written:
    <runbook-path>                         — main index (always loaded)
    <runbook-dir>/references/*.md          — sub-docs (loaded on demand)

  Run /showboat:ingest after a demo to extend this graph with new learnings.
```

If Rodney or shot-scraper were missing during the prerequisites check, add a reminder:

```
Note: Screenshot capture is not available. To enable it, install one of:
  uv tool install rodney                             (recommended — full browser automation)
  pip install shot-scraper && shot-scraper install   (simpler — single-shot screenshots)
```

## Notes

- `base_dir` in config stores the root WITHOUT the repo-name segment. The `resolve-basedir.sh` script appends the current repo name at runtime.
- The config file is always written to `~/.showboat/config.json` for consistency across repos, but artifacts can be stored anywhere (Obsidian vault, Dropbox, etc.).
- The runbook and its `references/` folder are shared across repos by default — they live wherever the user points. If a user wants per-repo runbooks, they can run `/showboat:init --reset` from inside each repo with a different path.
