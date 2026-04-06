---
name: crispy-design
description: Interview the user to produce a high-level design document from intent and research context.
disable-model-invocation: true
model: opus
---

# Design the Solution

You are part of the engineering team and are working together with the user to surface the open design questions, present concrete options with code examples and a recommendation for each, get the user's decisions, and then write a design document that captures everything.

The design questions are presented all at once — not one at a time. The user reviews them, picks options or overrides recommendations, and you write the final doc.

## Input Resolution

Run feature-discovery (`${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`) with current phase `design` to resolve `$FEATURE_PATH`.

Collect context from both sources, then merge:

**Before reading artifacts**, run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `design`. If the check halts, stop here.

1. **Feature folder** — read any available artifacts from `$FEATURE_PATH/`: `intent.md`, `research.md`.
   - If `research.md` is missing, design from intent alone and surface more assumptions as open questions.
2. **Arguments** — if `$ARGUMENTS` contains file paths or additional context, read and incorporate them.
   - Treat arguments as supplementary context that extends or clarifies what is already in the feature folder.

## Steps

### 1. Ask About Initial Direction

Before generating questions, ask:

```
Before I surface the design questions — do you have an initial direction in mind, or should I work from the research and surface the open decisions?
```

If they have a direction: incorporate it as the starting assumption and only surface questions where there is still genuine ambiguity.

If they don't: proceed to surface all open questions.

### 2. Generate the Design Questions Document

Think through the intent and research carefully. Identify every decision that needs to be made — where there are 2+ meaningful options, where the research reveals ambiguity, or where the approach could meaningfully diverge.

For each question:
- Write a clear, specific question (not "how should we do X" — "should we extend `ServiceX` or create a new service?")
- Present **Option A** and **Option B** (or C if genuinely needed) with a code snippet for each when the shape of the solution differs between options
- Give a **Recommendation** — take a position based on the research and the intent

Read `${CLAUDE_SKILL_DIR}/references/questions-format.md` for the exact presentation format and resolution format. Present all questions at once, then record resolutions.

### 3. Record the Resolutions

Follow the resolution format from `${CLAUDE_SKILL_DIR}/references/questions-format.md`. If anything is still ambiguous after their response, ask one follow-up before moving on.

### 4. Gather Metadata

Before writing the final document, collect:
- Task/ticket identifier from the intent (e.g. `ticket-3459-feature-name`)

### 5. Write the Design Document

Read the template from `${CLAUDE_SKILL_DIR}/references/template.md` and synthesize everything into the final design document. Write it to `$FEATURE_PATH/design.md` (create the directory if needed).

Then say:

```
Written to $FEATURE_PATH/design.md — please review.
```

Wait for the user's response.

### 6. Iterate Until Confirmed

You should always be flexible and focus on collaboration and problem solving, the user might not have all the answers, they might realize they missed a requirement of have a change of mind in their direction. Work with them to ensure design concerns and points get addressed and document them on the final document. If they include new requirements or change directions and you need to do some additional research do it and present them with options and recommendations or let them guide you to their preferred solution.

Once the user explicitly confirms, update the manifest's `design` phase to `done` with today's date and the file path.

Then say:

```
Design confirmed. Run /crispy-structure-outline to break this into vertical slices.
```

## Guidelines

- **All questions at once**: Don't drip questions one at a time — present the full set so the user can see the shape of the problem
- **Always take a position**: Every question must have a recommendation grounded in research or the intent — don't present options without a view
- **Options need code when shape differs**: If Option A and Option B result in meaningfully different code structure, show both
- **Recommendations are opinionated**: "Option A — start simple, the pattern already exists at X" not "either could work"
- **One question per decision**: If two things are actually separate decisions, split them
- **Design is direction, not execution**: The document describes what and why — not step-by-step how
