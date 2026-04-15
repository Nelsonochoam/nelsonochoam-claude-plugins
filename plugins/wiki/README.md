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

The core operation. Reads a source, extracts knowledge, and compiles it into wiki pages. A single source typically touches 10-15 pages.

```bash
# Ingest a local file
/wiki:ingest path/to/article.md

# Ingest a URL
/wiki:ingest https://simonwillison.net/2026/Feb/10/showboat-and-rodney/

# Ingest inline text/topic
/wiki:ingest "The key differences between transformers and RNNs are..."

# Ingest showboat learnings (auto-detected, creates testing pattern concept pages)
/wiki:ingest path/to/learnings/2026-04-20-introspect.md
```

What happens during ingest:

1. **Read the source** — parse the document, extract key entities, concepts, and takeaways
2. **Save raw source** — copy to `raw/articles/` or `raw/papers/` (immutable archive)
3. **Create source summary** — write `wiki/sources/<name>.md` with key takeaways, summary, notable quotes
4. **Create/update entity pages** — for each significant person, organization, or product mentioned, create or update `wiki/entities/<name>.md`
5. **Create/update concept pages** — for each key idea, framework, or technology discussed, create or update `wiki/concepts/<name>.md`
6. **Cross-link** — add `[[wikilinks]]` between all related pages, and update existing pages that should link to new content
7. **Check for synthesis** — if the source connects to existing knowledge in novel ways, create a `wiki/synthesis/<name>.md` page
8. **Update index** — add all new pages to `wiki/index.md`
9. **Log the operation** — append to `wiki/log.md`

When the source is a **showboat learnings file** (auto-detected by `type: learnings` in frontmatter), the ingest follows a specialized path: it parses the structured learnings, creates testing pattern concept pages (e.g., `wiki/concepts/auth-testing-patterns.md`), and creates repo-specific knowledge pages.

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

**Showboat learnings sync routine:**

If you use the showboat plugin, learnings accumulate in `<showboat-base>/*/learnings/`. Set up a routine to ingest them:

```
/schedule create weekly-learnings-sync
```

```
Find all showboat learnings files that haven't been ingested into the wiki yet:

1. Scan <showboat-base>/*/learnings/*.md for files not in wiki/sources/
2. For each new learnings file, run wiki:ingest
3. After ingesting, run wiki:lint to check for new orphans or missing links
4. Log what was synced
```

Schedule weekly. This is the automated version of the showboat-to-wiki feedback loop.

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

### Drop files in raw/ for batch ingest

The simplest workflow: save articles and papers to `raw/articles/` or `raw/papers/` (via Obsidian Web Clipper, manual download, or any tool). Then periodically run `/wiki:ingest` on each, or let a routine handle it.

```bash
# Ingest everything new in raw/articles
for f in raw/articles/*.md; do /wiki:ingest "$f"; done
```

### Use the wiki as showboat's knowledge index

Point showboat's `knowledge_index` at your wiki's `index.md`:

```json
{
  "base_dir": "/path/to/showboat",
  "knowledge_index": "/path/to/vault/wiki/index.md"
}
```

Now showboat progressively reads from your wiki when it needs testing context. As the wiki grows with ingested learnings, showboat gets smarter about how to test things — without you doing anything.

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
/wiki:ingest https://article-1.com
/wiki:ingest path/to/paper.pdf
/wiki:ingest https://article-2.com

# Ask questions to synthesize understanding
/wiki:query "What are the key themes across these sources?"

# Periodically maintain
/wiki:lint --fix
```

### Research project

```bash
# Ingest all your research materials
/wiki:ingest paper-1.md
/wiki:ingest paper-2.md
/wiki:ingest paper-3.md

# Ask analytical questions
/wiki:query "Where do these papers agree and disagree?"
/wiki:query "What gaps exist in the current research?"

# The synthesis pages capture accumulated insight
```

### Team knowledge base

Point the vault at a shared Obsidian vault (synced via git or Obsidian Sync). Multiple agents and humans can contribute:

```bash
# Agent ingests meeting notes
/wiki:ingest meeting-notes-2026-04-15.md

# Human adds a research paper via Obsidian Web Clipper
# Agent ingests it on next session
/wiki:ingest raw/articles/new-paper.md

# Anyone can query
/wiki:query "What decisions were made about the API redesign?"
```

### Showboat feedback loop

The wiki pairs with the showboat plugin to build testing knowledge that compounds:

```bash
# Agent tests a feature, makes mistakes, user corrects
/showboat:demo my-feature
/showboat:introspect my-feature     # writes learnings file

# Wiki ingests the learnings, creates concept pages
/wiki:ingest path/to/learnings/2026-04-20-introspect.md

# Showboat points knowledge_index at wiki/index.md
# Next test session benefits from accumulated knowledge
```

Set up a routine to automate the ingest step, and the loop runs itself.

## Obsidian Setup

For the best experience with the wiki vault:

- **[Dataview](https://github.com/blacksmithgu/obsidian-dataview)** — Required for dynamic queries in index pages. The index uses Dataview tables to show all pages sorted by date and type.
- **Graph View** (built-in) — Visualize the knowledge graph. Entities, concepts, and sources appear as nodes; wikilinks appear as edges.
- **[Obsidian Web Clipper](https://obsidian.md/clipper)** — Browser extension for converting web articles to markdown. Saves to `raw/articles/` for ingestion.
- **[QMD](https://github.com/tobiasbueschel/qmd)** — Local hybrid search engine (BM25 + vector + LLM re-ranking). Recommended for wikis with 100+ pages. Available as CLI and MCP server.
- **[Marp](https://marp.app/)** — Optional. Generate presentations from wiki pages.

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

When you omit `--wiki`, the default wiki is used. You can also set `WIKI_VAULT` as an env var to override for a session.

### Example: personal wiki + testing wiki

```bash
# Set up a personal knowledge base
/wiki:init personal

# Set up a testing knowledge wiki for showboat
/wiki:init testing

# Point showboat at the testing wiki
# In ~/.showboat/config.json: "knowledge_index": "/path/to/testing-vault/wiki/index.md"

# Personal research goes to personal wiki
/wiki:ingest --wiki personal https://interesting-article.com

# Testing learnings go to testing wiki
/wiki:ingest --wiki testing path/to/showboat/learnings/2026-04-20-introspect.md
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
- **Showboat learnings integration** — structured testing knowledge auto-compiles into concept pages
- **Automated maintenance via Routines** — daily/weekly lint, ingest, and compaction on a schedule
- **Progressive loading** — showboat reads the index and follows only relevant links, not the whole wiki

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
