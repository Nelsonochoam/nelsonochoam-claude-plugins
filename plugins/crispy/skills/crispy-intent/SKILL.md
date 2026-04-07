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
- **Existing intent**: If `$FEATURE_PATH/intent.md` already exists, ask the user whether they want to start a fresh intent or continue editing the existing one. If the file doesn't exist, proceed normally.

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

**Background:**
- What's the current system state relevant to this change?
- Has this been attempted before? Are there relevant docs, threads, or prior art?

**Scope:**
- What exactly should change or be created? What is explicitly out of scope, and why?
- Are there related areas that look similar but should NOT be touched?

**Motivation:**
- What problem does this solve, and who is affected by it?
- Is this a user complaint, a business requirement, tech debt, or something else?
- Why now? What's the cost of not doing this?

**Acceptance:**
- How will we know this is done? Describe scenarios: "Given X, when Y, then Z."
- Are there edge cases or error states that must be handled?
- Are there non-functional requirements (performance, security, accessibility)?

**Risks:**
- What could go wrong? Are there non-obvious edge cases or race conditions?
- Is there legacy behavior or technical debt that could trip up the implementation?
- Are there migration concerns or backwards-compatibility risks?

**Constraints:**
- Are there technical constraints, deadlines, or dependencies?

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

1. Write the intent document to `$FEATURE_PATH/intent.md` — the document **must include the front matter block** (`task` and `type` fields) from the template, filled in with the resolved feature name and `type: intent`. Acceptance criteria must use the Given/When/Then format with numbered labels (AC-1, AC-2, etc.)

Then say:

```
Written to $FEATURE_PATH/intent.md — please open it and review.
```

Wait for the user's response.

### 4. Iterate Until Confirmed

If the user requests changes, edit the file directly using the Edit tool and re-prompt for review. Do not print the full document to the conversation — point the user to the file.

## Guidelines

1. **Do not research code**: This phase is about understanding the ask, not the codebase
2. **Do not suggest solutions**: Surface the problem space, not the answer
3. **Acceptance criteria must be scenario-based**: Use Given/When/Then format. If a criterion can't be expressed as a scenario, it's likely a task, not a criterion. Vague criteria ("it should work well") should be pushed back on
4. **No open questions in the final document**: If something is unresolved, either research it or flag it explicitly as an open question
5. **Keep scope tight**: If the user's request seems to be expanding, note it and ask if that is intentional
6. **Gotchas & Risks must have substance**: This section should contain things a developer would wish they knew before starting. If you can't identify any, ask the user — there are always risks
7. **Out of scope needs rationale**: Each out-of-scope item should briefly explain why it's excluded, to prevent re-litigation
