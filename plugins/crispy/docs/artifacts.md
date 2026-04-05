# Artifact Storage

## How Artifacts Are Stored

All files go in `<base-dir>/<repo-name>/<feature-name>/`:

```
<base-dir>/
  my-repo/
    my-feature/
      manifest.json          ← phase status + task metadata
      intent.md
      research-questions.md
      research.md
      design.md
      structure-outline.md
      plan.md
      tasks/
        phase-1.md           ← self-contained task prompts
        phase-2.md
        ...
```

`manifest.json` tracks which phases are done and contains task metadata (status, dependencies, file paths). Each skill reads it to know where you are and updates it when a phase is confirmed. The `tasks/` directory contains one markdown file per implementation phase — each is a standalone prompt an agent can execute.

## Choosing Your Storage Location

During `/crispy-init`, you choose where to store artifacts:

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

## Multiple Repositories

When working on multiple repos, each gets its own folder under `<base-dir>/<repo-name>/`. If you use the same base directory for all repos, all artifacts appear in the same place organized by repo and feature.

## Changing Your Storage Location

To change where artifacts are stored:

```bash
/crispy-init --reset
```

Answer the prompts to specify a new base directory. Existing artifacts in the old location are not affected.
