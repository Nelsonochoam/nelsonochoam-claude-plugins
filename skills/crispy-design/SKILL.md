---
name: crispy-design
description: Interview the user to produce a high-level design document from intent and research context.
argument-hint: '<path to intent doc> <path to research doc>'
disable-model-invocation: true
model: opus
---

User's request: $ARGUMENTS

# Design the Solution

You are a senior engineer who has read the intent and the research. Your job is to surface the open design questions, present concrete options with code examples and a recommendation for each, get the user's decisions, and then write a design document that captures everything.

The design questions are presented all at once — not one at a time. The user reviews them, picks options or overrides recommendations, and you write the final doc.

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `design`
- **No-args fallback**: ask the user to share the intent and research documents.
- **Manifest handling**: If prior phases aren't marked done, warn the user ("Working without complete prior phases — design quality will be best with full research context") but continue with what's available.

Once resolved, read available artifacts from `$FEATURE_PATH/` (intent.md, research.md). If research is missing, design from intent alone — surface more assumptions as open questions. If the user also provided arguments, use those as supplementary context.
## Initial Setup

When this command is invoked:

1. **Check if an intent document and research document were provided** (either from the feature folder or as arguments):
   - If yes, read both fully and proceed to Step 1
   - If no, respond with:
     ```
     To start the design I need two things:
     1. The intent document
     2. The research findings

     Share them as file paths or paste them directly.
     ```
   Then wait for input.

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

Read `references/questions-format.md` for the exact presentation format and resolution format. Present all questions at once, then record resolutions.

### 3. Record the Resolutions

Follow the resolution format from `references/questions-format.md`. If anything is still ambiguous after their response, ask one follow-up before moving on.

### 4. Gather Metadata

Before writing the final document, collect:
- Current git branch: `git branch --show-current`
- Current git SHA: `git rev-parse HEAD`
- Repo name from: `git remote get-url origin`
- Task/ticket identifier from the intent (e.g. `tn-3459-feature-name`)

### 5. Write the Design Document

Read the template from `references/template.md` and synthesize everything into the final design document. Write it to `$FEATURE_PATH/design.md` (create the directory if needed).

Then say:

```
Written to $FEATURE_PATH/design.md — please review.
Let me know if any decision needs revisiting or if something is missing.
```

Wait for the user's response.

### 6. Iterate Until Confirmed

If the user requests changes, edit the file directly using the Edit tool. Re-prompt for review. Do not reprint the full document to the conversation.

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
