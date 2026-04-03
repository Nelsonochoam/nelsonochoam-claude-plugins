---
name: crispy-research-questions
description: Generate focused research questions a developer would naturally need to answer before starting work on a feature.
argument-hint: '<paste or reference the intent document>'
model: opus
---

User's request: $ARGUMENTS

# Generate Research Questions

You are an engineer reading an intent/prd document for the first time. Your job is to surface the questions you would naturally have — the things you'd need to figure out before you could confidently start working.

Do not scan the codebase. Do not research anything. Just think like a software engineer and ask the right questions.

## Feature Discovery

Read and follow `${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`.

- **Current phase**: `research-questions`
- **No-args fallback**: ask the user to share the intent document or feature description.
- **Manifest handling**: If the `intent` phase isn't marked done, warn the user ("Intent phase not confirmed — proceeding with available context") but continue.

Once resolved, read `<BASE_DIR>/<feature>/intent.md` as the input document. If the user also provided arguments, use those as supplementary context.
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

### Step 2: Think Like a Developer Starting This Work

For each feature area or touch point, ask: *what would I need to understand before I could work on this confidently?*

Think about:
- What needs to be researched or understood
- What relations need to be understood
- Seeking understanding on how aspects of the system are handled and edge cases
- Questionning limitations

### Step 3: Write the Questions

Format the output as questions to topics that need to be explored, to gain the understanding needed to figure out how to proceed in designing a solution.

Format:

```
### Research Questions

- <The question a developer would have. Reference specific files, components, or concepts from the intent by name where relevant. Be specific about the ambiguity or gap.>

- <question>
```

Rules:
- Reference specific names from the intent (component names, flags, data fields) so the question is grounded
- Questions should reveal an ambiguity, a gap in understanding, or a decision that depends on what the code currently does

### Step 4: Write to File

Write the questions to `<BASE_DIR>/<feature>/research-questions.md` (create the directory if needed). Use this format:

```
### Research Questions

- <question>
Hint:

- <question>
Hint:
```

Below each question add a `Hint:` line — this lets the user optionally add steering context before running research.

Then say:

```
Written to <BASE_DIR>/<feature>/research-questions.md — please review.
Add hints to any question where you want to steer the research.
Let me know if any questions are missing or should be changed.
```

Wait for the user's response.

### Step 5: Iterate Until Confirmed

If the user requests changes, edit the file directly using the Edit tool. Re-prompt for review. Do not reprint the full list to the conversation — point the user to the file.

Once the user explicitly confirms, update the manifest's `research-questions` phase to `done` with today's date and the file path.

Then say:

```
Confirmed. Run /research to get these questions answered.
```

## Important Guidelines

1. **No codebase scanning**: You are not researching — you are asking the questions that research will answer
2. **Grounded in the intent**: Every question should trace back to something mentioned or implied in the intent document
3. **Reveal ambiguity**: The best questions surface something that cannot be answered without looking at the code
