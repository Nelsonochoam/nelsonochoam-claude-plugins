# Comparison Strategies

How to compare current verification results against original evidence.

## Exit Codes (Exact Match)

Exit codes must match exactly. `expect_exit: 0` means the current command must also exit with 0.

- **Pass**: current exit code == expected exit code
- **Fail**: any other value

## HTTP Status Codes (Exact Match)

Status codes must match exactly. `expect_status: 200` means the current response must also be 200.

- **Pass**: current status == expected status
- **Fail**: any other value

## Stdout (Fuzzy Match)

Stdout often contains dynamic content. Apply these normalization rules before comparing:

### Always ignore:
- **Timestamps**: dates, times, "2 minutes ago", epoch values
- **UUIDs/IDs**: anything matching `[0-9a-f]{8}-[0-9a-f]{4}-...` or sequential numeric IDs
- **Durations**: "3.2s", "45ms", "Time: 0.123"
- **File paths with temp dirs**: `/tmp/...`, `/var/folders/...`
- **Process IDs**: PID numbers
- **Memory/CPU metrics**: "Heap: 42MB", "CPU: 12%"

### Compare structurally:
- **Test results**: compare pass/fail counts, not individual test durations. "42 passed, 0 failed" should match if the current run also has "42 passed, 0 failed" (or more passed, 0 failed).
- **JSON responses**: compare keys and value types, not exact values for timestamps/IDs. The structure should match.
- **Line counts**: if the original had N lines of meaningful output, the current should have approximately N lines.

### Flag as potential regression:
- **New failures**: tests that previously passed now fail
- **Missing output**: expected sections of output are absent
- **Error messages**: new error or warning messages that weren't in the original
- **Status changes**: "0 failed" → "2 failed"

## HTTP Response Bodies (Structural Match)

Compare JSON responses structurally:

1. **Same keys present** — all keys from the original should exist in the current response
2. **Same value types** — if a field was a string, it should still be a string
3. **Same array lengths** (approximately) — if the original had 5 items, the current should have ~5 items (not 0)
4. **Ignore**: timestamps, IDs, generated tokens, session values

For non-JSON responses, fall back to fuzzy stdout comparison.

## Screenshots (Manual Review Only)

Automated visual comparison is not feasible in this environment. For screenshot evidence:

1. Capture a new screenshot at the same URL with the same viewport
2. Save it alongside the original with a verification timestamp
3. Note in the report: "New screenshot captured for manual comparison"
4. Consider this a **Pass** for automated purposes unless the page returns an error (4xx/5xx)

## General Principles

- **Be lenient on values, strict on structure** — dynamic data changes between runs, but the shape of the output should be stable
- **Report differences, don't guess** — when something doesn't match, describe what changed and let the human decide if it's a regression
- **Err on the side of failing** — it's better to flag a false positive than to miss a real regression
