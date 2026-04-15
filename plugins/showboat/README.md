# Showboat

A Claude Code skill layer that wraps Simon Willison's [showboat](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/) and [Rodney](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/) tooling with a memory management layer — so agents can prove their work and get better at testing over time.

Showboat (the CLI) captures command outputs. Rodney (the browser automation CLI) captures screenshots. This plugin orchestrates them into a structured workflow: capture evidence, assemble demos, learn from failures, and feed corrections back into a knowledge base so the next session starts smarter.

## The Problem

When a coding agent finishes work, you have no proof it works beyond the agent's word. Tests passing is necessary but not sufficient — the UI might be broken, the API might return garbage, the feature might not match what you asked for. Manual QA is slow, and asking the agent "does it work?" just gets you "yes" with no evidence.

This plugin makes the agent **show its work**. Every piece of evidence comes from real execution — commands are actually run via showboat, screenshots are taken via Rodney, HTTP calls are actually made. The agent can't fabricate results because the capture tools execute the commands, not the agent. On top of that, a memory layer records what went wrong and feeds it back — so the agent doesn't repeat the same mistakes.

## How It Works

Showboat follows a five-step workflow:

1. **Configure** (`/showboat-init`) — Tell showboat where to write output (an Obsidian vault, a notes directory, anywhere)
2. **Describe** (`/showboat-context`) — Create a testing playbook for the repo: how to start the dev server, what pages exist, what APIs to hit, what tests to run
3. **Demonstrate** (`/showboat-demo`) — After implementing a feature, capture evidence and assemble a demo document
4. **Re-verify** (`/showboat-verify`) — Re-run all checks from a demo to detect regressions over time
5. **Learn** (`/showboat-introspect`) — When things go wrong, extract lessons from failures and your corrections, feed them back into the testing context and the wiki knowledge base

## Skills

### `/showboat-init`

One-time setup per machine. Configures where demo artifacts are stored.

```bash
/showboat-init              # interactive wizard
/showboat-init --reset      # reconfigure
```

Writes `~/.showboat/config.json` with a `base_dir` path. The output directory can be an Obsidian vault, a Dropbox folder, or any path. All output uses Obsidian-compatible markdown regardless of where it's stored.

### `/showboat-context`

Creates a testing playbook for the current repo. Run once per repo, update when the app changes.

```bash
/showboat-context           # explore repo and create playbook
/showboat-context --update  # refresh an existing playbook
```

The skill explores your codebase to auto-discover:
- **App type** (web-app, API, CLI, library, hybrid)
- **Dev server** commands and the "ready signal" in stdout
- **Test suites** (unit, integration, e2e, lint, type check)
- **Pages & routes** with verification criteria
- **API endpoints** with example curl commands
- **CLI commands** with expected output

The result is a `testing-context.md` file that agents use to know *how* to verify changes.

#### Skip context generation — bring your own

If you already know how your app should be tested, you don't need `/showboat-context` at all. Just write a markdown file with the testing details and place it at `<base_dir>/<repo>/testing-context.md`. Showboat will pick it up.

This works the same way as the knowledge index — it's just a markdown file that showboat reads. The format is flexible, but at minimum include:

```markdown
# Testing Context

## Dev Server
npm run dev — ready when you see "Local: http://localhost:3000"

## Test Command
npm test

## Pages
- /users — has a search bar, user table, pagination
- /dashboard — requires login (test@example.com / password123)

## API
- GET /api/users — returns paginated user list
- POST /api/users — creates a user, expects JSON body
```

You can also point your `knowledge_index` (configured in `/showboat-init`) at this file or at any markdown index that links to testing runbooks, wiki pages, or other docs. Showboat treats both the same way — it reads the file, follows relevant links, and uses what it finds to inform testing. The only difference is that `/showboat-context` auto-generates the file from code inspection, while you can write one by hand in 30 seconds if you already know the answers.

### `/showboat-capture`

Captures a single piece of evidence. Use during development or let `/showboat-demo` auto-capture.

```bash
/showboat-capture add-user-search npm test
/showboat-capture add-user-search http://localhost:3000/users
/showboat-capture add-user-search "curl -s localhost:3000/api/users?q=test"
```

Evidence types:
- **command** — runs a shell command, captures stdout/stderr/exit code/duration
- **screenshot** — takes a headless browser screenshot of a URL
- **http** — makes an HTTP request, captures status code and response body
- **diff** — captures git diff summary

Evidence is stored as append-only JSONL at `evidence/<feature>.jsonl`. Each line is a self-contained JSON record:

```json
{"id":"ev-001","type":"command","timestamp":"2026-04-15T10:30:00Z","command":"npm test","exit_code":0,"stdout":"42 passed, 0 failed","duration_ms":3200,"label":"Unit tests"}
```

### `/showboat-demo`

The core skill. Assembles a demo document from evidence, testing context, and git history.

```bash
/showboat-demo add-user-search
```

What it does:
1. Reads the testing context to understand the app
2. Reads any evidence already captured for this feature
3. Runs `git diff` to understand what changed
4. Auto-captures missing evidence (tests, screenshots, API calls) if the evidence log is sparse
5. Assembles everything into a structured demo document with Obsidian frontmatter
6. Updates the demo index and testing context

The output is a demo document like this:

```markdown
---
date: 2026-04-15
feature: add-user-search
repo: my-app
status: verified
tags: [showboat/demo, showboat/verified]
evidence_count: 5
---

# Demo: Add User Search

## Summary
Added real-time search filtering to the users page...

## What Changed
| File | Change |
|------|--------|
| `src/components/UserSearch.tsx` | New search component |
| `src/api/users.ts` | Added search parameter |

## Evidence

### Tests
#### Unit tests
> Captured: 2026-04-15 10:30:00 | Exit code: 0 | Duration: 3.2s
\`\`\`bash
$ npm test
\`\`\`
\`\`\`
Tests: 42 passed, 0 failed
\`\`\`

### Screenshots
#### Search results for 'test'
![Search results](../evidence/assets/ev-002-search.png)

### API Verification
#### GET /api/users?search=test
> Status: 200 | Duration: 45ms
\`\`\`json
{"users": [{"id": 1, "name": "Test User"}], "total": 1}
\`\`\`

## Verification Checklist
- [x] Unit tests pass (exit code 0)
- [x] Search UI renders (screenshot captured)
- [x] API returns filtered results (200 OK)

## Verification Commands
\`\`\`json
[
  {"type": "command", "command": "npm test", "expect_exit": 0},
  {"type": "http", "method": "GET", "url": "http://localhost:3000/api/users?search=test", "expect_status": 200}
]
\`\`\`
```

### `/showboat-verify`

Re-runs all verification commands from an existing demo to check for regressions.

```bash
/showboat-verify add-user-search
```

What it does:
1. Reads the demo's `Verification Commands` JSON block
2. Starts the dev server if needed (using testing context)
3. Re-executes each command/HTTP call/screenshot
4. Compares results against the original evidence (exact match for exit codes and HTTP status, fuzzy match for stdout)
5. Writes a verification report to `verifications/<feature>-<date>.md`
6. Updates the demo's status to `verified` or `regression`

### `/showboat-introspect`

The learning loop. When testing fails or you correct the agent, introspect extracts structured learnings and feeds them back into the system.

```bash
/showboat-introspect                    # extract learnings from all features
/showboat-introspect add-user-search    # scope to a specific feature
```

What it does:
1. Scans evidence logs for failures (non-zero exits, 4xx/5xx responses, startup failures)
2. Reads verification reports for regressions (FAIL and SKIP results)
3. Reads the current conversation for corrections you gave the agent (wrong routes, auth requirements, timing issues, selectors, etc.)
4. Classifies each learning into a category: `navigation`, `auth`, `timing`, `interaction`, `data`, `environment`, `workflow`, `tooling`
5. Writes a structured learnings document to `learnings/<date>-introspect.md`
6. **Directly updates `testing-context.md`** with corrections — fixing wrong routes, adding auth steps, updating dev server commands
7. Suggests running `/wiki-ingest` on the learnings to build long-term testing knowledge

This creates two feedback loops:
- **Short loop**: introspect fixes the testing context, so the next `/showboat-demo` gets it right
- **Long loop**: the wiki ingests learnings, extracts patterns and pitfalls into concept pages, so testing knowledge compounds over time

Example learnings:
```markdown
### 1. Dashboard requires authentication

- **Category**: auth
- **What happened**: Took screenshot of /dashboard, got login redirect
- **Correct approach**: Log in at /auth/login with test@example.com first
- **Source**: User correction

### 2. API base path changed

- **Category**: navigation
- **What happened**: GET /api/v1/users returned 404
- **Correct approach**: API moved to /api/v2/users
- **Source**: Evidence log (HTTP 404)
```

## Output Structure

```
<base_dir>/<repo>/
  testing-context.md              # Repo testing playbook (updated by introspect)
  demos/
    index.md                      # Auto-generated index with Dataview queries
    add-user-search.md            # Demo document
    fix-login-redirect.md
  evidence/
    assets/                       # Screenshots
      ev-002-search.png
    add-user-search.jsonl          # Evidence log
    fix-login-redirect.jsonl
  verifications/
    add-user-search-2026-04-20.md  # Re-verification report
  learnings/
    index.md                       # Learnings index
    2026-04-20-introspect.md       # Introspection learnings
```

## Anti-Fabrication Design

The core principle from Willison's showboat: evidence is captured by **executing commands**, not by accepting pre-written output from the agent. The capture scripts (`capture-command.sh`, `detect-capabilities.sh`) run the actual commands and record what happens. This prevents the agent from:

- Writing fake test output
- Claiming screenshots were taken when they weren't
- Fabricating API responses
- Reporting success when commands actually failed

Evidence files are append-only — the agent cannot edit or delete previous evidence entries.

## Browser Automation & Screenshots

Showboat auto-detects available browser tools in this priority order:

1. **[Rodney](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/)** (preferred) — Simon Willison's browser automation CLI built on Chrome DevTools Protocol. Manages multi-turn browser sessions: `rodney start`, `rodney open <url>`, `rodney click <selector>`, `rodney js <code>`, `rodney screenshot <path>`, `rodney stop`. When Rodney is available, showboat reuses a single browser session across all screenshots in a demo, enabling interactive captures (click buttons, fill forms, navigate between pages).
2. **[shot-scraper](https://shot-scraper.datasette.io/)** — Simon Willison's single-shot screenshot CLI. Good for simple page captures without interaction.
3. **Google Chrome** headless mode (built into macOS)
4. **Playwright** (if installed)
5. **Puppeteer** (if installed)

If no browser tool is available, showboat still works — it captures command outputs, HTTP responses, and git diffs. Screenshots are recorded as `screenshot_unavailable` with instructions on how to install a browser tool.

To enable screenshots (pick one):
```bash
uvx rodney                                           # preferred — full browser automation
pip install shot-scraper && shot-scraper install      # simpler — single-shot screenshots
```

## Typical Workflows

### After implementing a feature

```bash
# After any implementation workflow (crispy, manual, etc.)
/showboat-demo my-feature           # agent proves it works
```

### When the demo gets things wrong

```bash
/showboat-demo my-feature           # demo fails — wrong routes, missing auth, etc.
# You correct the agent: "the page is at /app/users not /users"
/showboat-introspect my-feature     # extracts learnings, fixes testing context
/showboat-demo my-feature           # retry — now it gets it right
```

### Building long-term testing knowledge

```bash
/showboat-introspect                                      # extract learnings
/wiki-ingest <base_dir>/<repo>/learnings/2026-04-20-introspect.md  # wiki digests them
# Future testing sessions benefit from accumulated knowledge
```

### Standalone verification

```bash
# After any coding session
/showboat-demo fix-login-bug

# A week later, check it still works
/showboat-verify fix-login-bug
```

### Incremental evidence capture

```bash
# Capture evidence as you go during development
/showboat-capture my-feature npm test
/showboat-capture my-feature http://localhost:3000/my-page
/showboat-capture my-feature "curl -s localhost:3000/api/health"

# Assemble everything at the end
/showboat-demo my-feature
```

## Knowledge Index

Showboat can optionally point to a **knowledge index** — a markdown file that serves as an entry point to testing knowledge. This could be:

- A wiki index (e.g., from the wiki plugin's `wiki/index.md`)
- An Obsidian Map of Content (MOC)
- A runbook or testing playbook directory index
- Any markdown file with links to relevant docs

Configure it during `/showboat-init` or edit the config directly. Showboat loads from the index **progressively** — it reads the index, follows links relevant to the current feature, and stops. It doesn't load the entire knowledge base into context.

This is how the memory layer works:
1. `/showboat-introspect` writes learnings files
2. You (or the wiki plugin) organize those learnings into a knowledge base
3. You point showboat's `knowledge_index` at that knowledge base
4. Next time `/showboat-demo` runs, it reads the index and follows relevant links before testing

No specific knowledge base structure is required. Showboat follows whatever links it finds. In practice, the knowledge index and the testing context serve the same purpose — they're both markdown files that tell showboat how to test things. The difference is scope:

- **`testing-context.md`** is per-repo: "how to test *this* app"
- **`knowledge_index`** is cross-repo: "how to test things *in general*" — patterns, pitfalls, auth flows, environment setup that applies across projects

## Configuration

Config file: `~/.showboat/config.json`

```json
{
  "base_dir": "/path/to/your/output/directory",
  "knowledge_index": "/path/to/your/knowledge/index.md"
}
```

- `base_dir` — where demo artifacts go (per-repo subdirectories created automatically)
- `knowledge_index` — (optional) path to a markdown index file with testing knowledge

All output uses Obsidian format (YAML frontmatter, `[[wikilinks]]`, Dataview-compatible properties, `showboat/*` tag namespace).

## Installation

```
/plugin install showboat@nelsonochoam
```

## References

This plugin wraps and extends the following tools:

- **[Showboat](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/)** by Simon Willison — The CLI that this plugin is built around. Showboat builds markdown demo documents by *executing* commands and capturing their output, preventing agents from fabricating results. Install: `uvx showboat`
- **[Rodney](https://simonwillison.net/2026/Feb/10/showboat-and-rodney/)** by Simon Willison — Browser automation CLI built on Chrome DevTools Protocol. Manages multi-turn browser sessions (navigate, click, screenshot) for capturing web UI state. Install: `uvx rodney`

The memory management layer was informed by:

- **[Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** by Andrej Karpathy — The three-layer wiki architecture (raw sources, compiled wiki, schema) influenced the knowledge index pattern and how learnings feed into a knowledge base.
- **[obsidian-mind](https://github.com/breferrari/obsidian-mind)** by breferrari — An Obsidian vault giving AI agents persistent memory. Its hook patterns, frontmatter conventions, and progressive context loading influenced showboat's output format.
- **[Self-Evolving Claude Code Memory with Obsidian Hooks](https://www.mindstudio.ai/blog/self-evolving-claude-code-memory-obsidian-hooks)** by MindStudio — The memory extraction pattern (session end → extract learnings → write to vault) informed the introspect skill design.
- **[claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian)** by AgriciDaniel — A knowledge companion using Karpathy's wiki pattern. Its approach to autonomous note organization influenced the testing context and demo index structures.
- **[Agentic Note-Taking with Obsidian and Claude Code](https://www.stefanimhoff.de/agentic-note-taking-obsidian-claude-code/)** by Stefan Imhoff — Practical patterns for AI-maintained Obsidian vaults, including frontmatter conventions and Dataview integration.
