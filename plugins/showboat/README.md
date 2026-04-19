# Showboat

A Claude Code skill layer built around Simon Willison's [showboat](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/) and [Rodney](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/) CLIs — so agents can prove their work by actually running the app, not just claiming it works.

## The Problem

When a coding agent finishes work, you have no proof it works beyond the agent's word. Tests passing is necessary but not sufficient — the UI might be broken, the API might return garbage, the feature might not match what you asked for.

This plugin makes the agent **show its work** the way a human tester would: navigate to the feature, interact with it, observe the results, and capture everything. Because evidence is captured by *executing commands* — not by the agent writing markdown — the output is genuine proof, not a summary.

## How It Works

The core is the showboat CLI: it builds an executable markdown document by running real commands. `showboat exec` runs a command and captures its output. `showboat image` copies in a screenshot. `showboat verify` re-runs everything and diffs the output. The agent never writes evidence directly.

Rodney provides the browser side: a persistent Chrome session the agent can navigate, click, fill forms, read DOM state, and screenshot — all via CLI commands that showboat captures as proof.

### Workflow

1. **Configure** (`/showboat:init`) — Tell showboat where to write output and (optionally) auto-generate a testing runbook by exploring the current repo. The runbook is a graph of docs agents load on demand.
2. **Demonstrate** (`/showboat:demo`) — After implementing a feature, the agent manually tests it — navigating the UI with rodney, hitting APIs with curl — and builds a demo document from real captured output.
3. **Re-verify** (`/showboat:verify`) — Re-run all code blocks in a demo to check for regressions.
4. **Record corrections** (`/showboat:introspect`) — When testing goes wrong or you correct the agent, write the corrections to `introspection.md` so they're available next time.
5. **Ingest learnings** (`/showboat:ingest`) — Generalize the per-feature corrections into the shared runbook so future demos benefit from them.

## Skills

### `/showboat:init`

One-time setup per machine. Interactive wizard.

```bash
/showboat:init         # first-time setup
/showboat:init --reset # reconfigure
```

Writes `~/.showboat/config.json`. The output directory can be an Obsidian vault, a notes folder, or any path. For the runbook you can:

- **Skip it** — showboat will infer testing approach from the codebase each demo.
- **Point at an existing file** — use your own runbook as-is.
- **Auto-generate one from the current repo** — showboat explores the repo (entry points, dev-server scripts, test commands, routes, API endpoints) and writes a slim index plus focused sub-docs in `references/`. That graph is then extended by `/showboat:ingest` as testing sessions surface corrections.

See [Runbook](#runbook) below.

### `/showboat:demo`

The core skill. Manually tests a feature and builds a demo document using the showboat CLI.

```bash
/showboat:demo add-user-search
/showboat:demo add-user-search "app is running on http://localhost:3278"
```

What it does:
1. Reads `git diff` to understand what changed
2. Loads the runbook (if configured) for testing knowledge — login steps, URLs, known patterns
3. If no runbook: discovers testing info from the codebase (package.json, route files, etc.)
4. Initializes the demo document: `showboat init <file> "<title>"`
5. **Manually tests the feature** — this is the main event:
   - Browser features: rodney navigates, interacts, asserts, and screenshots
   - API features: curl hits endpoints with real requests, captures full responses
6. Runs the relevant test suite as supporting evidence
7. Closes with `showboat verify` to confirm all blocks still match

The demo document is built entirely by showboat commands. Every `showboat exec` block is executable and verifiable. Every screenshot was actually taken.

**Output**: `<base_dir>/<repo>/<feature>/demo/<feature>.md`

Example demo document structure:
```markdown
# Demo: Add User Search

*2026-04-15T10:30:00Z*

Added real-time search filtering to the users page...

## Manual Browser Verification

\`\`\`bash
rodney start
\`\`\`
\`\`\`output
Chrome launched (headless)
\`\`\`

\`\`\`bash
rodney open 'http://localhost:3000/users'
\`\`\`

![Initial state](before.png)

\`\`\`bash
rodney input '#search' 'test'
rodney waitstable
\`\`\`

\`\`\`bash
rodney exists '.user-row'
\`\`\`
\`\`\`output
found
\`\`\`

![Search results showing filtered users](after.png)
```

### `/showboat:verify`

Re-runs all code blocks in a demo document and diffs the output against what was captured.

```bash
/showboat:verify add-user-search
```

Delegates to `showboat verify <file>`. Exits 0 if everything matches, 1 if any output has changed.

### `/showboat:introspect`

Captures corrections and lessons from a testing session into `introspection.md`.

```bash
/showboat:introspect
/showboat:introspect add-user-search
```

Reviews the current conversation for corrections you gave the agent (wrong routes, missing auth steps, selector fixes, timing issues, etc.) and appends them to `$DEMO_BASE/introspection.md`. Simple and flat — no index files, no categories.

### `/showboat:ingest`

Takes an introspection file and merges its learnings into the shared runbook, preserving progressive-loading structure (slim index + focused sub-docs in `references/`).

```bash
/showboat:ingest                                    # uses $DEMO_BASE/introspection.md for the current feature
/showboat:ingest /path/to/some/introspection.md     # explicit file
```

What it does:

1. Resolves the introspection file — argument first, then `$DEMO_BASE/introspection.md` as the default
2. Resolves the configured runbook path and reads the current graph (main index + all `references/*.md`)
3. Categorizes each introspection entry (interaction, environment, commands, etc.) and maps it to the right sub-doc
4. Merges each entry: creates or updates sub-docs, cross-links related sections, skips duplicates
5. Updates the main index only when a new sub-doc was added or a top-level constant changed

Use it right after `/showboat:introspect` to turn per-feature corrections into shared knowledge.

## Runbook

The runbook is a **graph** of markdown docs that tells agents how to test your application — a slim index plus focused sub-docs in `references/` (environment, testing, pages, api, cli, ...). Agents load the index always and pull in sub-docs on demand, so knowledge scales without bloating context. Configure it once in `/showboat:init`.

```json
{
  "base_dir": "/path/to/output",
  "runbook": "/path/to/runbook.md"
}
```

Example structure:

```
<runbook-dir>/
  runbook.md                — slim index (always loaded): quick constants + task→doc map
  references/
    environment.md          — login, env vars, dev-server, prerequisites
    testing.md              — test commands, type-check, build
    pages.md                — routes, pages, auth requirements (web apps)
    api.md                  — endpoints and example curl calls (APIs)
    cli.md                  — command invocations (CLIs)
```

Sub-docs cross-link to each other using section anchors, so an agent reading `pages.md` can jump straight to the auth snippet in `environment.md` without loading the whole graph.

**Two ways to get one:**

- `/showboat:init` auto-generates an initial graph by exploring the current repo — entry points, dev-server scripts, test commands, route definitions, OpenAPI specs.
- `/showboat:ingest` extends the graph over time by merging corrections from `/showboat:introspect` runs into the right sub-docs.

If no runbook is configured, the demo skill infers testing information from the codebase each time — package.json scripts, route files, git diff. It works without a runbook; it just works better (and cheaper) with one.

## Output Structure

```
<base_dir>/<repo>/<feature>/demo/
  <feature>.md          — demo document (built by showboat CLI)
  introspection.md      — corrections and lessons from testing sessions
```

## Browser Automation

Showboat detects available browser tools in priority order:

1. **[Rodney](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/)** (preferred) — persistent multi-turn Chrome session via DevTools Protocol. Navigate, click, fill forms, assert, screenshot — all captured as proof.
2. **[shot-scraper](https://shot-scraper.datasette.io/)** — single-shot screenshots, no interaction.
3. **Chrome headless** — built into macOS, fallback only.

Install:
```bash
uv tool install rodney      # preferred
pip install shot-scraper && shot-scraper install
```

Without any browser tool, showboat still captures command outputs, test results, and API responses — just no screenshots.

## Anti-Fabrication Design

Every piece of evidence comes from executing a real command. The showboat CLI runs the command and writes the output to the document — the agent doesn't write evidence directly. An agent can't claim "tests passed" and write fake output; it has to run `showboat exec <file> bash "npm test"` and the actual output gets captured.

`showboat verify` completes the loop: re-running the document later will catch any drift between what was captured and what happens now.

## Typical Workflows

### After implementing a feature

```bash
/showboat:demo my-feature
```

### When the demo gets something wrong

```bash
/showboat:demo my-feature           # agent uses wrong route
# You correct: "the page is at /app/users not /users"
/showboat:introspect my-feature     # record the correction
/showboat:demo my-feature           # retry with the correction in context
```

### Generalize corrections into the runbook

```bash
/showboat:introspect my-feature     # captures corrections for this feature
/showboat:ingest                    # merges them into the shared runbook
```

### Check for regressions after unrelated changes

```bash
/showboat:verify my-feature
```

## Configuration

Config file: `~/.showboat/config.json`

```json
{
  "base_dir": "/path/to/your/output/directory",
  "runbook": "/path/to/runbook.md"
}
```

- **`base_dir`** — where demo artifacts go. Per-repo subdirectories are created automatically.
- **`runbook`** — (optional) markdown file describing how to test your applications. Can be a single self-contained file or an entry point that links to other files — showboat follows links progressively to load only what's relevant.

## Installation

```
/plugin install showboat@nelsonochoam
```

## References

- **[Showboat](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/)** by Simon Willison — The CLI this plugin is built around. Builds markdown demo documents by executing commands and capturing output. Install: `uvx showboat`
- **[Rodney](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/)** by Simon Willison — Browser automation CLI via Chrome DevTools Protocol. Install: `uvx rodney`
- **[Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** by Andrej Karpathy — Three-layer wiki architecture that influenced the progressive knowledge loading pattern.
- **[obsidian-mind](https://github.com/breferrari/obsidian-mind)** by breferrari — Hook patterns, frontmatter conventions, and progressive context loading that influenced showboat's output format.
