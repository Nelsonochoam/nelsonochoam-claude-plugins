# Usage Guide

## The Seven Phases Detailed

### 1. Intent — Define what you're building

Captures scope, motivation, acceptance criteria, and constraints before any code is touched. Every subsequent phase reads this as the source of truth.

**Output:** `intent.md`

### 2. Research Questions — Ask before looking

Reads `intent.md` and surfaces the questions a developer would need answered before starting work — without scanning the codebase yet.

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

Produces a master plan index and self-sufficient phase docs. The plan (`plan.md`) contains the overview, dependency graph, and links to phase docs. Each phase doc (`phases/phase-N.md`) contains all implementation details: exact file paths, code changes, design decisions, and success criteria. Generated in a single pass.

**Reads:** `intent.md`, `research.md`, `design.md`, `structure-outline.md` | **Output:** `plan.md` + `phases/phase-N.md`

### 7. Implement — Execute the plan

Implements one phase at a time, then stops. Uses `next-phase.sh` to find the next eligible phase from `manifest.json`, reads the phase doc (which is self-sufficient), verifies with automated checks, and updates status. Supports targeted execution: `/crispy-implement phase-N`.

**Reads:** `manifest.json` + `phases/phase-N.md`

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
# Review, confirm, reset
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

# Session 6: Write the detailed plan → plan.md + phases/
> /crispy-plan
# Review plan.md and phase docs, confirm
> /clear

# Session 7+: Implement one phase at a time
> /crispy-implement
# Implements next ready phase, stops. Review, then reset.
> /clear
> /crispy-implement
# Next phase...
```

Each `/clear` gives the next skill a fresh context window. A fresh agent reading a clean artifact follows instructions far better than a tired agent at turn 80.

**`CRISPY_FEATURE` persists within a session.** Once the feature is resolved (either from the env variable or by answering the prompt), a `SessionStart` hook automatically restores it after every `/clear`. You only need to set `CRISPY_FEATURE=my-feature` when launching `claude` — subsequent `/clear` resets within the same session don't require re-entering the feature name.

You can also use separate terminal sessions or `claude --resume` instead of `/clear` — the key is that each phase starts with a clean context.

---

## Prerequisite Enforcement

Every phase requires all prior phases to be complete. The pipeline is strict:

```
intent → research-questions → research → design → structure → plan → implement
```

When you invoke a skill and prior phases are missing, the skill will:

1. **Hard-stop if intent is missing** — intent always requires human input and cannot be skipped or auto-advanced. You must run `/crispy-intent` first.
2. **Offer auto-advance for other missing phases** — if intent is done but intermediate phases are missing, you'll be offered two choices:
   - **Auto-advance** — runs each missing phase automatically via `claude -p` (no human review between them)
   - **Stop** — run the missing phases manually with their slash commands

This means you can jump to any phase — e.g., run `/crispy-plan` right after intent — and auto-advance will fill in the gaps. But there's a trade-off.

### Auto-Advance Trade-offs

Auto-advance uses `claude -p` to run each missing phase as a separate non-interactive agent. This is fast but means **the model makes all decisions for you** — research focus areas, design choices, structure breakdown. You won't review intermediate artifacts before they feed into the next phase.

**When auto-advance is fine:**
- Well-scoped work where defaults are likely correct
- You plan to review the final plan carefully before implementing
- Speed matters more than precision in intermediate steps

**When you should run phases manually:**
- Complex features touching multiple systems
- Work where design decisions have significant trade-offs
- The cost of getting it wrong is high

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
