# Auto-Initializing the Runbook

When the user points `/showboat:init` at a runbook path that does not yet exist, this doc tells you how to generate the initial graph by exploring the current repo.

The shape is identical to what `/showboat:ingest` maintains: a slim main index at `$RUNBOOK`, plus focused sub-docs under `$RUNBOOK_DIR/references/`. Read `${CLAUDE_PLUGIN_ROOT}/references/runbook-structure.md` first — that is the contract.

The goal is a useful **starting point**, not completeness. Missing information is fine; ingest will fill gaps as testing sessions surface them. Do not invent content the repo does not reveal.

## 1. Classify the app

Read `${CLAUDE_PLUGIN_ROOT}/references/app-type-patterns.md` and decide the `app_type`: `web-app`, `api`, `cli`, `library`, or `hybrid`. That decision drives which sub-docs to generate.

| app_type | Generate these sub-docs |
|---|---|
| web-app | `environment.md`, `testing.md`, `pages.md` |
| api | `environment.md`, `testing.md`, `api.md` |
| cli | `environment.md`, `testing.md`, `cli.md` |
| library | `environment.md`, `testing.md` |
| hybrid | `environment.md`, `testing.md`, plus whichever of `pages.md` / `api.md` / `cli.md` apply |

Skip any sub-doc where there is nothing meaningful to write. An empty doc is worse than none.

## 2. Explore the repo

Parallelize with sub-agents for large repos. Focus on what each sub-doc needs:

### environment.md — how to run the app

Look for:
- Package manifests (`package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`)
- Entry points and dev-server scripts
- Dockerfile / `docker-compose.yml`
- `.env.example`, `.envrc`
- `README.md`, `CONTRIBUTING.md`

Extract:
- Install command
- Dev-server command **and the stdout string that means "ready"** (agents need this to know when to proceed)
- Port / base URL
- Required env vars (names only — never values)
- Auth / login steps if the app has them
- Service prerequisites (database, redis, etc.)

### testing.md — how to verify

From the same manifests and any CI configs:
- Unit, integration, and e2e test commands
- Type-check and lint commands
- Build command
- Any path conventions (e.g., "run the file closest to the change, not the full suite")

### pages.md — for web-app / hybrid

Scan route definitions:
- Next.js `app/` or `pages/`
- Remix, Nuxt, SvelteKit, Astro route conventions
- Express/Fastify/Hono route files
- Rails `config/routes.rb`, Django `urls.py`

For each significant page, capture route + one-line purpose + whether auth is required. Do not enumerate every file — pick the pages a tester is most likely to demo.

### api.md — for api / hybrid

Scan endpoint definitions and OpenAPI specs:
- Route handler files
- `openapi.yaml`, `swagger.json`
- GraphQL schemas

For each endpoint, capture method + path + one-line purpose. Include one real `curl` example per resource, not every verb.

### cli.md — for cli / hybrid

Find command definitions (Commander, yargs, clap, cobra, click, argparse, `bin/` entries). For each command, capture invocation + one-line purpose + a real example.

## 3. Use inline details from the user

If the user passed details with `/showboat:init` (ports, credentials, URLs), prefer those over what the code suggests. Codebase inference is a hint; user input is ground truth.

## 4. Ask only for what you cannot infer

Before writing, use `AskUserQuestion` only for gaps the code cannot answer: test credentials, staging URLs, pages that need special setup. Do not ask about anything you already found.

## 5. Write the graph

Create the main index at `$RUNBOOK` using the skeleton in `${CLAUDE_PLUGIN_ROOT}/references/runbook-structure.md`. Populate:

- **Quick constants**: base URL, primary dev-server command, any cwd rule.
- **Task → Reference map**: one row per sub-doc you are about to create.
- Leave the "When you hit something new" footer in place so future ingest runs know where to drop learnings.

Then write each sub-doc under `$RUNBOOK_DIR/references/`. Every sub-doc starts with a `Load when: ...` line on line 2. Keep each under ~80 lines.

## 6. Cross-link

Add the obvious edges now — they are cheap and help future agents navigate:
- `pages.md` or `api.md` sections that require auth → link to `environment.md#login` (or wherever login lives).
- `testing.md` commands that require services → link to `environment.md#prerequisites`.

Do not force links where there is no natural connection.

## 7. Report

Print to the user:

```
Initial runbook created at: <runbook-path>

  Main index:        <runbook-path>
  Sub-docs created:  references/environment.md, references/testing.md, ...
  App type:          <app_type>
  Dev server:        <command> (port <port>)

Future /showboat:introspect + /showboat:ingest runs will extend this graph with corrections from real testing sessions.
```
