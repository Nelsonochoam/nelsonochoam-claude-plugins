# Crispy — Structured Agentic Engineering

![crispy hero](assets/crispy.png)


**crispy** (QRDSPI) is a framework for building software with AI agents evolving from RPI (Research -> Plan -> Implement). It breaks complex coding tasks into discrete phases so nothing gets quietly skipped — alignment before research, research before design, design before planning, planning before code.

> "If implementation feels creative, something upstream is missing."

Inspired by:
[From RPI to QRSPI by Dexter Horthy](https://www.youtube.com/watch?v=5MWl3eRXVQk)

## The Problem It Solves

Agents that jump straight to code routinely make avoidable mistakes: building the wrong thing, misreading the codebase, or producing a plan full of guesses. crispy forces explicit alignment gates before major work begins.

But there's a deeper problem: **long context windows degrade instruction-following**. As a conversation grows, models pay progressively less attention to their instructions — they start drifting, improvising, and losing track of constraints. Packing research, design, planning, and implementation into a single context is a recipe for an agent that confidently does the wrong thing by the end.

crispy addresses this by treating each phase as a **fresh context window**. Each skill starts clean, reads only the artifacts it needs, does its focused job, and writes its output to a file. The next phase picks up that file — not the sprawling conversation that produced it. This is the "Ralph loop" pattern: ruthless context resets as a reliability technique, not a limitation.

> Context is the enemy of focus. Each phase gets exactly the context it needs — and nothing more.

See: [Long Context Isn't the Answer](https://www.humanlayer.dev/blog/long-context-isnt-the-answer)

## How to Use

The core idea: **one phase per session, then reset**. Each skill reads artifacts from disk, does its job, writes output to a file, and you start fresh. No long conversations, no context drift.

### Setup

**Optional: run `/crispy-init` once per machine** to configure where crispy stores artifacts and optionally link to an Obsidian vault. Without it, crispy defaults to `~/.crispy/`. Run it only when you want to change the storage location — it is never called automatically.

Set your feature name as an environment variable so every skill knows which feature folder to use:

```bash
CRISPY_FEATURE=my-feature claude
```

This tells all crispy skills to use `.crispy/my-feature/` without prompting. You can also set it mid-session with `export CRISPY_FEATURE=my-feature`.

If `CRISPY_FEATURE` is not set, crispy will ask you for a feature name the first time a skill needs one and track it for the rest of the session. But that tracking only lasts for the current session — **if you terminate the session and want to continue the same feature later, always start with `CRISPY_FEATURE=<name> claude`** so every skill resolves to the right folder without prompting.

### The Phases

```
/intent → /research-questions → /research → /design → /structure → /create-plan → /implement
```

Each phase produces a file that becomes the input for the next. The **artifacts are the handoff** — not the conversation. Start a fresh session for each phase; the skill reads prior artifacts cold and works from those.

#### `/intent` — Define what you're building

Captures scope, motivation, acceptance criteria, and constraints before any code is touched. Every subsequent phase reads this as the source of truth.

**Output:** `intent.md`

#### `/research-questions` — Ask before looking

Reads `intent.md` and surfaces the questions a developer would need answered before starting work — without scanning the codebase yet. Each question is written with a `Hint:` field below it. If you already have partial knowledge about a question — a file you suspect is relevant, a flag you remember seeing, a module you know is involved — fill in that hint before running `/research`. The research agents will use filled hints to focus their investigation on what you point them toward, while still answering the full question.

**Reads:** `intent.md` | **Output:** `research-questions.md`

#### `/research` — Answer those questions

Spawns parallel sub-agents to explore the codebase and answer the research questions factually. Documents what exists — no opinions, no design. Intentionally does NOT read `intent.md` so findings stay objective.

**Reads:** `research-questions.md` | **Output:** `research.md`

#### `/design` — Decide the approach

Surfaces open design decisions as options with recommendations, gets your decisions, then writes a design document.

**Reads:** `intent.md`, `research-questions.md`, `research.md` | **Output:** `design.md`

#### `/structure` — Break it into phases

Breaks the work into vertical slices — each phase delivers end-to-end behavior with its own tests and verification steps.

**Reads:** `intent.md`, `research.md`, `design.md` | **Output:** `structure-outline.md`

#### `/create-plan` — Write the mechanical plan

Produces a precise, step-by-step implementation plan with exact file paths, function signatures, and success criteria. Once confirmed, generates implementation tasks in `manifest.json` — self-contained prompts with dependency metadata for each phase.

**Reads:** `intent.md`, `research.md`, `design.md`, `structure-outline.md` | **Output:** `plan.md` + `tasks/phase-N.md`

#### `/implement` — Execute the plan

Implements one phase at a time, then stops. Reads `manifest.json` to find the next eligible phase, verifies with automated checks, and updates task status. Supports targeted execution: `/implement phase-N`.

**Reads:** all prior artifacts + `plan.md` + `manifest.json` + `tasks/phase-N.md`

### Typical Workflow

```bash
# Session 1: Capture intent — scope, acceptance criteria, constraints → intent.md
CRISPY_FEATURE=my-feature claude
> /intent
# Review intent.md, confirm, then reset
> /clear

# Session 2: Surface what needs to be understood before touching the codebase → research-questions.md
> /research-questions
# Review research-questions.md — fill in Hint: fields for any question where you
# already know where to look (a file, flag, module, etc.). Then confirm and reset.
> /clear

# Session 3: Answer the research questions by exploring the codebase → research.md
> /research
# Review research.md, confirm, reset
> /clear

# Session 4: Resolve design decisions → design.md
> /design
# Review design.md, confirm, reset
> /clear

# Session 5: Break the work into vertical phases → structure-outline.md
> /structure
# Review structure-outline.md, confirm, reset
> /clear

# Session 6: Write the detailed implementation plan → plan.md + tasks/
> /create-plan
# Review plan.md, confirm → tasks generated automatically
> /clear

# Session 7+: Implement one phase at a time
> /implement
# Implements next ready phase, stops. Review, then reset.
> /clear
> /implement
# Next phase...
```

Each `/clear` gives the next skill a fresh context window. A fresh agent reading a clean artifact follows instructions far better than a tired agent at turn 80.

You can also use separate terminal sessions or `claude --resume` instead of `/clear` — the key is that each phase starts with a clean context.

### Quick Plan Workflow

For cases where you already know what to build — a small UI tweak, a well-scoped bug fix, a one-off change:

```bash
# Session 1: Capture intent → intent.md
CRISPY_FEATURE=my-feature claude
> /intent
> /clear

# Session 2: Write the plan directly (skips research, design, structure)
> /create-plan
# Skill does its own codebase research pass, surfaces all assumed decisions,
# and writes plan.md. Review assumptions before confirming.
> /clear

# Session 3+: Implement one phase at a time
> /implement
> /clear
> /implement
```

`/create-plan` handles missing intermediate artifacts — when called with only `intent.md`, it does its own research pass and surfaces all design decisions and phase breakdown as explicit assumptions. Review those in `plan.md` before confirming. If any are wrong, fix them before running `/implement`.

**Trade-off:** Faster start, but you're compressing research, design, and structure into a single step. If the plan comes back with too many unknowns, consider running the full flow or a subset (e.g., `/research` → `/create-plan`). See [Flexible Entry Points](#flexible-entry-points).

### Skipping Phases

You don't have to run every phase. Skills adapt and flag any assumptions they have to make. See [Flexible Entry Points](#flexible-entry-points) below.

## When to Use (and When Not To)

Crispy is not for everything. It adds structure and overhead — that's the point for complex work, but overkill for simple tasks.

**Use crispy when:**
- The work is complex, touches multiple systems, or requires architectural decisions
- You need to steer the AI carefully to avoid slop — generic, shallow, or drifted output
- The feature is large enough that a single context window would degrade quality
- You want a reviewable paper trail of decisions before code is written

**Don't use crispy when:**
- The task is straightforward — a well-defined ticket with clear direction is enough context for Claude to work from directly
- Claude's built-in plan mode (`/plan`) covers your needs — for medium-complexity work, a quick plan + implement cycle works fine
- You're fixing a bug, writing a test, or making a small change — just do it

The full QRDSPI flow is a tool for deep work. Use it when the cost of getting it wrong is high. For everything else, point Claude at a spec and go.


## How Artifacts Are Stored

All files go in `<repo-root>/.crispy/<feature-name>/`:

```
.crispy/
  my-feature/
    manifest.json          ← phase status + task metadata
    intent.md
    research-questions.md
    research.md
    design.md
    structure-outline.md
    plan.md
    tasks/                 ← generated by /create-plan on confirmation
      phase-1.md           ← self-contained task prompt
      phase-2.md
      phase-3.md
```

The `manifest.json` tracks which phases are done and contains task metadata (status, dependencies, file paths). Each skill reads it to know where you are and updates it when a phase is confirmed. The `tasks/` directory contains one markdown file per implementation phase — each is a standalone prompt an agent can execute.

---

## Write-First Review Pattern

Every skill writes its output to the `.crispy/<feature>/` file **before** asking for your review. You review the file directly (open it in your editor), request changes, and the skill edits the file in place. Once you confirm, the manifest is updated and you move to the next phase.

This keeps the conversation clean — you're reviewing a structured document, not a wall of text.

---

## Implementation Tasks

When `/create-plan` is confirmed, it generates two things:

1. **Task files** in `.crispy/<feature>/tasks/` — one markdown file per phase (`phase-1.md`, `phase-2.md`, etc.). Each is a self-contained prompt that tells an agent exactly what to read, implement, and verify.
2. **Task metadata** in `manifest.json` — status, dependencies, and a file pointer for each task.

```json
{
  "tasks": {
    "phase-1": {
      "name": "Phase 1: Add status field to Questionnaire model",
      "status": "pending",
      "dependencies": [],
      "file": ".crispy/my-feature/tasks/phase-1.md"
    },
    "phase-2": {
      "name": "Phase 2: API endpoints for status filtering",
      "status": "pending",
      "dependencies": ["phase-1"],
      "file": ".crispy/my-feature/tasks/phase-2.md"
    }
  }
}
```

The task files are plain markdown — easy to read, edit, copy to a Jira ticket, or pass as an `@file` reference. The `dependencies` array declares which tasks must be `"done"` before this task can start — derived from the structure outline's dependency chart.

### Execution Strategies

The tasks are data — how you execute them is your choice:

| Strategy | How |
|---|---|
| **Sequential** | Run `/implement` repeatedly. Each invocation picks up the next ready phase, implements it, and stops. Ralph-loop style — fresh context per phase. |
| **Targeted** | Run `/implement phase-N` to execute a specific phase. Useful when you know which phase to work on. |
| **Multi-session** | Stop mid-feature, close the session, come back later. The manifest tracks which tasks are done. `/implement` picks up where you left off. |
| **Parallel** | For phases with no dependency on each other, run their task files in separate worktrees or sessions simultaneously. The manifest's dependency data tells you which phases are independent. |
| **External** | Copy a task file's contents into a Jira ticket, a Claude task, or any other orchestration system. The files are plain markdown referencing repo-relative paths — they work anywhere the repo is available. |

The implement skill itself stays simple: one phase per invocation, clean stops. Orchestration of parallel or external execution is up to you.

---

### Using with Ralph Loop

The [ralph-loop](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop) plugin automates sequential execution by intercepting session exit and refeeding a prompt. Because crispy tasks track their own status in `manifest.json`, ralph-loop can drive the full implementation without manual intervention between phases.

**How it works:** Ralph-loop refeeds the same prompt each iteration. Each iteration sees the updated `manifest.json` (task statuses set to `"done"` by the previous iteration), so the next ready task is automatically picked up. When all tasks are done, the loop terminates.

**Prompt to use:**

```
/ralph-loop "Read .crispy/<feature>/manifest.json. Find the first task where status is 'pending' and all dependencies have status 'done'. If no such task exists and all tasks are 'done', output <promise>ALL TASKS COMPLETE</promise>. Otherwise, read the task's file (the 'file' field) and follow its instructions exactly — it contains everything needed to implement, verify, and update status for that phase."
```

Replace `<feature>` with your feature folder name, or use `$CRISPY_FEATURE` if set.

The prompt is intentionally minimal — each task file already contains full instructions for reading artifacts, implementing the phase, running verification, and updating manifest status. The ralph-loop prompt only handles orchestration: pick next task, delegate to task file, signal completion.

**What each iteration does:**
1. Reads `manifest.json` → finds next eligible task (pending, dependencies met)
2. Reads `tasks/phase-N.md` → follows its instructions (read artifacts, implement, verify, update status)
3. Exits → ralph-loop intercepts → refeeds prompt → next iteration sees updated manifest
4. When all tasks are `"done"` → outputs `<promise>` → loop terminates

**When to prefer ralph-loop over manual `/implement`:**
- The plan has many small, straightforward phases
- You trust the plan enough to run without pausing for manual verification between phases
- You want unattended execution

**When to prefer manual `/implement`:**
- Phases are complex and benefit from human review between them
- You want to verify each phase manually before continuing
- The plan has phases you might want to run in parallel instead of sequentially

---

## Flexible Entry Points

You don't have to start at `/intent`. Start wherever you have context:

| If you have... | Start at |
|---|---|
| Nothing yet | `/intent` |
| A rough description | `/intent` or pass it directly to `/research-questions` |
| An intent doc already written | `/research-questions` |
| Intent + research done | `/design` |
| Intent + enough context to skip research | `/create-plan` |
| A confirmed plan | `/implement` |

When prior phases are missing, skills warn you and proceed with what's available — making explicit any assumptions they have to fill in. The more complete your prior phase artifacts, the less the agent has to guess.

**Best results come from the full flow.** Skipping phases is a trade-off: faster start, more assumptions, higher chance of needing to backtrack.

## Why It Works

| Common failure | crispy solution |
|---|---|
| Agent builds the wrong thing | `/intent` aligns on scope before anything else |
| Research is unfocused | `/research-questions` scopes exactly what to find |
| Research is biased toward the solution | Research gets questions only — not the intent — so findings stay factual |
| Design decisions made silently | `/design` surfaces all decisions explicitly before any phases are defined |
| Plan skips structural steps | `/structure` forces a phased breakdown first |
| Implementation drifts or improvises | `/implement` follows a mechanical plan; deviations surface immediately |
| Long context degrades instruction-following | Each phase is a fresh window — the model reads a clean artifact, not 80 turns of conversation |

---

## References

- [Long Context Isn't the Answer](https://www.humanlayer.dev/blog/long-context-isnt-the-answer)
- [The Necessary Evolution of "Research, Plan, Implement"](https://betterquestions.ai/the-necessary-evolution-of-research-plan-implement-as-an-agentic-practice-in-2026/)
- [Advanced Context Engineering for Coding Agents](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)
- [Ralph loops — ruthless context resets](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop)
- [HumanLayer](https://humanlayer.dev)
