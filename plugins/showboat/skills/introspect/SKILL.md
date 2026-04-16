---
name: introspect
description: Capture corrections and lessons from this testing session into introspection.md at the feature demo path.
argument-hint: '<optional: feature-name>'
model: opus
---

User's request: $ARGUMENTS

# Introspect

You are capturing what was learned during this testing session — corrections the user provided, things that failed, and what the right approach turned out to be. Write it all to a single `introspection.md` file at the feature's demo path.

## Project Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/project-discovery.md`.

Store the resolved base directory as `$DEMO_BASE`.

## Gather Corrections and Failures

Review the current conversation for anything that went wrong or was corrected:

- **Navigation**: wrong routes, redirects, 404s
- **Auth**: login steps that were missing or wrong
- **Timing**: pages that needed extra wait time, spinners, async delays
- **Selectors**: wrong CSS selectors, elements that weren't where expected
- **Data**: seed commands needed, test credentials, fixture requirements
- **Environment**: wrong ports, missing env vars, prerequisite services
- **Workflow**: ordering issues, migrations needed before server start
- **Commands**: test commands that failed, build commands that changed

Also check for any failed or partial demo documents:

```bash
showboat verify "$DEMO_BASE/demo.md" 2>&1 || true
grep -l 'status: partial\|status: regression' "$DEMO_BASE/"*.md 2>/dev/null
```

If nothing went wrong and the user hasn't provided corrections, use `AskUserQuestion`:

> What corrections or tips should I record from this session?

Options: `I have corrections to share` / `Nothing to record`

## Write introspection.md

Write everything to `$DEMO_BASE/introspection.md`. If the file already exists, append to it rather than overwriting — preserve prior entries.

The file should be plain and readable:

```markdown
# Introspection: <feature-name>

## <YYYY-MM-DD>

### What went wrong
- <brief description of each failure>

### Corrections
- <what the right approach was>
- <corrected route, selector, command, etc.>

### Notes for next time
- <anything that would help the next demo go smoother>
```

Keep it concise. One paragraph per issue is enough. The goal is a quick reference, not a detailed report.

## Done

```
Written to: $DEMO_BASE/introspection.md
```
