# App Type Detection Patterns

Use these patterns to determine the `app_type` for the testing context.

## web-app

**Indicators:**
- Frontend framework present: React, Vue, Svelte, Angular, Next.js, Nuxt, SvelteKit, Remix, Astro
- `pages/` or `app/` directory with route components
- `public/` or `static/` directory with assets
- CSS/Tailwind/styled-components in dependencies
- Dev server serves HTML at a port

**Testing focus:** Pages & Routes, screenshots, UI verification, test suites
**Skip:** CLI Commands

## api

**Indicators:**
- Backend framework present: Express, Fastify, Hono, Django REST, Flask, FastAPI, Gin, Echo
- Route handler files without corresponding frontend
- No `pages/`, `app/`, or frontend components
- OpenAPI/Swagger spec
- Only JSON/data responses

**Testing focus:** API Endpoints, HTTP verification, test suites
**Skip:** Pages & Routes (unless there's a docs/swagger UI), screenshots

## cli

**Indicators:**
- `bin/` directory with entry points
- CLI framework: Commander, yargs, clap, cobra, click, argparse
- `package.json` with `bin` field
- No web server, no routes, no frontend

**Testing focus:** CLI Commands, stdout/stderr capture, exit codes, test suites
**Skip:** Pages & Routes, API Endpoints, screenshots

## library

**Indicators:**
- Published package (npm, PyPI, crates.io, etc.)
- `src/lib.rs`, `src/index.ts` exporting functions/classes
- No entry point, no server, no CLI
- Extensive test suite

**Testing focus:** Test suites (unit + integration), API documentation, code coverage
**Skip:** Pages & Routes, API Endpoints, CLI Commands, screenshots

## hybrid

**Indicators:**
- Monorepo with multiple app types (`packages/api`, `packages/web`, `apps/cli`)
- Full-stack framework (Next.js with API routes, Django with templates)
- Both frontend and backend in one repo

**Testing focus:** All sections relevant to the sub-applications present
**Skip:** Nothing — include all applicable sections, organized by sub-application
