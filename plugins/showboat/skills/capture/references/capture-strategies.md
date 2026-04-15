# Capture Strategies

Guidance on what evidence to capture in different scenarios.

## After Running Tests

Capture the test command output:
- `npm test` / `pytest` / `cargo test` / `go test ./...`
- Include the full command, not a subset
- Label: "Unit tests pass" / "Integration tests pass" / "E2E tests pass"
- Also capture lint and type-check if available

## After Making UI Changes

For each affected page:
1. Take a screenshot of the page showing the change
2. Label with what the screenshot shows: "Search bar on /users page" not just "screenshot"
3. If the change is interactive (e.g., dropdown, modal), capture multiple states:
   - Before interaction
   - After interaction (click, type, etc.)

## After API Changes

For each affected endpoint:
1. Make an HTTP call to the endpoint
2. Use realistic parameters (not empty)
3. Label: "GET /api/users returns paginated results" not just "API call"
4. For POST/PUT/DELETE, capture both the request body (in the command) and response

## After CLI Changes

For each affected command:
1. Run the command with representative arguments
2. Capture stdout AND stderr (both are in the evidence record)
3. Verify exit code is expected (0 for success, non-zero for expected errors)
4. Label: "my-tool init creates project directory" not just "CLI output"

## After Configuration Changes

1. Capture the relevant config file content
2. Run a command that exercises the configuration
3. Verify the behavior matches expectations

## After Bug Fixes

1. Capture evidence that the bug is fixed (the command/page/API that previously failed now succeeds)
2. Capture the test that covers the bug (prevents regression)
3. Label: "Fix: login redirect now goes to /dashboard" not just "bug fixed"

## General Principles

- **Be specific in labels**: Labels appear in the demo document and should be self-explanatory
- **Capture the happy path first**: Then capture edge cases if relevant
- **One evidence item per concern**: Don't combine multiple checks into one capture
- **Include the verification criteria**: The evidence should make it obvious whether the check passed or failed
