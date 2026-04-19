# Self-Discovery: Testing Without a Runbook

When no runbook is configured, gather testing information by reading the codebase directly. The goal is to answer: how do I run this app, how do I test it, and what should I exercise?

Use the git diff as the north star — it tells you exactly what changed and therefore what to test. Everything else (how to start the server, what endpoints exist) is in service of demonstrating those specific changes.

## 1. Understand What Changed

Start here before exploring the codebase:

```bash
git diff --stat HEAD~1
git log --oneline -5
```

Read the diff of the changed files themselves — not just the stat. This tells you:
- What kind of change it is (UI, API, business logic, config)
- Which routes, components, or endpoints were modified
- What the expected new behavior should be

## 2. Discover How to Run the App

Look for the dev server command and port:

```bash
cat package.json 2>/dev/null | jq '{scripts, main}'
cat Makefile 2>/dev/null | head -40
cat README.md 2>/dev/null | head -80
cat CONTRIBUTING.md 2>/dev/null | head -60
```

Common patterns by stack:
- **Node/TS**: `npm run dev`, `yarn dev`, `pnpm dev` → port usually in the script or `.env`
- **Next.js**: `next dev` → default port 3000
- **Rails**: `rails server` → default port 3000
- **Django/Flask**: `python manage.py runserver` / `flask run` → default 8000 / 5000
- **Go**: look for `main.go`, usually `go run .`
- **Rust**: `cargo run`

Find the port:

```bash
cat .env.example 2>/dev/null
cat .env 2>/dev/null
# Look for PORT=, port:, listen( patterns in the entry point
grep -r "listen\|PORT\|port" --include="*.ts" --include="*.js" --include="*.go" --include="*.py" -l | head -5
```

## 3. Discover Test Commands

```bash
# Node projects
cat package.json 2>/dev/null | jq '.scripts | to_entries[] | select(.key | test("test|lint|typecheck|check"))'

# Other stacks
ls Makefile pytest.ini jest.config.* vitest.config.* .github/workflows/ 2>/dev/null
```

Run only the tests related to changed files — don't run the full suite blindly if it's slow. If the diff touched `src/auth/`, look for `test/auth/` or `*.test.ts` near the changed files.

## 4. Discover Routes and Pages

For the specific routes/pages touched by the diff:

```bash
# Next.js / Remix / file-based routing
find . -path "*/pages/*.tsx" -o -path "*/app/*/page.tsx" 2>/dev/null | head -20

# Express / Fastify / Hono
grep -r "router\.\|app\.get\|app\.post\|\.route(" --include="*.ts" --include="*.js" -l | head -10

# Rails
cat config/routes.rb 2>/dev/null | head -50

# Django
grep -r "path\|re_path" --include="urls.py" -r . | head -20
```

Focus on routes touched by the diff. Don't enumerate all routes.

## 5. Discover API Endpoints

```bash
# OpenAPI / Swagger
find . -name "openapi.yaml" -o -name "swagger.json" -o -name "*.openapi.*" 2>/dev/null | head -3

# Look at what the diff changed directly
git diff HEAD~1 -- "*.ts" "*.js" "*.py" "*.go" "*.rb" | grep -E "^+.*(GET|POST|PUT|PATCH|DELETE|router\.|@app\.)" | head -20
```

## 6. Discover Auth Requirements

```bash
# Look for auth middleware or guards in changed files
git diff HEAD~1 | grep -E "auth|guard|middleware|token|session|jwt" -i | head -10

# Look for login routes
grep -r "login\|signin\|auth" --include="*.ts" --include="*.js" -l | head -5
```

## 7. Infer App Type

Use these signals to decide how to test:

| Signal | App type | Testing approach |
|--------|----------|-----------------|
| `pages/` or `app/` dir with JSX | web-app | rodney for UI, screenshots |
| Route files returning JSON only | api | curl for endpoints |
| `bin/` or CLI framework | cli | exec commands, capture stdout |
| Library exports, no entry point | library | run test suite |
| Both frontend + API routes | hybrid | rodney + curl |

See `${CLAUDE_PLUGIN_ROOT}/references/app-type-patterns.md` for detailed detection patterns.

## 8. When You're Uncertain

Make one reasonable attempt before asking the user:

- Try the most common dev server command for the detected stack
- Try the most common test command
- Hit the most likely endpoint (`/api/health`, `/health`, `/`)

If a command fails, use `showboat pop "$DEMO_FILE"` to remove it and try the next most likely option. Only use `AskUserQuestion` if two attempts fail or if you can't determine the app type at all.

## What to Produce

By the end of self-discovery, you should have the same information you'd get from a runbook:
- Dev server command and URL
- 1-2 test commands to run
- The specific routes or endpoints affected by the diff
- Whether auth is required and roughly how it works

If you discover something broadly useful (the port, the auth flow, the test command), note it at the end of the demo:

> No runbook configured — I inferred the following. Run `/showboat:init --reset` and choose "Auto-generate" to capture this permanently.
