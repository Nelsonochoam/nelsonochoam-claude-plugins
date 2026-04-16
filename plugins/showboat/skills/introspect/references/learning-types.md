# Learning Types

Classification taxonomy for introspection learnings. Each learning gets exactly one primary category.

## navigation

Route and URL corrections.

**Examples:**
- "The settings page is at /settings/profile not /settings"
- "The API base path changed from /api/v1 to /api/v2"
- "The admin dashboard is a separate app at port 3001"
- "Query parameters use `q` not `search`"

**Impact:** Update Pages & Routes or API Endpoints in testing context.

## auth

Authentication and authorization requirements.

**Examples:**
- "All /admin/* routes require admin login"
- "The API requires a Bearer token in the Authorization header"
- "Use test@example.com / password123 for test credentials"
- "The session cookie expires after 30 minutes — re-login between demos"
- "OAuth flow requires clicking the Google button, can't just POST to /auth"

**Impact:** Add auth prerequisites to affected pages/endpoints in testing context.

## timing

Wait conditions, startup delays, and async operations.

**Examples:**
- "The dev server takes 15 seconds to start, not 5"
- "After POST /api/reindex, wait for the task queue to finish (poll GET /api/reindex/status)"
- "The search index updates asynchronously — wait 2 seconds after inserting data before searching"
- "The ready signal is 'Listening on' not 'Local:'"
- "Hot reload takes 3 seconds — screenshot immediately after change misses the update"

**Impact:** Update ready signals, add wait conditions to verification patterns.

## interaction

Browser automation specifics — selectors, click targets, form inputs.

**Examples:**
- "The submit button is `button[type=submit]` not `.submit-btn`"
- "The dropdown requires clicking to open, then selecting the option by text"
- "The modal appears after a 500ms animation — wait before screenshotting"
- "Use `rodney click '.nav-menu button'` then `rodney click '.dropdown-item:nth-child(2)'`"
- "The dark mode toggle is in a shadow DOM — use `rodney js` to access it"

**Impact:** Add interaction steps to page verification in testing context. Useful for Rodney command sequences.

## data

Test data, seed commands, fixtures, and expected values.

**Examples:**
- "Run `npm run db:seed` before testing — the app shows an empty state otherwise"
- "The search test needs at least 5 users in the database to paginate"
- "Use the fixture file at `tests/fixtures/users.json` for test data"
- "The API returns dates in ISO 8601 not Unix timestamps"
- "Expected response has `total_count` not `total`"

**Impact:** Update Database Setup and Common Verification Patterns in testing context.

## environment

Environment variables, ports, prerequisites, and system requirements.

**Examples:**
- "Set NEXT_PUBLIC_API_URL=http://localhost:8080 before starting the dev server"
- "Redis must be running on port 6379 for the cache to work"
- "The app requires Node 20+ — Node 18 causes a crypto error"
- "PORT=3001 because another service uses 3000"
- "Need to run `docker compose up -d postgres redis` first"

**Impact:** Update Prerequisites and Environment Variables in testing context.

## workflow

Ordering of operations, step dependencies, and multi-step procedures.

**Examples:**
- "Must run migrations before seeding: `npm run db:migrate && npm run db:seed`"
- "Start the API server before the frontend — the frontend health check hits the API"
- "Build first, then start: the dev server doesn't auto-build"
- "Clear the cache between test runs: `npm run cache:clear`"
- "The e2e tests must run sequentially, not in parallel"

**Impact:** Update Environment Setup ordering and add workflow notes to testing context.

## tooling

Which tools work, which don't, and workarounds.

**Examples:**
- "Chrome headless can't handle this page — use Rodney with `rodney js` to dismiss the cookie banner first"
- "shot-scraper doesn't wait for lazy-loaded images — use Rodney with a delay"
- "curl doesn't follow the OAuth redirect — use httpie or a browser-based approach"
- "The API returns gzipped responses — add `-H 'Accept-Encoding: identity'` to curl"
- "Playwright works better than Chrome headless for this SPA — it waits for network idle"

**Impact:** Update tool preferences, add workaround notes to testing context or capture strategies.

## Choosing a Category

When a learning could fit multiple categories, pick the one that determines the **fix**:

- "The admin page requires login" → **auth** (the fix is adding auth steps)
- "The admin page is at /admin/dashboard not /admin" → **navigation** (the fix is changing the route)
- "The admin page loads slowly so the screenshot is blank" → **timing** (the fix is adding a wait)
- "The admin page's save button has a new class name" → **interaction** (the fix is updating the selector)
