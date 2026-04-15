# Using Crispy with Markdown Readers

Crispy artifacts are plain markdown files. You can store them anywhere, including inside directories that markdown readers (Obsidian, Logseq, Dendron, etc.) watch.

## How It Works

When you run `/crispy:init`, choose a storage path. Crispy will organize artifacts as:

```
<your-chosen-path>/
  <repo-name>/
    <feature>/
      1-intent.md
      2-research-questions.md
      3-research.md
      4-design.md
      5-structure-outline.md
      6-plan.md
      phases/
        phase-1.md
        ...
```

If you choose a path inside a markdown reader's directory, all artifacts automatically appear in that app.

## Obsidian

**Storage path to use:** Your Obsidian vault root + `/crispy`

Examples:
- `/Users/you/Documents/MyVault/crispy`
- `/Users/you/Obsidian/main-vault/crispy`

**Steps:**
1. Run `/crispy:init`
2. When asked for storage location, provide: `/path/to/your/vault/crispy`
3. Artifacts now appear in your vault under `crispy/<repo-name>/<feature>/`

**What you get:**
- Full-text search of all artifacts
- Graph view showing connections between features and plans
- Backlinks from other vault notes to crispy artifacts
- Automatic backup/sync of all artifacts with your vault

**Switching vaults:** Run `/crispy:init --reset` and provide the path to your new vault.

## Logseq

**Storage path to use:** Your Logseq graphs folder + `/crispy`

Examples:
- `/Users/you/Logseq/graphs/my-graph/crispy`
- `/Users/you/.logseq/my-graph/crispy`

**Steps:**
1. Run `/crispy:init`
2. When asked for storage location, provide the path to your graph directory
3. Artifacts appear in your graph alongside other notes

## Dendron

**Storage path to use:** Your Dendron vault root + `/crispy`

Example:
- `/Users/you/Dendron/vault/crispy`

**Steps:**
1. Run `/crispy:init`
2. When asked for storage location, provide your Dendron vault root + `/crispy`
3. Artifacts integrate as standard Dendron files

## Other Markdown Readers

Any tool that watches a directory and supports markdown will work. Just point `/crispy:init` to a path inside that tool's directory.

Tools that work well:
- Note-taking apps
- Knowledge base software
- PKM (Personal Knowledge Management) systems
- Any wiki or document store that watches directories

## Default Location (No Integration)

If you don't want artifacts in a markdown reader, use the default:

```bash
/crispy:init
# Choose: Default (~/.crispy/)
```

Artifacts stay in `~/.crispy/` and won't appear in any external app. You can always change this later with `/crispy:init --reset`.

## Changing Storage Location

If you want to move artifacts to a different location or app:

```bash
/crispy:init --reset
```

Choose a new path. Existing artifacts in the old location remain there.
