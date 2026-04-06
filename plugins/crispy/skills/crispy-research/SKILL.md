---
name: crispy-research
description: Answer research questions by exploring the codebase factually and writing findings to a document.
disable-model-invocation: true
model: opus
---

User's request: $ARGUMENTS

# Research Codebase

You are tasked with answering a set of research questions by exploring the codebase and writing up what you find. You spawn parallel sub-agents to cover the questions efficiently, synthesize their findings, and write the results to a document.

## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY
- DO NOT suggest improvements or changes
- DO NOT infer what the user is trying to build and offer opinions about it
- DO NOT propose future enhancements
- DO NOT critique the implementation or identify problems
- ONLY describe what exists, where it exists, how it works, and how components interact

## Input Resolution

Run feature-discovery (`${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`) with current phase `research` to resolve `$FEATURE_PATH`.

**Before reading artifacts**, run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `research`. If the check halts, stop here.

Read questions from `$FEATURE_PATH/research-questions.md` in full.

Do NOT read `intent.md` or any other prior artifact — the research phase must stay unbiased about what is being built.

## Steps

### 1. Decompose and Plan

Break the questions into distinct research areas. Read `${CLAUDE_SKILL_DIR}/references/agent-types.md` for the available agent types and assign each area to the right fit.

### 2. Spawn Parallel Sub-agents

Run agents concurrently for independent questions or areas. Give each agent a focused, narrow scope. Remind them: document what exists, no recommendations.

Wait for **all sub-agents to complete** before synthesizing.

### 3. Synthesize

Compile all findings. Organize by question or component area, not by which agent found what. Verify critical claims by reading the relevant file sections yourself. When sources differ, prefer the live codebase.

### 4. Write the Research Document

Read the document format from `${CLAUDE_SKILL_DIR}/references/template.md`. Write findings to `$FEATURE_PATH/research.md` (create the directory if needed).

Then say:

```
Written to $FEATURE_PATH/research.md — please review.
```

### 5. Iterate Until Confirmed

If the user requests more depth on a question, do a targeted sub-agent lookup and update the file with Edit. Re-prompt for review. Do not reprint the full document to the conversation.

Once the user explicitly confirms, update the manifest's `research` phase to `done` with today's date and the file path.

Then say:

```
Confirmed. Run /design with the intent and research docs to synthesize the solution.
```

## Guidelines

- **Wait for all agents**: Never synthesize partial results
- **Detailed Findings use bullets**: Each bullet is a factual observation with a `file:line` reference
- **Use code snippets**: Include short, relevant snippets when they explain behavior better than prose
- **Code References are a flat index**: Every file touched during research should appear here
- **No recommendations**: If you notice something worth flagging, put it in Open Questions — not as a suggestion
