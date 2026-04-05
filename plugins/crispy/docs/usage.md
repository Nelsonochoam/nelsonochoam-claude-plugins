# Usage Guide

## The Seven Phases Detailed

### 1. Intent — Define what you're building

Captures scope, motivation, acceptance criteria, and constraints before any code is touched. Every subsequent phase reads this as the source of truth.

**Output:** `intent.md`

### 2. Research Questions — Ask before looking

Reads `intent.md` and surfaces the questions a developer would need answered before starting work — without scanning the codebase yet. Each question has a `Hint:` field below it. Fill in hints for any question where you already know where to look (a file, flag, module, etc.), and research agents will focus on what you point them toward.

**Reads:** `intent.md` | **Output:** `research-questions.md`

### 3. Research — Answer those questions

Spawns parallel sub-agents to explore the codebase and answer the research questions factually. Documents what exists — no opinions, no design. Intentionally does NOT read `intent.md` so findings stay objective.

**Reads:** `research-questions.md` | **Output:** `research.md`

### 4. Design — Decide the approach

Surfaces open design decisions as options with recommendations, gets your decisions, then writes a design document.

**Reads:** `intent.md`, `research-questions.md`, `research.md` | **Output:** `design.md`

### 5. Structure — Break it into phases

Breaks the work into vertical slices — each phase delivers end-to-end behavior with its own tests and verification steps.

**Reads:** `intent.md`, `research.md`, `design.md` | **Output:** `structure-outline.md`

### 6. Plan — Write the mechanical plan

Produces a precise, step-by-step implementation plan with exact file paths, function signatures, and success criteria. Once confirmed, generates implementation tasks in `manifest.json` — self-contained prompts with dependency metadata for each phase.

**Reads:** `intent.md`, `research.md`, `design.md`, `structure-outline.md` | **Output:** `plan.md` + `tasks/phase-N.md`

### 7. Implement — Execute the plan

Implements one phase at a time, then stops. Reads `manifest.json` to find the next eligible phase, verifies with automated checks, and updates task status. Supports targeted execution: `/implement phase-N`.

**Reads:** all prior artifacts + `plan.md` + `manifest.json` + `tasks/phase-N.md`

---

## Typical Workflow

The full seven-phase flow with fresh context between each:

```bash
# Session 1: Capture intent → intent.md
CRISPY_FEATURE=my-feature claude
> /crispy-intent
# Review intent.md, confirm, then reset
> /clear

# Session 2: Surface research questions → research-questions.md
> /crispy-research-questions
# Review, fill in Hint: fields if you know where to look, confirm, reset
> /clear

# Session 3: Answer research questions → research.md
> /crispy-research
# Review research.md, confirm, reset
> /clear

# Session 4: Resolve design decisions → design.md
> /crispy-design
# Review design.md, confirm, reset
> /clear

# Session 5: Break into vertical phases → structure-outline.md
> /crispy-structure
# Review structure-outline.md, confirm, reset
> /clear

# Session 6: Write the detailed plan → plan.md + tasks/
> /crispy-plan
# Review plan.md, confirm → tasks generated automatically
> /clear

# Session 7+: Implement one phase at a time
> /crispy-implement
# Implements next ready phase, stops. Review, then reset.
> /clear
> /crispy-implement
# Next phase...
```

Each `/clear` gives the next skill a fresh context window. A fresh agent reading a clean artifact follows instructions far better than a tired agent at turn 80.

You can also use separate terminal sessions or `claude --resume` instead of `/clear` — the key is that each phase starts with a clean context.

---

## Quick Plan Workflow

For cases where you already know what to build — a small UI tweak, a well-scoped bug fix, a one-off change:

```bash
# Session 1: Capture intent → intent.md
CRISPY_FEATURE=my-feature claude
> /crispy-intent
> /clear

# Session 2: Write the plan directly (skips research, design, structure)
> /crispy-plan
# Skill does its own codebase research pass, surfaces all assumed decisions,
# and writes plan.md. Review assumptions before confirming.
> /clear

# Session 3+: Implement one phase at a time
> /crispy-implement
> /clear
> /crispy-implement
```

`/crispy-plan` handles missing intermediate artifacts — when called with only `intent.md`, it does its own research pass and surfaces all design decisions and phase breakdown as explicit assumptions. Review those in `plan.md` before confirming. If any are wrong, fix them before running `/implement`.

**Trade-off:** Faster start, but you're compressing research, design, and structure into a single step. If the plan comes back with too many unknowns, consider running the full flow or a subset (e.g., `/crispy-research` → `/crispy-plan`). See [Flexible Entry Points](#flexible-entry-points) below.

---

## Flexible Entry Points

You don't have to start at `/crispy-intent`. Start wherever you have context:

| If you have... | Start at |
|---|---|
| Nothing yet | `/crispy-intent` |
| A rough description | `/crispy-intent` or pass it to `/crispy-research-questions` |
| An intent doc already written | `/crispy-research-questions` |
| Intent + research done | `/crispy-design` |
| Intent + enough context to skip research | `/crispy-plan` |
| A confirmed plan | `/crispy-implement` |

When prior phases are missing, skills warn you and proceed with what's available — making explicit any assumptions they have to fill in. The more complete your prior phase artifacts, the less the agent has to guess.

**Best results come from the full flow.** Skipping phases is a trade-off: faster start, more assumptions, higher chance of needing to backtrack.

---

## Skipping Phases

You don't have to run every phase. Skills adapt and flag any assumptions they have to make.

---

## Why It Works

| Common failure | Crispy solution |
|---|---|
| Agent builds the wrong thing | `/crispy-intent` aligns on scope before anything else |
| Research is unfocused | `/crispy-research-questions` scopes exactly what to find |
| Research is biased toward the solution | Research gets questions only — not the intent — so findings stay factual |
| Design decisions made silently | `/crispy-design` surfaces all decisions explicitly before any phases are defined |
| Plan skips structural steps | `/crispy-structure` forces a phased breakdown first |
| Implementation drifts or improvises | `/crispy-implement` follows a mechanical plan; deviations surface immediately |
| Long context degrades instruction-following | Each phase is a fresh window — the model reads a clean artifact, not 80 turns of conversation |
