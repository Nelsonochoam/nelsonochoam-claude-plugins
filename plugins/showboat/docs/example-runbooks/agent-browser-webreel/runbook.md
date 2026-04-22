# Example Runbook — agent-browser + webreel

Navigation index for LLMs testing this app. Load only the sub-docs you need — do not read them all upfront.

## Quick constants

- Base URL: `http://localhost:3000`
- Dev server: `npm run dev`

## Task → Reference map

| Task | Load |
|---|---|
| Starting the app, login, env vars | [`references/environment.md`](references/environment.md) |
| Running tests, type-checks, builds | [`references/testing.md`](references/testing.md) |
| Taking screenshots or interacting with the browser (agent-browser) | [`references/browser-tool.md`](references/browser-tool.md) |
| Recording a polished video of the demo flow (webreel) | [`references/browser-tool.md`](references/browser-tool.md#webreel--polished-video-recording) |
| Navigating a specific route or page | [`references/pages.md`](references/pages.md) |
| Hitting API endpoints | [`references/api.md`](references/api.md) |

## When you hit something new

Capture gotchas in the relevant `references/*.md` file (not here). Keep this index slim — it is always loaded; sub-docs are loaded on demand.
