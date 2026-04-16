# Wiki

Obsidian knowledge base curation using [Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Instead of RAG (re-synthesizing from raw docs every query), the LLM **compiles** raw sources into a structured, cross-referenced wiki that accumulates knowledge over time.

## The Problem

Traditional knowledge management has two failure modes:

1. **Human-maintained wikis decay** — the cost of maintenance is high, so pages go stale, cross-references break, and the wiki becomes unreliable.
2. **RAG starts from scratch every time** — if a question requires synthesizing five documents, RAG pulls and combines them for that one response, then repeats the entire process if asked again tomorrow.

The LLM Wiki pattern solves both: the LLM handles the bookkeeping (summarizing, cross-referencing, filing, consistency checks), and compiled knowledge persists so insights compound rather than evaporate.

## How It Works

The wiki follows Karpathy's three-layer architecture:

```
vault/
├── raw/          Layer 1: Immutable source documents (the LLM reads, never modifies)
│   ├── articles/   Web articles, blog posts
│   ├── papers/     Research papers, reports
│   └── assets/     Images, diagrams, data files
├── wiki/         Layer 2: LLM-compiled pages (entities, concepts, summaries, synthesis)
│   ├── index.md    Content catalog with Dataview queries
│   ├── log.md      Append-only changelog of all operations
│   ├── entities/   People, organizations, products
│   ├── concepts/   Ideas, frameworks, patterns
│   ├── sources/    Source document summaries
│   └── synthesis/  Cross-cutting analysis
└── CLAUDE.md     Layer 3: Schema defining conventions and workflows
```

The key insight: "The tedious part of maintaining a knowledge base is not the reading or the thinking — it's the bookkeeping." You curate sources and ask questions. The LLM handles everything else.

### Graph Structure

Every page links to other pages via `[[wikilinks]]`. Entities link to concepts they're associated with. Concepts link to related concepts. Sources link to the entities and concepts they discuss. Synthesis pages connect everything.

This creates an Obsidian-compatible knowledge graph where:
- **Nodes** = pages (entities, concepts, sources, synthesis)
- **Edges** = `[[wikilinks]]` between pages
- **Clusters** = naturally forming topic groups visible in Obsidian's Graph View

The core rule: **"A note without links is a bug."** Every page must have at least one outbound link. `/wiki:lint` enforces this — orphan pages get flagged, dead links get caught, and missing cross-references get surfaced.

## Skills

### `/wiki:init`

One-time setup. Creates the three-layer vault structure and generates a `CLAUDE.md` schema.

```bash
/wiki:init              # interactive wizard
/wiki:init --reset      # reconfigure
```

Creates:
- `~/.wiki/config.json` with the vault path
- `raw/` directory tree for source documents
- `wiki/` directory tree for compiled pages
- `wiki/index.md` — content catalog with Dataview queries
- `wiki/log.md` — empty operations log
- `CLAUDE.md` — schema defining page conventions, operations, and linting criteria

The schema (`CLAUDE.md`) is the brain of the vault — it tells the LLM how pages should be formatted, how to ingest sources, and what conventions to follow. You can customize it to fit your domain.

### `/wiki:ingest`

The core operation. Point it at a source — a file you've dropped into `raw/`, a URL, or inline text — and the LLM reads it, extracts knowledge, and compiles it into wiki pages. A single source typically touches 10-15 pages.

```bash
# Ingest a file (already in raw/ or anywhere on disk)
/wiki:ingest raw/articles/article.md

# Ingest a URL (fetched and saved to raw/ automatically)
/wiki:ingest https://example.com/article

# Ingest inline text/topic
/wiki:ingest "The key differences between transformers and RNNs are..."
```

What happens during ingest:

1. **Read the source** — parse the document, extract key entities, concepts, and takeaways
2. **Discuss** — the LLM surfaces its read (key takeaways, entities, concepts it found) and asks what you want to emphasize before writing anything
3. **Read index** — check `wiki/index.md` (the single source of truth) to see what pages already exist; no folder scanning
4. **Save raw source** — copy to `raw/articles/` or `raw/papers/` if not already there (immutable archive)
5. **Create source summary** — write `wiki/sources/<name>.md` shaped by your guidance
6. **Create/update entity pages** — for each significant person, organization, or product, create or update `wiki/entities/<name>.md`
7. **Create/update concept pages** — for each key idea or framework discussed, create or update `wiki/concepts/<name>.md`
8. **Cross-link** — add `[[wikilinks]]` between all related pages, and update existing pages that should link to new content
9. **Check for synthesis** — if the source connects to existing knowledge in novel ways, create a `wiki/synthesis/<name>.md` page
10. **Update index** — add all new pages to `wiki/index.md`
11. **Log the operation** — append to `wiki/log.md` via script (parseable with `grep "^## \[" log.md | tail -5`)

### `/wiki:query`

Search the wiki and synthesize an answer grounded in wiki pages with `[[wikilink]]` citations.

```bash
/wiki:query "What are the key approaches to agent verification?"
/wiki:query "How does Karpathy's wiki pattern compare to RAG?"
/wiki:query "Who is working on browser automation for LLM agents?"
```

What it does:

1. **Search** — reads the index, greps for relevant terms, follows wikilinks from matching pages
2. **Deep read** — reads the most relevant pages fully (up to 10 pages)
3. **Synthesize** — composes an answer that cites wiki pages with `[[wikilinks]]`, synthesizes across multiple sources, and acknowledges gaps
4. **Optionally create synthesis page** — if the answer reveals novel connections not captured in any existing page, offers to create a new synthesis page

### `/wiki:lint`

Health-check the wiki for structural issues, missing connections, and content problems.

```bash
/wiki:lint          # report issues
/wiki:lint --fix    # auto-fix structural issues
```

| Check | Severity | Auto-fixable |
|-------|----------|-------------|
| Dead links (wikilinks to non-existent pages) | Critical | Yes (creates stubs) |
| Missing frontmatter (required YAML fields) | Critical | Yes (infers from directory) |
| Orphan pages (no inbound links) | Warning | Yes (links from related pages) |
| Missing concepts (terms in 3+ pages without a page) | Warning | No |
| Index gaps (pages not in index) | Warning | Yes |
| Tag inconsistencies (type vs. tag mismatch) | Warning | Yes |
| Stale pages (not updated in 90+ days) | Suggestion | No |
| Empty sections (headers with no content) | Suggestion | No |
| Contradictions (conflicting claims across pages) | Warning | No |
| Missing cross-references (related pages not linked) | Suggestion | No |

## Page Conventions

All pages use YAML frontmatter and `[[wikilinks]]`:

```yaml
---
type: entity | concept | source | synthesis
created: 2026-04-15
updated: 2026-04-15
sources: ["[[sources/article-name]]"]
tags:
  - wiki/<type>
  - <domain-tag>
---
```

### Page Types

**Entity pages** (`entities/`) — People, organizations, products. Key facts, roles, timeline, relationships. Link to concepts they're associated with and sources that mention them.

**Concept pages** (`concepts/`) — Ideas, frameworks, patterns, technologies. Definition, explanation, examples, related concepts. The backbone of the knowledge graph.

**Source pages** (`sources/`) — Summaries of ingested raw documents. 3-5 key takeaways, a summary, notable quotes, and links to entities/concepts discussed.

**Synthesis pages** (`synthesis/`) — The most valuable pages. Cross-cutting analysis connecting multiple sources. Comparisons, trend analysis, evolved understanding. Created when ingest or query reveals novel connections.

### Key Files

- **`wiki/index.md`** — Content catalog. Every page listed with a wikilink and one-line summary. Dataview queries for dynamic views. Updated on every ingest. Works well up to a few hundred pages; beyond that, consider adding [QMD](https://github.com/tobiasbueschel/qmd) for hybrid BM25/vector search.
- **`wiki/log.md`** — Append-only changelog. Records every ingest, query, lint, and synthesis operation with timestamps and page lists.
- **`CLAUDE.md`** — The schema. Defines all conventions, page formats, operation workflows. Customizable per vault. Read by the LLM at the start of every operation.

## Things You Can Do

### Automate maintenance with Claude Code Routines

[Claude Code Routines](https://code.claude.com/docs/en/routines) are scheduled tasks that run on Anthropic's cloud. You can set up a routine that maintains your wiki automatically — lint, organize new sources, update stale pages — on a daily or weekly schedule, even with your laptop closed.

**Daily wiki maintenance routine:**

Use `/schedule` in Claude Code to create a routine:

```
/schedule create daily-wiki-maintenance
```

Set the prompt to:

```
Run wiki maintenance on my knowledge base at /path/to/vault:

1. Check for new files in raw/ that haven't been ingested
2. For each new file, run the wiki:ingest workflow
3. Run wiki:lint --fix to repair structural issues
4. Check for stale pages (not updated in 90+ days) and flag them in the log
5. Update the index with any new pages
```

Schedule it to run nightly or weekly. The routine runs on Anthropic's cloud, so it works while you sleep.

### In-session automation with /loop

For maintenance during an active session, use `/loop`:

```bash
# Lint every 30 minutes while you work
/loop 30m /wiki:lint

# Ingest any new files dropped in raw/ every hour
/loop 1h check raw/ for new files and run /wiki:ingest on each
```

### Desktop scheduled tasks

For local automation that needs access to your files but should survive session restarts:

```bash
# Desktop task that runs daily at 9am
/schedule create --desktop --cron "0 9 * * *" daily-wiki-lint
```

### Drop files in raw/ then ingest

Save articles and papers to `raw/articles/` or `raw/papers/` (via Obsidian Web Clipper, manual download, or any tool), then ingest each one:

```bash
/wiki:ingest raw/articles/article-name.md
```

### Build a domain-specific knowledge graph

The wiki works for any domain, not just testing knowledge:

```bash
# Research domain
/wiki:ingest paper-on-transformers.pdf
/wiki:ingest paper-on-attention.pdf
/wiki:query "How has attention mechanism evolved across these papers?"

# Product domain
/wiki:ingest competitor-analysis.md
/wiki:ingest user-interview-notes.md
/wiki:query "What features do users want that competitors don't offer?"

# Incident response
/wiki:ingest postmortem-2026-04-10.md
/wiki:ingest runbook-database-failover.md
/wiki:query "What patterns repeat across our incidents?"
```

### Generate reports from wiki knowledge

Ask the wiki to compile what it knows into a structured report:

```bash
/wiki:query "Compile a summary of everything we know about authentication patterns across all projects. Format as a report with sections."
```

The synthesis pages that result from these queries are the wiki's most valuable output — they represent accumulated understanding that no single source contains.

## Scaling

The wiki pattern works differently at different sizes:

| Pages | Index Strategy | Search | Maintenance |
|-------|---------------|--------|-------------|
| < 100 | `index.md` is enough | Grep + follow links | Manual `/wiki:lint` |
| 100-500 | Categorized index with sections | Grep + Dataview queries | Weekly `/wiki:lint --fix` |
| 500+ | Add [QMD](https://github.com/tobiasbueschel/qmd) for hybrid search | BM25 + vector + graph traversal | Automated routine |

As recommended by Karpathy: QMD (by Tobi Lutke) provides hybrid BM25/vector search with LLM re-ranking, all on-device. It's available as both a CLI and an MCP server, making it a natural complement to this plugin for larger wikis.

### Compaction

Append-only wikis eventually grow unwieldy. Periodically:
- Archive stale source pages that have been fully synthesized
- Merge overlapping concept pages
- Consolidate synthesis pages that cover the same ground
- Keep `log.md` manageable (archive entries older than 90 days)

A weekly `/wiki:lint` catches most structural issues. For deeper maintenance, review the lint report's "Stale pages" and "Contradictions" sections manually.

## Typical Workflows

### Building a knowledge base on a topic

```bash
/wiki:init                            # set up vault

# Ingest sources one at a time
/wiki:ingest raw/articles/article-1.md
/wiki:ingest https://example.com/paper
/wiki:ingest raw/articles/article-2.md

# Ask questions to synthesize understanding
/wiki:query "What are the key themes across these sources?"

# Periodically maintain
/wiki:lint --fix
```

### Research project

```bash
# Ingest papers as you read them
/wiki:ingest raw/papers/paper-1.md
/wiki:ingest raw/papers/paper-2.md
/wiki:ingest raw/papers/paper-3.md

# Ask analytical questions
/wiki:query "Where do these papers agree and disagree?"
/wiki:query "What gaps exist in the current research?"

# The synthesis pages capture accumulated insight
```

### Team knowledge base

Point the vault at a shared Obsidian vault (synced via git or Obsidian Sync). Multiple agents and humans can contribute:

```bash
# Agent ingests meeting notes
/wiki:ingest raw/articles/meeting-notes-2026-04-15.md

# Human clips an article via Obsidian Web Clipper → raw/articles/
# Agent ingests it next session
/wiki:ingest raw/articles/new-paper.md

# Anyone can query
/wiki:query "What decisions were made about the API redesign?"
```

## Obsidian Setup

For the best experience with the wiki vault:

- **[Dataview](https://github.com/blacksmithgu/obsidian-dataview)** — Required for dynamic queries in index pages. The index uses Dataview tables to show all pages sorted by date and type.
- **Graph View** (built-in) — Visualize the knowledge graph. Entities, concepts, and sources appear as nodes; wikilinks appear as edges.
- **[Obsidian Web Clipper](https://obsidian.md/clipper)** — Browser extension for converting web articles to markdown. Saves to `raw/articles/` for ingestion.
- **[QMD](https://github.com/tobiasbueschel/qmd)** — Local hybrid search engine (BM25 + vector + LLM re-ranking). Recommended for wikis with 100+ pages. Available as CLI and MCP server.
- **[Marp](https://marp.app/)** — Optional. Generate presentations from wiki pages.

## Docs

- [Multiple wikis](docs/multiple-wikis.md) — configuring multiple named vaults, the `WIKI` env var, and typical workflows

## Configuration

Config file: `~/.wiki/config.json`

**Single wiki** (simple setup):
```json
{
  "base_dir": "/path/to/your/obsidian-vault"
}
```

**Multiple wikis** (separate knowledge bases for different purposes):
```json
{
  "wikis": {
    "personal": "/path/to/personal-vault",
    "testing": "/path/to/testing-vault",
    "research": "/path/to/research-vault"
  },
  "default": "personal"
}
```

Use `--wiki <name>` on any command to target a specific wiki:

```bash
/wiki:init testing                                  # create a new wiki called "testing"
/wiki:ingest --wiki testing path/to/runbook.md      # ingest into the testing wiki
/wiki:query --wiki research "What do the papers say about X?"
/wiki:lint --wiki personal --fix
```

When you omit `--wiki`, the default wiki is used. Set `WIKI=<name>` or `WIKI=<path>` as an env var to override for a session. See [Multiple wikis](docs/multiple-wikis.md) for full examples.

### Example: personal wiki + research wiki

```bash
# Set up a personal knowledge base
/wiki:init personal

# Set up a research wiki
/wiki:init research

# Personal research goes to personal wiki
/wiki:ingest --wiki personal https://interesting-article.com

# Research papers go to research wiki
/wiki:ingest --wiki research path/to/paper.pdf

# Or set WIKI for a focused session on one wiki
export WIKI=research
/wiki:ingest path/to/runbook.md
/wiki:ingest path/to/notes.md
/wiki:lint --fix
```

## Installation

```
/plugin install wiki@nelsonochoam
```

## How This Follows Karpathy's Pattern

This plugin implements [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) faithfully:

| Karpathy's Pattern | This Plugin |
|---|---|
| Three layers: raw, wiki, schema | `raw/`, `wiki/`, `CLAUDE.md` |
| Ingest: read source, create/update pages, cross-link | `/wiki:ingest` — touches 10-15 pages per source |
| Query: search wiki, synthesize with citations | `/wiki:query` — answers with `[[wikilink]]` citations |
| Lint: find contradictions, orphans, stale pages | `/wiki:lint` — 10 checks, auto-fix for structural issues |
| Index as content catalog | `wiki/index.md` with Dataview queries |
| Log as append-only changelog | `wiki/log.md` with timestamped entries |
| Obsidian for graph visualization | All output is Obsidian-compatible (frontmatter, wikilinks, tags) |
| "A note without links is a bug" | `/wiki:lint` enforces outbound links and flags orphans |
| Schema drives conventions | `CLAUDE.md` defines page formats, operations, linting rules |
| QMD for search at scale | Recommended in docs for 100+ page wikis |

Extensions beyond the original gist (informed by [LLM Wiki v2](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2)):
- **Automated maintenance via Routines** — daily/weekly lint, ingest, and compaction on a schedule
- **Multiple named wikis** — separate knowledge bases with `--wiki` targeting and `WIKI` env var

## References

- **[Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** by Andrej Karpathy — The foundational architecture. Three layers, ingest/query/lint, and the insight that LLMs should compile knowledge rather than re-derive it.
- **[LLM Wiki v2](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2)** by Rohit Gupta — Extensions to Karpathy's pattern: confidence scoring, typed relationships, consolidation tiers, event-driven automation, and quality control systems.
- **[Claude Code Routines](https://code.claude.com/docs/en/routines)** — Scheduled tasks on Anthropic's cloud for automating wiki maintenance (lint, ingest, compaction) on a daily or weekly schedule.
- **[Claude Code Scheduled Tasks](https://code.claude.com/docs/en/scheduled-tasks)** — In-session `/loop` and cron scheduling for polling and periodic maintenance during active sessions.
- **[QMD](https://github.com/tobiasbueschel/qmd)** by Tobi Lutke — Local hybrid search engine (BM25 + vector + LLM re-ranking) recommended by Karpathy for wikis beyond ~100 pages.
- **[obsidian-mind](https://github.com/breferrari/obsidian-mind)** by breferrari — An Obsidian vault giving AI agents persistent memory. Its lifecycle hooks and "folders group by purpose, links group by meaning" philosophy informed our vault structure.
- **[claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian)** by AgriciDaniel — A Claude + Obsidian knowledge companion implementing Karpathy's pattern with autonomous note organization.
- **[obsidian-wiki](https://github.com/Ar9av/obsidian-wiki)** by Ar9av — A framework for AI agents to build and maintain an Obsidian wiki using Karpathy's pattern.
- **[obsidian-llm-wiki-local](https://github.com/kytmanov/obsidian-llm-wiki-local)** by kytmanov — Karpathy's LLM Wiki running 100% locally with Ollama. Demonstrates the pattern works without cloud APIs.
- **[Self-Evolving Claude Code Memory with Obsidian Hooks](https://www.mindstudio.ai/blog/self-evolving-claude-code-memory-obsidian-hooks)** by MindStudio — The Stop hook + memory extraction pattern for automatic knowledge capture at session end.
- **[Building an AI Second Brain with Claude Code and Obsidian](https://www.mindstudio.ai/blog/build-ai-second-brain-claude-code-obsidian)** by MindStudio — The concept of an "active" knowledge base with an agent layer.
- **[Claude Code Memory Setup with Obsidian + Graphify](https://github.com/lucasrosati/claude-code-memory-setup)** by Lucas Rosati — Token-efficient memory using knowledge graphs, achieving up to 71.5x fewer tokens per session.
