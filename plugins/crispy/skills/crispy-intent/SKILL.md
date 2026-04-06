---
name: crispy-intent
description: Capture intent, define acceptance criteria, and surface ambiguities before any research or planning begins.
argument-hint: '<describe what you want to build or change>'
model: opus
---

User's request: $ARGUMENTS

# Capture Intent

You are tasked with fully understanding what the user wants before any work begins. Do not research code, do not suggest solutions, do not form opinions about implementation. Only ask, listen, and document.

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `intent`
- **No-args fallback**: ask the user to describe what they want to build or change.
- **Manifest handling**: If the `intent` phase is already `done`, ask the user whether they want to start a fresh intent or continue editing the existing one. If `pending`, load the existing `intent.md` and skip to Step 4 (Iterate Until Confirmed).

## Initial Setup

When this command is invoked:

1. **Check if a description was provided as a parameter**:
   - If yes, restate it in your own words and proceed to Phase 2
   - If no, respond with:
   ```
   I'll help capture the intent before we start. Please describe what you want to build or change — as much or as little detail as you have.
   ```
   Then wait for the user's input.

## Steps

### 1. Restate and Confirm

Restate the user's request in 2–3 sentences in your own words. This surfaces any initial misreading and gives the user a chance to correct it before questions are asked.

Then say: "Before we proceed I have a few questions to make sure I understand your intent fully."

### 2. Ask Clarifying Questions

Ask targeted questions across the following dimensions. Only ask what is genuinely unclear — do not ask about things already stated.

**Scope:**
- What exactly should change or be created? What is explicitly out of scope?
- Are there related areas that look similar but should NOT be touched?

**Motivation:**
- What problem does this solve, and who is affected by it?
- Is this a user complaint, a business requirement, tech debt, or something else?

**Acceptance:**
- How will we know this is done? What does success look like to the user?
- Are there edge cases or error states that must be handled?
- Are there non-functional requirements (performance, security, accessibility)?

**Constraints:**
- Are there technical constraints, deadlines, or dependencies?
- Must this be backwards compatible? Are there migration concerns?

Present all questions in a single numbered list. Wait for the user's answers before continuing.

### 3. Write the Intent Document

Once the user has answered, determine the feature name using this priority:

1. **Ticket** — if the user mentioned a ticket, use it as the feature name.
2. **Intent title** — otherwise, convert the intent title to kebab-case (e.g. "Add Dark Mode Toggle" → `add-dark-mode-toggle`).

Then resolve and create the feature folder by running:

```bash
FEATURE_PATH=$(bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-feature.sh" "<feature-name>")
```

Read the template from `references/intent-template.md`, then:

1. Write the intent document to `$FEATURE_PATH/intent.md`
2. Create the manifest at `$FEATURE_PATH/manifest.json` using the template from `references/manifest-template.json` — replace `<Feature Name>`, `<feature>`, and `<today's date>` with actual values.

Then say:

```
Written to $FEATURE_PATH/intent.md — please open it and review.
Let me know if anything needs to change, or confirm to proceed to /crispy-research-questions.
```

Wait for the user's response.

### 4. Iterate Until Confirmed

If the user requests changes, edit the file directly using the Edit tool and re-prompt for review. Do not print the full document to the conversation — point the user to the file.

### 5. Update Manifest

Once the user explicitly confirms the intent document is correct, update the manifest's `intent` phase to `done` with today's date.

Then say:

```
Intent confirmed. Run /crispy-research-questions to generate the research questions.
```

## Guidelines

1. **Do not research code**: This phase is about understanding the ask, not the codebase
2. **Do not suggest solutions**: Surface the problem space, not the answer
3. **Be specific about acceptance criteria**: Vague criteria ("it should work well") should be pushed back on — ask for something testable
4. **No open questions in the final document**: If something is unresolved, either research it or flag it explicitly as an open question
5. **Keep scope tight**: If the user's request seems to be expanding, note it and ask if that is intentional
