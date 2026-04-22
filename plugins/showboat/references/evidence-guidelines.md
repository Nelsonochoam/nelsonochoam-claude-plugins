# Evidence Guidelines

These rules ensure evidence is trustworthy and verifiable. Follow them strictly.

## Anti-Fabrication Rules

1. **Always execute commands** — never write evidence records with pre-composed output. Run the actual command via `showboat exec` and use the real stdout/stderr/exit code.

2. **Never paste pre-written output** — if you know what the output should be, run the command anyway. The evidence must reflect what actually happened, not what you expected.

3. **Never edit evidence files** — evidence logs are append-only. If you need to re-capture something, add a new entry. The demo assembly skill uses the most recent entry for each label.

4. **Capture failures honestly** — if a test fails, a server won't start, or a screenshot can't be taken, record the failure as evidence. A demo with honest failures is more trustworthy than one with fabricated successes.

5. **Use real data** — when making HTTP calls or CLI commands, use realistic parameters. `curl localhost:3000/api/users?q=test` is better than `curl localhost:3000/api/users`.

## What Makes Good Evidence

- **Self-explanatory**: Someone reading the demo should understand what each piece of evidence proves without additional context.
- **Reproducible**: The command/URL in the evidence can be re-run to get the same (or equivalent) result.
- **Complete**: The evidence covers the full scope of the change — not just one happy path.
- **Timestamped**: Each entry has a UTC timestamp so temporal ordering is clear.

## What to Capture

For any feature, aim to capture at minimum:
1. **Tests pass** — run the relevant test suite(s)
2. **Build succeeds** — if applicable, verify the build completes
3. **Feature works** — at least one piece of evidence showing the feature in action (screenshot, API response, CLI output)

Additional evidence that strengthens the demo:
- Edge case handling (empty state, error state, max values)
- Performance characteristics (response times in HTTP evidence)
- No regressions (full test suite pass, not just feature-specific tests)

## When NOT to Capture

- Don't capture evidence for code that wasn't changed
- Don't capture infrastructure details (server logs, build cache, etc.) unless they're relevant to the change
- Don't capture sensitive data (API keys, passwords, personal information)
