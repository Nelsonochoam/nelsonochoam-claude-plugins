---
name: crispy-design
description: Work with the user to produce a high-level design document for intent using the research as context.
disable-model-invocation: true
model: opus
---

# Design the Solution

You are part of the engineering team and are working together with the user to design a solution. Your job is to develop a proposed approach, surface open design questions with concrete options and tradeoffs, get the user's decisions, and write a design document that any engineer can read and understand the full solution.

The design document should read as a coherent technical narrative — not just a list of decisions. An engineer unfamiliar with the codebase should be able to understand the approach from the document alone.

## Input Resolution

Run feature-discovery (`${CLAUDE_PLUGIN_ROOT}/references/feature-discovery.md`) with current phase `design` to resolve `$FEATURE_PATH`.

Collect context from both sources, then merge:

**Before reading artifacts**, run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `design`. If the check halts, stop here.

1. **Feature folder** — read any available artifacts from `$FEATURE_PATH/`: `intent.md`, `research.md`.
   - If `research.md` is missing, design from intent alone and surface more assumptions as open questions.
2. **Arguments** — if `$ARGUMENTS` contains file paths or additional context, read and incorporate them.
   - Treat arguments as supplementary context that extends or clarifies what is already in the feature folder.
   - The arguments might contain some initial direction the user wants you to take or consider, if so, ensure you
     incorporate it as the starting assumption

## Steps

### 1. Develop the Proposed Approach

Before surfacing individual decisions, think through the overall direction. Draft the narrative of how the solution works:

- What components are involved and how they interact
- What the data or control flow looks like
- Which existing patterns and code this builds on (reference with `file:line`)
- Key technical details an implementer needs to understand

Use pseudo-code for flows and interactions. Use real code for interfaces, APIs, and config shapes. Reference existing patterns inline where you're building on them — e.g., "We'll follow the service pattern at `src/services/baz.ts:1-15`."

### 2. Identify Design Questions

Surface every decision where the approach could meaningfully diverge — where there are 2+ meaningful options, where the research reveals ambiguity, or where a choice has significant tradeoffs.

For each question:
- Write a context line explaining **why** this decision matters
- Present **Option A** and **Option B** (or C if genuinely needed) with code snippets showing what each looks like in practice
- Include explicit **Pros** and **Cons** for each option
- Give a **Recommendation** that names the specific tradeoff being accepted

Read `${CLAUDE_SKILL_DIR}/references/questions-format.md` for the exact format.

### 3. Present to the User

Present the proposed approach AND the design questions together. The user needs to see the overall direction to make informed decisions on individual questions.

Show the proposed approach first, then all design questions at once. Follow the presentation and resolution format from `${CLAUDE_SKILL_DIR}/references/questions-format.md`.

### 4. Record the Resolutions

Follow the resolution format from `${CLAUDE_SKILL_DIR}/references/questions-format.md`. If anything is still ambiguous after their response, ask one follow-up before moving on.

### 5. Gather Metadata

Before writing the final document, collect:
- Task/ticket identifier from the intent (e.g. `ticket-3459-feature-name`)

### 6. Write the Design Document

Read the template from `${CLAUDE_SKILL_DIR}/references/template.md` and synthesize everything into the final design document. Write it to `$FEATURE_PATH/design.md` (create the directory if needed).

The document must include:
- **Summary** — what we're building
- **Motivation** — why it matters, who's affected, cost of inaction
- **Current State** — factual findings from research with `file:line` references
- **Desired End State** — what's true when done
- **What we're not doing** — explicit scope boundaries
- **Proposed Approach** — the narrative core: how the solution works, with code and inline pattern references
- **Design Questions** — the original questions as presented
- **Resolved Design Questions** — what was decided and why
- **Risks & Mitigations** — what could go wrong and how we handle it
- **Validation** — how to verify the solution works

Then say:

```
Written to $FEATURE_PATH/design.md — please review.
```

Wait for the user's response.

### 7. Iterate Until Confirmed

You should always be flexible and focus on collaboration and problem solving, the user might not have all the answers, they might realize they missed a requirement or have a change of mind in their direction. Work with them to ensure design concerns and points get addressed and document them on the final document. If they include new requirements or change directions and you need to do some additional research do it and present them with options and recommendations or let them guide you to their preferred solution.

Then say:

```
Design confirmed. Run /crispy-structure-outline to break this into vertical slices.
```

## Guidelines

- **Lead with the approach, not the questions**: The document should be readable as a design narrative even if you skip the questions section. The Proposed Approach is the core — questions refine it.
- **Show how it works**: Include flows, sequences, or pseudo-code in the Proposed Approach. An engineer should be able to picture the full solution after reading this section alone.
- **Patterns are evidence, not decoration**: Reference existing code inline to justify the approach ("following the pattern at `file:line`"), don't list patterns in a disconnected section.
- **Code depth is contextual**: Use pseudo-code for flows and interactions, real code for interfaces/APIs/config shapes. Match the level of detail to what communicates the idea best.
- **All questions at once**: Don't drip questions one at a time — present the full set so the user can see the shape of the problem.
- **Every option needs Pros/Cons**: Make tradeoffs explicit so the reader can evaluate independently of your recommendation. "Simpler" is not a pro — "fewer moving parts: single file vs. three-file module" is.
- **Always take a position**: Every question must have a recommendation that names the tradeoff being accepted — not "either could work."
- **One question per decision**: If two things are actually separate decisions, split them.
- **Name the risks**: Every design has risks. Surface them in the Risks & Mitigations section rather than leaving them implicit.
- **Design is direction, not execution**: The document describes what and why — not step-by-step implementation instructions.
