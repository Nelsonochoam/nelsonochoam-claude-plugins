# Example Runbook — Playwright

Navigation index for LLMs testing this app. Load only the sub-docs you need — do not read them all upfront.

## Quick constants

- Base URL: `http://localhost:3000`
- Dev server: `npm run dev`

## Task → Reference map

| Task | Load |
|---|---|
| Starting the app, login, env vars | [`references/environment.md`](references/environment.md) |
| Running tests, type-checks, builds | [`references/testing.md`](references/testing.md) |
| One-shot screenshot of a public URL (no auth needed) | [`references/browser-tool.md`](references/browser-tool.md#quick-screenshots-no-interaction-needed) |
| Interactive session: auth, click, fill, screenshot, video (`playwright-cli`) | [`references/browser-tool.md`](references/browser-tool.md#full-sessions-interaction--screenshots--video-playwright-cli) |
| Navigating a specific route or page | [`references/pages.md`](references/pages.md) |
| Hitting API endpoints | [`references/api.md`](references/api.md) |

## When you hit something new

Capture gotchas in the relevant `references/*.md` file (not here). Keep this index slim — it is always loaded; sub-docs are loaded on demand.
