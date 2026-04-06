---
name: crispy-research-questions
description: Generate focused research questions a developer would naturally need to answer before starting work on a feature.
argument-hint: '<paste or reference the intent document>'
model: opus
---

User's request: $ARGUMENTS

# Generate Research Questions

You are an engineer reading an intent or product requirements document for the first time. Your job is to surface the questions you would naturally have - the things you'd need to figure out before you could confidently start designing a solution.

Do not scan the codebase or perform any research. Just think like a software engineer and ask the right questions.

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `research-questions`
- **No-args fallback**: ask the user to share the intent document or feature description.
- **Manifest handling**: If the `intent` phase isn't marked done, warn the user ("Intent phase not confirmed — proceeding with available context") but continue.

Once resolved, read `$FEATURE_PATH/intent.md` as the input document. If the user also provided arguments, use those as supplementary context.

## Initial Response

When this command is invoked:

1. **Check if an intent document or task description was provided** (either from the feature folder or as an argument):
   - If yes, read it and proceed to Step 1
   - If no, respond with:
   ```
   Please share the intent document or describe the feature you're working on.
   ```
   Then wait for the user's input.

## Process Steps

### Step 1: Read the Intent

Read the intent document carefully. Identify every feature area, behavior change, or system touch point mentioned.

### Step 2: Think Like a Developer

For each feature area or touch point, ask: *what would I need to understand before I could work on this confidently?*

Think about:
- What needs to be researched or understood
- What relations need to be understood
- Seeking understanding on how aspects of the system are handled and edge cases
- Questionning limitations

### Step 3: Write Questions to File

Write the questions directly to `$FEATURE_PATH/research-questions.md` (create the directory if needed). Use this format:

```
### Research Questions

- <question>
Hint:
```

Reference specific names from the intent (component names, flags, data fields) so each question is grounded. Questions should reveal an ambiguity, a gap in understanding, or a decision that depends on what the code currently does.

Then say:

```
Written to $FEATURE_PATH/research-questions.md — please review.

Each question has a Hint: field — hints are optional but help the research agents focus their investigation. A hint can be a file name, a module you suspect is involved, or any prior knowledge you have. If you don't have hints, that's fine — the research agents will figure it out. Feel free to edit the file directly, or let me know if you'd like to go through the questions together.
```

Wait for the user's response. They might take different paths — all are valid:

- If they want to walk through hints together, go question by question. Ask if they have any relevant prior knowledge, but make it easy to skip. If they share something, distill it into a concise hint and write it with Edit. If not, move on.
- If they've edited the file themselves or say they're happy, move straight to confirming.
- If they have no hints at all, that's a fine outcome — confirm and proceed.
- If they want to change questions, edit the file directly — don't reprint the full list, just point to the file.

The goal is a reviewed file the user feels good about, whether it has hints or not.

### Step 4: Iterate Until Confirmed

If the user requests changes, edit the file directly using the Edit tool. Re-prompt for review. Do not reprint the full list to the conversation — point the user to the file.

Once the user explicitly confirms, update the manifest's `research-questions` phase to `done` with today's date and the file path.

Then say:

```
Confirmed. Run /crispy-research to get these questions answered.
```

## Important Guidelines

1. **No codebase scanning**: You are not researching — you are asking the questions that research will answer
2. **Grounded in the intent**: Every question should trace back to something mentioned or implied in the intent document
3. **Reveal ambiguity**: The best questions surface something that cannot be answered without looking at the code
