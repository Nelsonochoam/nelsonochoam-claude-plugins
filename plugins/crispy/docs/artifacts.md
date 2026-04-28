# Artifact Storage

## How Artifacts Are Stored

By default, files go in `<base_dir>/<repo-name>/<feature-name>/` (one folder per repo):

```
<base_dir>/
  my-repo/
    my-feature/
      manifest.json          ← phase status + implementation metadata
      1-intent.md
      2-research-questions.md
      3-research.md
      4-design.md
      5-structure-outline.md
      6-plan.md                ← master index (overview, dependency graph, links to phase docs)
      artifacts/             ← images, screenshots, mockups shared during any phase
        current-ui.png
        proposed-mockup.jpg
        ...
      phases/
        phase-1.md           ← self-sufficient implementation doc
        phase-2.md
        ...
```

If you opt into the **flat layout** during `/crispy:init` (useful for features that span multiple repos), files go directly in `<base_dir>/<feature-name>/` instead:

```
<base_dir>/
  my-feature/
    1-intent.md
    ...
```

The `artifacts/` subfolder stores images shared during any phase — screenshots of current UI, mockups, whiteboard photos, diagrams, etc. These are referenced from markdown documents using relative links like `![description](artifacts/filename.png)`, which renders natively in Obsidian, Logseq, and most markdown viewers.

`manifest.json` tracks implementation phase status (pending/done), dependencies, and file pointers. It is created by `/crispy:plan` and only contains `implementation` entries — it does not record planning phase status. **Prerequisites are enforced** — a deterministic script (`check-prerequisites.sh`) checks planning phase completion by file existence (e.g., `1-intent.md`, `3-research.md`) and implementation phase completion via `manifest.json`. The `phases/` directory contains one markdown file per implementation phase — each is a self-sufficient document with all the details an agent needs to implement that phase.

## Choosing Your Storage Location

During `/crispy:init`, you choose where to store artifacts:

**Default location:**
```
~/.crispy/
```

**Custom locations** — choose any path based on your workflow:
- Inside an Obsidian vault: `/Users/you/Documents/MyVault/crispy`
- Inside a Logseq graph: `/Users/you/Logseq/graphs/my-graph/crispy`
- In a notes directory: `/Users/you/Notes/crispy`
- Anywhere else: `/Users/you/Projects/knowledge-base/crispy`

The config file is always stored at `~/.crispy/config.json` so crispy can find your storage location. But the artifacts themselves can live anywhere.

## Write-First Review Pattern

Every skill writes its output to the artifact storage **before** asking for your review. You review the file directly (open it in your editor), request changes, and the skill edits the file in place. Once you confirm, the manifest is updated and you move to the next phase.

This keeps the conversation clean — you're reviewing a structured document, not a wall of text.

## Working Across Multiple Repos

See [Working Across Multiple Repos](./multi-repo.md) for the recommended folder structure, setup, and workflow.

## Changing Your Storage Location

To change where artifacts are stored:

```bash
/crispy:init --reset
```

Answer the prompts to specify a new base directory. Existing artifacts in the old location are not affected.

## Configuration Reference

Crispy stores its config at `~/.crispy/config.json`. You can edit this file directly instead of re-running `/crispy:init`.

**Full schema:**

```json
{
  "base_dir": "/absolute/path/to/artifacts",
  "folders": {
    "git": true
  }
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `base_dir` | string | `~/.crispy` | Absolute path where feature folders are written. Must already exist. |
| `folders.git` | boolean | `true` | When `true`, features are grouped under a repo-name subfolder: `<base_dir>/<repo>/<feature>/`. When `false`, features are written flat: `<base_dir>/<feature>/`. |

**Example — flat layout pointing at an Obsidian vault:**

```json
{
  "base_dir": "/Users/you/Documents/MyVault/crispy",
  "folders": {
    "git": false
  }
}
```

**Notes:**
- The `folders` key is optional. If absent, crispy behaves as if `folders.git` is `true`.
- Changes take effect immediately — no restart needed.
- The config file itself always lives at `~/.crispy/config.json` regardless of where artifacts are stored.
