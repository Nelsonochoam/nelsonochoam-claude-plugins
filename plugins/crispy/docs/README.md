# Crispy Documentation

## Getting Started

- **[Usage Guide](./usage.md)** — Phase descriptions, typical workflow, quick plan workflow, flexible entry points, why it works

## How Crispy Works

- **[Artifact Storage](./artifacts.md)** — How files are organized, write-first review pattern, choosing storage locations
- **[Using with Markdown Readers](./markdown-readers.md)** — Store artifacts in Obsidian, Logseq, Dendron, or any markdown app
- **[Implementation Details](./implementation.md)** — Task metadata, execution strategies (sequential, parallel, external), Ralph loop automation

## Troubleshooting

### Configuration Issues

**I already ran `/crispy-init` and want to change my setup**

Run `/crispy-init --reset` to reconfigure and choose a new storage location.

**I want to store artifacts in a markdown reader but already have them elsewhere**

Run `/crispy-init --reset` and choose the new storage location. Existing artifacts in the old location remain there. You can move them manually if needed.

### Artifact Issues

**My markdown reader isn't picking up new files**

Check that:
- The storage path you provided is correct (run `cat ~/.crispy/config.json`)
- Your markdown reader is watching that directory
- The app has refreshed (some tools require manual refresh or restart)

### Execution Issues

**I want to run multiple phases in parallel**

See [Execution Strategies](./implementation.md#execution-strategies) — use separate sessions or worktrees, and check the manifest's dependency data to see which phases are independent.

**I want to automate the full workflow**

See [Ralph Loop Integration](./implementation.md#ralph-loop-integration) — it orchestrates sequential execution automatically.
