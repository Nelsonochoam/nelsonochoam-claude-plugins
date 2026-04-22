# Example Runbook — agent-browser

Navigation index for LLMs testing this app. Load only the sub-docs you need — do not read them all upfront.

## Quick constants

- Base URL: `http://localhost:8080`
- Dev server: `npm run dev`

## Task → Reference map

| Task                                                            | Load                                                       |
| --------------------------------------------------------------- | ---------------------------------------------------------- |
| Starting the app, login, env vars                               | [`references/environment.md`](references/environment.md)   |
| Running tests, type-checks, builds                              | [`references/testing.md`](references/testing.md)           |
| Taking screenshots, recording video (WebM), browser interaction | [`references/browser-tool.md`](references/browser-tool.md) |
| Navigating a specific route or page                             | [`references/pages.md`](references/pages.md)               |
| Hitting API endpoints                                           | [`references/api.md`](references/api.md)                   |

## When you hit something new

Capture gotchas in the relevant `references/*.md` file (not here). Keep this index slim — it is always loaded; sub-docs are loaded on demand.
