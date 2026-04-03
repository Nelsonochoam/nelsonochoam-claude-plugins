---
name: crispy-research
description: Answer research questions by exploring the codebase factually and writing findings to a document.
argument-hint: '<paste the research questions file path or the questions directly>'
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

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `research`
- **No-args fallback**: ask the user to provide the research questions.
- **Manifest handling**: If the `research-questions` phase isn't marked done, warn the user but continue with whatever questions are available.

Once resolved, read `<BASE_DIR>/<feature>/research-questions.md` as the **only** input. Do NOT read `intent.md` or any other prior artifact — the research phase must not know what is being built, only what questions need answering. This keeps findings factual and unbiased. If the user also provided arguments, use those as supplementary context only if they are additional questions, not intent or design direction.
## Initial Setup

When this command is invoked, check if research questions were provided (either from the feature folder or as an argument):
- If yes, read them and proceed to Step 1
- If no, respond with:
  ```
  Please provide the research questions — paste them directly or give the path to the research questions file.
  ```
  Then wait for the user's input.

## Steps

### 1. Read Any Directly Mentioned Files First

If the questions reference specific files, read them **fully** in the main context before spawning any sub-agents — no `limit` or `offset` parameters. This gives you full context before decomposing the work.

### 2. Decompose and Plan

Break the questions into distinct research areas. Read `references/agent-types.md` for the available agent types and assign each area to the right fit.

### 3. Spawn Parallel Sub-agents

Run agents concurrently for independent questions or areas. Give each agent a focused, narrow scope. Remind them: document what exists, no recommendations.

Wait for **all sub-agents to complete** before synthesizing.

### 4. Gather Metadata

Before writing the document, collect:
- Today's date and time
- Current git branch: `git branch --show-current`
- Current git commit: `git rev-parse --short HEAD`

### 5. Synthesize

Compile all findings. Organize by question or component area, not by which agent found what. Verify critical claims by reading the relevant file sections yourself. When sources differ, prefer the live codebase.

### 6. Write the Research Document

Read the document format from `references/template.md`. Write findings to `<BASE_DIR>/<feature>/research.md` (create the directory if needed).

Then say:

```
Written to <BASE_DIR>/<feature>/research.md — please review.
Let me know if any area needs more depth or if something looks off.
```

Wait for the user's response.

### 7. Iterate Until Confirmed

If the user requests more depth on a question, do a targeted sub-agent lookup and update the file with Edit. Re-prompt for review. Do not reprint the full document to the conversation.

Once the user explicitly confirms, update the manifest's `research` phase to `done` with today's date and the file path.

Then say:

```
Confirmed. Run /design with the intent and research docs to synthesize the solution.
```

## Guidelines

- **Read mentioned files first**: Always before spawning sub-agents
- **Wait for all agents**: Never synthesize partial results
- **Detailed Findings use bullets**: Each bullet is a factual observation with a `file:line` reference
- **Use code snippets**: Include short, relevant snippets when they explain behavior better than prose
- **Code References are a flat index**: Every file touched during research should appear here
- **No recommendations**: If you notice something worth flagging, put it in Open Questions — not as a suggestion
