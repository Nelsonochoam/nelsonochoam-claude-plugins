---
name: context
description: Create or update the testing playbook for the current repo — describes how to run, test, and verify the application.
argument-hint: '<optional: --update to refresh an existing context>'
model: opus
---

User's request: $ARGUMENTS

# Create Testing Context

You are building a testing playbook for this repository. This document tells agents (and humans) everything they need to know to test and verify changes to this application.

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved base directory as `$DEMO_BASE`.

## Check for Existing Context

```bash
cat "$BASE_DIR/testing-context.md" 2>/dev/null || echo "NOT_FOUND"
```

**If exists and `--update` was NOT passed:** Read the existing context, then use `AskUserQuestion` to ask:

> A testing context already exists for this repo. What would you like to do?

Options: `Update it with new information` / `Rewrite from scratch` / `Cancel`

**If NOT found (or rewriting):** proceed to exploration.

## Consult Existing Knowledge

Before exploring the repo from scratch, check what we already know from prior testing sessions and the wiki.

### Read Learnings History

```bash
cat "$DEMO_BASE/learnings/index.md" 2>/dev/null || echo "NO_LEARNINGS"
```

If learnings exist, read the most recent files. Extract knowledge that should go into the testing context:
- Environment setup corrections (ports, env vars, prerequisites)
- Auth flows and credentials
- Known timing issues (startup delays, async operations)
- Correct routes and URL patterns (overriding what code inspection might suggest)
- Verification patterns that worked in practice

### Query Knowledge Index (optional)

```bash
KNOWLEDGE_INDEX=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/resolve-knowledge-index.sh" 2>/dev/null) || true
echo "${KNOWLEDGE_INDEX:-NO_KNOWLEDGE_INDEX}"
```

**If NO_KNOWLEDGE_INDEX** — skip this section. The knowledge index is optional. Showboat works fine with just code inspection and learnings.

**If a knowledge index exists**, read it and follow links progressively to find testing-relevant knowledge:
- Known testing patterns for this app type
- Environment and infrastructure knowledge
- Authentication and authorization flows
- Common pitfalls and workarounds

Only read linked pages that seem relevant to this repo's app type — don't load the entire knowledge base.

This accumulated knowledge should inform the testing context you write — don't rely only on code inspection when prior sessions have already discovered what actually works.

### Use Inline Details from User

If `$ARGUMENTS` contains testing details (e.g., `/showboat:context "app runs on port 8080, uses JWT auth, needs redis"`), incorporate those details directly into the testing context. Inline details take priority over code-inferred values.

## Explore the Repository

Investigate the codebase to understand what this application is and how it works. Use sub-agents for parallel exploration if the repo is large. Focus on:

### 1. Application Type

Determine the `app_type` — read `${CLAUDE_SKILL_DIR}/references/app-type-patterns.md` for guidance.

Look at:
- `package.json` scripts, dependencies, and framework indicators
- `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`, or equivalent
- Entry points (`src/index.ts`, `main.go`, `app.py`, etc.)
- Presence of `public/`, `pages/`, `app/` directories (web frameworks)
- Presence of CLI entry points, `bin/` directories
- Docker/docker-compose files

### 2. Dev Server & Build

Find how to:
- Install dependencies
- Start the dev server (and what port it runs on)
- What the "ready signal" looks like in stdout (e.g., `Local: http://localhost:3000`)
- Build for production
- Run database migrations or seed data

### 3. Test Suites

Find all test commands:
- Unit tests
- Integration tests
- End-to-end tests
- Linting and type checking

### 4. Routes & Pages (for web apps)

Scan route definitions, page components, or API endpoint files:
- Next.js: `app/` or `pages/` directory
- Express/Fastify: route files
- Django/Flask: URL configs
- Static sites: file structure

### 5. API Endpoints (for APIs)

Find endpoint definitions and example payloads. Look for:
- OpenAPI/Swagger specs
- Route handler files
- GraphQL schemas

### 6. CLI Commands (for CLI tools/libraries)

Find command definitions, help text, and example usage.

## Ask Clarifying Questions

Use `AskUserQuestion` for anything you cannot determine from the code:

- Is there a specific URL or port the app runs on?
- Are there test credentials or seed data?
- Are there any pages or features that require special setup?
- Is there a staging/preview environment?

Keep questions focused. Do not ask about things you already found in the code.

## Write the Testing Context

Read the template at `${CLAUDE_SKILL_DIR}/references/context-template.md` and fill it in with everything you discovered.

Write the file to `$BASE_DIR/testing-context.md`.

**Important conventions:**
- Use Obsidian YAML frontmatter with `app_name`, `app_type`, `repo`, `created`, `updated` fields
- Use `tags: [showboat/context]`
- Use code blocks for all commands — agents will execute these literally
- Include the "ready signal" for dev servers — agents need to know when to proceed
- For each page/endpoint, include concrete verification criteria (what to check, not just what exists)
- Leave the "Feature-Specific Testing" section empty — it grows as demos are created

## If Updating

When `--update` was passed or the user chose to update:
1. Read the existing `testing-context.md`
2. Re-explore only what seems outdated or missing
3. Preserve existing Feature-Specific Testing entries (they were added by previous demos)
4. Update the `updated` date in frontmatter
5. Use `Edit` to modify in place — do not rewrite the entire file

## Done

After writing, say:

```
Testing context written to: $BASE_DIR/testing-context.md

Discovered:
  App type: <app_type>
  Dev server: <command> (port <port>)
  Test commands: <count> found
  Routes/pages: <count> found
  API endpoints: <count> found

Run /showboat:demo <feature-name> after implementing a feature to generate a demo with evidence.
```
