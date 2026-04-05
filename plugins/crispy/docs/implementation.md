# Implementation Details

## Task Metadata

When `/crispy-plan` is confirmed, it generates two things:

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

## Execution Strategies

The tasks are data — how you execute them is your choice:

| Strategy | How |
|---|---|
| **Sequential** | Run `/crispy-implement` repeatedly. Each invocation picks up the next ready phase, implements it, and stops. Ralph-loop style — fresh context per phase. |
| **Targeted** | Run `/crispy-implement phase-N` to execute a specific phase. Useful when you know which phase to work on. |
| **Multi-session** | Stop mid-feature, close the session, come back later. The manifest tracks which tasks are done. `/crispy-implement` picks up where you left off. |
| **Parallel** | For phases with no dependency on each other, run their task files in separate worktrees or sessions simultaneously. The manifest's dependency data tells you which phases are independent. |
| **External** | Copy a task file's contents into a Jira ticket, a Claude task, or any other orchestration system. The files are plain markdown referencing repo-relative paths — they work anywhere the repo is available. |

The implement skill itself stays simple: one phase per invocation, clean stops. Orchestration of parallel or external execution is up to you.

---

## Ralph Loop Integration

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
