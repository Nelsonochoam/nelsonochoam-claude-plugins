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

**Before reading artifacts**, run prerequisite check per `${CLAUDE_PLUGIN_ROOT}/references/prerequisite-check.md` for phase `design`. If the check halts, stop here.

**Auto-advance**: If `$ARGUMENTS` contains `--autoadvance`, follow the auto-advance protocol in the prerequisite check reference before proceeding. Strip `--autoadvance` from arguments before using them as context.

Collect context from available sources, then merge:

1. **Feature folder** — read any available artifacts from `$FEATURE_PATH/`: `intent.md`, `research.md`.
   - If `research.md` is missing, do a codebase exploration as part of the design process to ground the approach in reality. Otherwise use the `research.md` and only do research as needed.
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

For complex flows, use your judgment on whether a mermaid diagram (sequence, flowchart, or state diagram) would help explain the approach more clearly than prose alone. If visualizing the flow makes it easier for an engineer to understand component interactions, branching logic, or state transitions — include one. Don't add diagrams for the sake of it; they should earn their place by clarifying something that text struggles to convey.

Use pseudo-code for flows and interactions. Use real code for interfaces, APIs, and config shapes. Reference existing patterns inline where you're building on them — e.g., "We'll follow the service pattern at `src/services/baz.ts:1-15`."

### 2. Identify Design Questions

Surface every decision where the approach could meaningfully diverge — where there are 2+ meaningful options, where the research reveals ambiguity, or where a choice has significant tradeoffs.

For each question:
- Write a context line explaining **why** this decision matters
- Present **Option A** and **Option B** (or C if genuinely needed) with code snippets showing what each looks like in practice
- Include explicit **Pros** and **Cons** for each option
- Give a **Recommendation** that names the specific tradeoff being accepted

Read `${CLAUDE_SKILL_DIR}/references/questions-format.md` for the exact format.

### 3. Write Draft to File

Read the template from `${CLAUDE_SKILL_DIR}/references/template.md`. Collect the task/ticket identifier from the intent (e.g. `ticket-3459-feature-name`). Write a draft design document to `$FEATURE_PATH/design.md` (create the directory if needed) that includes:

- **Summary** — what we're building
- **Motivation** — why it matters, who's affected, cost of inaction
- **Current State** — factual findings from research with `file:line` references
- **Desired End State** — what's true when done
- **What we're not doing** — explicit scope boundaries
- **Proposed Approach** — the narrative core: how the solution works, with code and inline pattern references
- **Design Questions** — the open questions with options, tradeoffs, and your recommendation (follow the format from `${CLAUDE_SKILL_DIR}/references/questions-format.md`)
- **Risks & Mitigations** — what could go wrong and how we handle it
- **Validation** — how to verify the solution works
- **AC Coverage** — traceability from acceptance criteria to design sections (see template)

Before writing the draft, review the intent's acceptance criteria:
- If the intent contains explicit ACs (AC-1, AC-2, etc.), verify that every AC is addressed by at least one design decision (D1, D2, etc.). Map each AC to the decisions that cover it in the AC Coverage table.
- If the intent has no explicit ACs, infer the key outcomes the design is meant to achieve from the intent's summary, motivation, and scope. List these as coverage items in the AC Coverage section using the checklist format from the template.
- If any AC is not covered by the design, either expand the design to address it or note it as intentionally deferred with a reason.

Do NOT print the document content in the conversation. Once written, say:

```
Draft written to $FEATURE_PATH/design.md — open it and let me know your thoughts.
```

Wait for the user's response.

### 4. Collaborate Until Confirmed

Work with the user like two peers reviewing a document together. They may question decisions, prefer different options, surface new requirements, or want to change direction entirely.

- Update `$FEATURE_PATH/design.md` after each meaningful exchange to reflect the current agreed state.
- Do not re-print the document in the conversation — keep discussion focused and refer the user back to the file.
- If they introduce new requirements or constraints, discuss the implications, update the approach, and surface any new design questions that arise.
- If more research is needed, do it and return with updated options and a recommendation.
- If anything is ambiguous, ask one focused follow-up before moving on.

Follow the resolution format from `${CLAUDE_SKILL_DIR}/references/questions-format.md` when recording decisions.

Once all questions are resolved and the user is satisfied, do a final update to `$FEATURE_PATH/design.md`:

- Move resolved questions into a **Resolved Design Questions** section
- Ensure the Proposed Approach reflects all decisions made

Then say:

```
════════════════════════════════════════
✓ Design confirmed.

Recommended next: /crispy-structure-outline
Any phase can follow — each works with whatever artifacts exist.
════════════════════════════════════════
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
