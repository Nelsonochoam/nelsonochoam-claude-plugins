# Multiple Wikis

How to configure and use multiple wiki vaults with the wiki plugin.

## Setup

If you keep your Obsidian vaults in a common directory, point each one to a named wiki. For example, with this structure:

```
~/Projects/vaults/
├── personal/     — personal knowledge base (AI, Ideas, Meetings, ...)
├── playbooks/    — runbooks and testing playbooks
└── projects/     — project-specific notes (qnr-server, ...)
```

Run `/wiki:init` once per vault:

```
/wiki:init personal   → path: ~/Projects/vaults/personal
/wiki:init playbooks  → path: ~/Projects/vaults/playbooks
/wiki:init projects   → path: ~/Projects/vaults/projects
```

Each init adds `raw/` and `wiki/` subdirectories alongside your existing Obsidian folders — it does not touch existing notes. The result in `~/.wiki/config.json`:

```json
{
  "wikis": {
    "personal": "/Users/you/Projects/vaults/personal",
    "playbooks": "/Users/you/Projects/vaults/playbooks",
    "projects": "/Users/you/Projects/vaults/projects"
  },
  "default": "personal"
}
```

## Targeting a wiki

Three ways to specify which wiki a command should use, in priority order:

### 1. `--wiki` flag (per-command)

```bash
/wiki:ingest --wiki projects path/to/runbook.md
/wiki:query --wiki personal "What do I know about transformers?"
/wiki:lint --wiki playbooks --fix
```

### 2. `WIKI` env var (session-wide)

By name — looks up the path in config:

```bash
export WIKI=projects
/wiki:ingest runbook.md       # → projects vault
/wiki:ingest postmortem.md    # → projects vault (still)
/wiki:query "What broke?"     # → projects vault
```

By path — bypasses config entirely:

```bash
WIKI=~/Projects/vaults/personal /wiki:ingest article.md
```

### 3. Default (no flag, no env var)

Uses the `default` key in config. Set or change the default by running `/wiki:init` and choosing "Yes, set as default" for that wiki.

## Typical workflows

### Focused session on one vault

```bash
export WIKI=projects
/wiki:ingest path/to/new-runbook.md
/wiki:ingest path/to/postmortem.md
/wiki:query "What patterns show up in our incidents?"
/wiki:lint --fix
```

### Ad-hoc cross-vault queries

```bash
# Ingest a personal article, then check projects for related knowledge
/wiki:ingest --wiki personal https://interesting-article.com
/wiki:query --wiki projects "How does this apply to qnr-server?"
```

### Showboat integration

Point showboat's `knowledge_index` at whichever vault holds your testing knowledge:

```json
{
  "base_dir": "/path/to/showboat-output",
  "knowledge_index": "/Users/you/Projects/vaults/playbooks/wiki/index.md"
}
```

Now `/showboat:demo` reads from your playbooks vault when testing. Ingest new runbooks and showboat automatically benefits next session.

## When to use multiple wikis vs. one

Use **separate wikis** when knowledge is genuinely siloed — different schemas, confidentiality boundaries, or distinct audiences (testing runbooks vs. personal research).

Use **one wiki** when knowledge overlaps and cross-linking would be valuable. The folder structure (`entities/`, `concepts/`, etc.) and tags handle organization within a single vault without needing multiple wikis.
