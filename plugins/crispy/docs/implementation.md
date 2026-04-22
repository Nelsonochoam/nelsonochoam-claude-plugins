# Implementation Details

## Phase Documents and Metadata

When `/crispy:plan` is confirmed, it generates:

1. **A master plan** (`6-plan.md`) — a lightweight index with the overview, dependency graph, phase summary table, and global success criteria. No implementation details live here.
2. **Phase docs** in `.crispy/<feature>/phases/` — one markdown file per phase (`phase-1.md`, `phase-2.md`, etc.). Each is a self-sufficient document containing all implementation details: exact file paths, code changes, design decisions, and success criteria. An agent reads only this file to implement the phase.
3. **Implementation metadata** in `manifest.json` — status, dependencies, and a file pointer for each phase.

```json
{
  "implementation": {
    "phase-1": {
      "name": "Phase 1: Add status field to the Order model",
      "status": "pending",
      "dependencies": [],
      "file": ".crispy/my-feature/phases/phase-1.md"
    },
    "phase-2": {
      "name": "Phase 2: API endpoints for status filtering",
      "status": "pending",
      "dependencies": ["phase-1"],
      "file": ".crispy/my-feature/phases/phase-2.md"
    }
  }
}
```

The phase docs are plain markdown — easy to read, edit, copy to a Jira ticket, or pass as an `@file` reference. The `dependencies` array declares which phases must be `"done"` before this phase can start — derived from the structure outline's dependency chart.

## Execution Strategies

The phase docs are data — how you execute them is your choice:

| Strategy | How |
|---|---|
| **Sequential** | Run `/crispy:implement` repeatedly. Each invocation uses `next-phase.sh` to pick up the next ready phase, implements it, and stops. Ralph-loop style — fresh context per phase. |
| **Targeted** | Run `/crispy:implement phase-N` to execute a specific phase. Useful when you know which phase to work on. |
| **Multi-session** | Stop mid-feature, close the session, come back later. The manifest tracks which phases are done. `/crispy:implement` picks up where you left off. |
| **Parallel** | For phases with no dependency on each other, run their phase docs in separate worktrees or sessions simultaneously. The manifest's dependency data tells you which phases are independent. |
| **External** | Copy a phase doc's contents into a Jira ticket, a Claude task, or any other orchestration system. The files are plain markdown referencing repo-relative paths — they work anywhere the repo is available. |

The implement skill itself stays simple: one phase per invocation, clean stops. Orchestration of parallel or external execution is up to you.

### Finding the Next Phase

Use the `next-phase.sh` script to deterministically find the next workable phase:

```bash
NEXT=$(bash scripts/next-phase.sh "$FEATURE_PATH")
```

Returns JSON with `found`, `id`, `name`, `file`, `reason`, and `blocked_by` fields. When `found` is `false`, `reason` tells you why:
- `"all_done"` — every phase has `status: "done"`
- `"blocked"` — all pending phases have unmet dependencies; `blocked_by` lists the blocking phase IDs
- `"no_implementation_key"` — `manifest.json` exists but has no `implementation` section (plan not yet generated)
- `"no_manifest"` — `manifest.json` does not exist yet

---

## Auto-Advance

When you invoke a skill and prior phases are missing, crispy offers to **auto-advance** through them. This uses `auto-advance.sh`, which runs each missing phase via `claude -p` (non-interactive mode) with the crispy plugin loaded.

**How it works:**

1. `check-prerequisites.sh` reads `manifest.json` and identifies which phases are missing
2. The skill presents the missing phases and asks if you want to auto-advance
3. If you choose auto-advance, `auto-advance.sh` runs each missing phase in pipeline order:
   - Sets `CRISPY_FEATURE` and invokes `claude -p --plugin-dir ... --permission-mode auto --model opus`
   - Each phase runs as a separate agent with full tool access
   - The agent writes the artifact and updates the manifest
4. After all phases complete, the original skill continues with its normal workflow

**Important:** Auto-advance makes decisions on your behalf. The model chooses research focus areas, makes design decisions, and structures the work without your review. This is faster but produces lower quality results than running each phase manually.

**Scripts involved:**
- `scripts/check-prerequisites.sh` — deterministic prerequisite check, outputs JSON
- `scripts/auto-advance.sh` — orchestrates `claude -p` invocations for missing phases

---

## Ralph Loop Integration

The [ralph-loop](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop) plugin automates sequential execution by intercepting session exit and refeeding a prompt. Because crispy phases track their own status in `manifest.json`, ralph-loop can drive the full implementation without manual intervention between phases.

**How it works:** Ralph-loop refeeds the same prompt each iteration. Each iteration sees the updated `manifest.json` (phase statuses set to `"done"` by the previous iteration), so the next ready phase is automatically picked up. When all phases are done, the loop terminates.

**Prompt to use:**

```
/ralph-loop "Run bash scripts/next-phase.sh .crispy/<feature> to find the next phase. If the result shows found:false and reason:all_done, output <promise>ALL TASKS COMPLETE</promise>. Otherwise, read the phase doc at the file path returned and follow its instructions exactly — it is self-sufficient with everything needed to implement, verify, and update status for that phase."
```

Replace `<feature>` with your feature folder name, or use `$CRISPY_FEATURE` if set.

The prompt is intentionally minimal — each phase doc is self-sufficient with all implementation details, references to design/research artifacts, and verification instructions. The ralph-loop prompt only handles orchestration: find next phase, delegate to phase doc, signal completion.

**What each iteration does:**
1. Runs `next-phase.sh` → finds next eligible phase (pending, dependencies met)
2. Reads `phases/phase-N.md` → follows its instructions (implement, verify, update manifest status)
3. Exits → ralph-loop intercepts → refeeds prompt → next iteration sees updated manifest
4. When all phases are `"done"` → outputs `<promise>` → loop terminates

**When to prefer ralph-loop over manual `/crispy:implement`:**
- The plan has many small, straightforward phases
- You trust the plan enough to run without pausing for manual verification between phases
- You want unattended execution

**When to prefer manual `/crispy:implement`:**
- Phases are complex and benefit from human review between them
- You want to verify each phase manually before continuing
- The plan has phases you might want to run in parallel instead of sequentially
