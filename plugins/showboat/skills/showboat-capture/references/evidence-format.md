# Evidence Format (JSONL)

Evidence is stored as append-only JSONL at `<base_dir>/<repo>/evidence/<feature>.jsonl`. Each line is a self-contained JSON record representing one piece of evidence.

## Common Fields

Every evidence record has these fields:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique ID, format: `ev-<unix_timestamp>-<pid>` |
| `type` | string | Evidence type (see below) |
| `timestamp` | string | ISO 8601 UTC timestamp |
| `label` | string | Human-readable description of what this evidence proves |

## Evidence Types

### `command`

A shell command was executed and its output captured.

```json
{
  "id": "ev-1713168600-1234",
  "type": "command",
  "timestamp": "2026-04-15T10:30:00Z",
  "command": "npm test",
  "exit_code": 0,
  "stdout": "Tests: 42 passed, 0 failed\nTest Suites: 12 passed",
  "stderr": "",
  "duration_ms": 3200,
  "label": "Unit tests pass"
}
```

### `screenshot`

A browser screenshot was captured.

```json
{
  "id": "ev-1713168660-1234",
  "type": "screenshot",
  "timestamp": "2026-04-15T10:31:00Z",
  "url": "http://localhost:3000/users?q=test",
  "path": "evidence/assets/ev-1713168660-1234-screenshot.png",
  "label": "Search results for 'test'",
  "dimensions": "1280x720"
}
```

### `http`

An HTTP request was made and the response captured.

```json
{
  "id": "ev-1713168720-1234",
  "type": "http",
  "timestamp": "2026-04-15T10:32:00Z",
  "method": "GET",
  "url": "http://localhost:3000/api/users?search=test",
  "status": 200,
  "body": "{\"users\":[{\"id\":1,\"name\":\"Test User\"}],\"total\":1}",
  "duration_ms": 45,
  "label": "Search API returns filtered results"
}
```

### `diff`

A git diff summary was captured.

```json
{
  "id": "ev-1713168780-1234",
  "type": "diff",
  "timestamp": "2026-04-15T10:33:00Z",
  "command": "git diff --stat HEAD~1",
  "stdout": "5 files changed, 120 insertions(+), 30 deletions(-)",
  "label": "Changes summary"
}
```

### `screenshot_unavailable`

A screenshot was requested but no browser automation tool was available.

```json
{
  "id": "ev-1713168840-1234",
  "type": "screenshot_unavailable",
  "timestamp": "2026-04-15T10:34:00Z",
  "url": "http://localhost:3000/users",
  "label": "Search page screenshot",
  "reason": "No browser automation tool available. Install shot-scraper: pip install shot-scraper && shot-scraper install"
}
```

### `startup_failure`

A dev server or required service failed to start.

```json
{
  "id": "ev-1713168900-1234",
  "type": "startup_failure",
  "timestamp": "2026-04-15T10:35:00Z",
  "command": "npm run dev",
  "stderr": "Error: EADDRINUSE: address already in use :::3000",
  "label": "Dev server failed to start",
  "reason": "Port 3000 already in use"
}
```

## Notes

- Evidence files are append-only. Never delete or modify existing entries.
- When assembling a demo document, use the most recent entry for each unique `label`.
- Stdout is truncated to 50KB to prevent excessively large evidence files.
- File paths in `screenshot` entries are relative to the repo's base directory.
