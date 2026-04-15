# Usage Guide

## The Phases

### 1. Intent — Define what you're building *(required)*

Captures scope, motivation, acceptance criteria, and constraints before any code is touched. Most subsequent phases read this as context — with one deliberate exception: research never reads the intent directly when research questions exist (see phase 2 for why). Flexible — accepts anything from a single phrase to a full structured document.

**Output:** `1-intent.md`

### 2. Research Questions — Scope the research

Reads `1-intent.md` and surfaces the questions that would need answered before starting work. Does a light scan of the codebase to confirm specifics mentioned in the intent (component names, flags, file paths) and ground the questions in reality — but does not go deep. Deep exploration happens in the research phase.

**Why this phase exists:** Research questions act as a middle layer that hides the intent from the research phase. If the research agent reads the intent directly, it starts forming opinions about implementation and steers its findings toward what the intent says should be built — rather than documenting what actually exists. By distilling the intent into focused questions first, research stays grounded in facts. The questions tell the researcher *where to look* without revealing *what we plan to do*, which keeps findings objective and prevents confirmation bias.

**Reads:** `1-intent.md` | **Output:** `2-research-questions.md`

### 3. Research — Answer those questions

Spawns parallel sub-agents to explore the codebase and answer questions factually. Documents what exists — no opinions, no design. When `2-research-questions.md` exists, research reads only that (not intent) to keep findings objective. When it doesn't exist, research derives questions from the intent internally — this still works but loses some of the objectivity benefit.

**Reads:** `2-research-questions.md` or `1-intent.md` | **Output:** `3-research.md`

### 4. Design — Decide the approach

Surfaces open design decisions as options with recommendations, gets your decisions, then writes a design document. When research is available, uses it for grounding. When it's not, does lightweight codebase exploration as part of the design process.

**How to use design questions:** The options presented are starting points for discussion, not a closed list. You can pick one of the presented options, combine ideas from multiple options, or propose an entirely different approach. The goal is a conversation that steers the implementation direction — not a multiple-choice quiz. Push back, suggest alternatives, or change direction entirely. The design updates in place as decisions are made.

**Reads:** `1-intent.md`, `3-research.md` (if available) | **Output:** `4-design.md`

### 5. Structure — Break it into phases

**Why this phase exists:** LLMs naturally split work into horizontal layers — database first, then API, then frontend. That might not match how you actually want to build a feature. This phase gives you control over how the work gets planned by breaking it into vertical slices of functionality, where each phase delivers end-to-end behavior (with its own tests and verification) rather than a single layer across the stack. You can define how the work should be split — reorder phases, collapse them, or restructure entirely. If you don't specify, the LLM will do its best to organize the work as vertical slices by default.

**Reads:** `1-intent.md`, `4-design.md`, `3-research.md` (whatever exists) | **Output:** `5-structure-outline.md`

### 6. Plan — Write the mechanical plan

Produces a master plan index and self-sufficient phase docs. The plan (`6-plan.md`) contains the overview, dependency graph, and links to phase docs. Each phase doc (`phases/phase-N.md`) contains all implementation details: exact file paths, code changes, design decisions, and success criteria.

**Reads:** `1-intent.md`, `4-design.md`, `3-research.md`, `5-structure-outline.md` (whatever exists) | **Output:** `6-plan.md` + `phases/phase-N.md`

### 7. Implement — Execute the work

Adapts to what exists. When a full plan with manifest and phase docs is available, it follows the planned execution path — one phase at a time with verification between each. When only some artifacts exist, it works from whatever's available, breaking the work into logical chunks and pausing for user review between them.

**Reads:** whatever exists — `manifest.json` + `phases/phase-N.md`, or `6-plan.md`, or `1-intent.md` + `4-design.md`

---

## Workflow Examples

### Full Flow (recommended for complex work)

The seven-phase flow with fresh context between each:

```bash
# Session 1: Capture intent → 1-intent.md
CRISPY_FEATURE=my-feature claude
> /crispy:intent
# Review 1-intent.md, confirm, then reset
> /clear

# Session 2: Surface research questions → 2-research-questions.md
> /crispy:research-questions
# Review, confirm, reset
> /clear

# Session 3: Answer research questions → 3-research.md
> /crispy:research
# Review 3-research.md, confirm, reset
> /clear

# Session 4: Resolve design decisions → 4-design.md
> /crispy:design
# Review 4-design.md, confirm, reset
> /clear

# Session 5: Break into vertical phases → 5-structure-outline.md
> /crispy:structure
# Review 5-structure-outline.md, confirm, reset
> /clear

# Session 6: Write the detailed plan → 6-plan.md + phases/
> /crispy:plan
# Review 6-plan.md and phase docs, confirm
> /clear

# Session 7+: Implement one phase at a time
> /crispy:implement
# Implements next ready phase, stops. Review, then reset.
> /clear
> /crispy:implement
# Next phase...
```

### RPI Flow (intent → research → plan → implement)

A shorter loop inspired by the traditional research-plan-implement pattern. The plan phase surfaces design decisions and collaborates with you to resolve them since no separate design phase was run.

```bash
CRISPY_FEATURE=my-feature claude
> /crispy:intent Add a dark mode toggle to the settings page
# Confirm intent, reset
> /clear

> /crispy:research
# Research explores the codebase, documents what exists
# Review 3-research.md, confirm, reset
> /clear

> /crispy:plan
# Surfaces design decision points since no 4-design.md exists
# Collaborate on decisions, then plan is written
# Review 6-plan.md and phase docs, confirm
> /clear

> /crispy:implement
# Implements one phase at a time
```

### Quick Flow (intent → design → implement)

```bash
CRISPY_FEATURE=my-feature claude
> /crispy:intent Add a dark mode toggle to the settings page
# Confirm lightweight intent, reset
> /clear

> /crispy:design
# Design explores the codebase itself since no research exists
# Review 4-design.md, confirm, reset
> /clear

> /crispy:implement
# Implements directly from intent + design
```

### Direct Flow (intent → implement)

```bash
CRISPY_FEATURE=my-feature claude
> /crispy:intent Fix the race condition in the session refresh logic
# Confirm, reset
> /clear

> /crispy:implement
# Works directly from intent, implements in chunks with pauses
```

### Auto-advance Flow

```bash
CRISPY_FEATURE=my-feature claude
> /crispy:intent
# Full intent capture, confirm, reset
> /clear

> /crispy:design --autoadvance
# Automatically runs research-questions + research, then starts design
# Review 4-design.md, confirm, reset
> /clear

> /crispy:plan --autoadvance
# Automatically runs structure-outline, then starts planning
```

### Iterative Flow (intent → plan → implement → refine → repeat)

For work that benefits from tight feedback loops. Implement a first pass, review the result, refine the intent with what you learned, and re-plan.

```bash
# Round 1: Initial intent and plan
CRISPY_FEATURE=my-feature claude
> /crispy:intent Add user preferences API with dark mode toggle
# Confirm intent, reset
> /clear

> /crispy:plan
# No 4-design.md — plan surfaces design decisions, you collaborate
# Review 6-plan.md and phase docs, confirm
> /clear

> /crispy:implement
# Implements phases, review the result
> /clear

# Round 2: Refine after reviewing implementation
> /crispy:intent
# Existing intent detected — choose to edit it
# Add missed requirements or adjust scope based on what you learned
> /clear

> /crispy:plan
# Existing plan detected — choose to re-plan or edit
# Surfaces which prior phases are still valid
# Collaborate on new decisions, write updated plan
> /clear

> /crispy:implement
# Implements new/updated phases
```

Each `/clear` gives the next skill a fresh context window. A fresh agent reading a clean artifact follows instructions far better than a tired agent at turn 80.

**`CRISPY_FEATURE` persists within a session.** Once the feature is resolved (either from the env variable or by answering the prompt), a `SessionStart` hook automatically restores it after every `/clear`. You only need to set `CRISPY_FEATURE=my-feature` when launching `claude` — subsequent `/clear` resets within the same session don't require re-entering the feature name.

You can also use separate terminal sessions or `claude --resume` instead of `/clear` — the key is that each phase starts with a clean context.

---

## Flexible Workflow

Intent is the only hard gate. Every other phase adapts to what's available:

| Phase | Required | Adapts when missing |
|---|---|---|
| Intent | **Yes — always required** | N/A |
| Research Questions | No | Research derives questions from intent |
| Research | No | Design does its own codebase exploration |
| Design | No | Plan/Structure make decisions through research |
| Structure | No | Plan derives its own phase breakdown |
| Plan | No | Implement works directly from intent/design |

### `--autoadvance` Flag

Any phase accepts `--autoadvance` to automatically run missing upstream phases before proceeding:

```bash
/crispy:plan --autoadvance    # runs research-questions → research → design → structure → plan
/crispy:design --autoadvance  # runs research-questions → research → design
```

Each missing phase runs as a separate `claude -p` agent with `--permission-mode auto`. This is fast but means the model makes all intermediate decisions without your review.

**When auto-advance is fine:**
- Well-scoped work where defaults are likely correct
- You plan to review the final output carefully
- Speed matters more than precision in intermediate steps

**When you should run phases manually:**
- Complex features touching multiple systems
- Work where design decisions have significant trade-offs
- The cost of getting it wrong is high

---

## Why It Works

| Common failure | Crispy solution |
|---|---|
| Agent builds the wrong thing | `/crispy:intent` aligns on scope before anything else |
| Research is unfocused | `/crispy:research-questions` scopes exactly what to find |
| LLM mixes facts with implementation opinions | Research questions act as a middle layer — research sees *where to look* but not *what we plan to build*, so it documents what exists instead of advocating for the intent |
| Design decisions made silently | `/crispy:design` surfaces all decisions explicitly |
| Implementation drifts or improvises | `/crispy:implement` follows a plan or pauses for review between chunks |
| Long context degrades instruction-following | Each phase is a fresh window — the model reads a clean artifact, not 80 turns of conversation |
| Too much ceremony for simple work | Skip phases — each adapts to what's available |
