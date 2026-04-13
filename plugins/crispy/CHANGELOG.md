# Changelog

## 1.3.2

### Bug Fixes

- **Feature discovery reads session file.** `feature-discovery.md` now checks `/tmp/.crispy_session_${PPID}` before prompting the user. Skills triggered after a `/clear` (e.g. `/crispy-research`) will pick up the active feature from the session instead of asking for it again.

## 1.3.0

### Flexible Workflow — Intent as the Only Hard Gate

Crispy no longer enforces a strict 7-phase sequential pipeline. Intent is the only required phase — every other phase adapts to whatever artifacts are available.

#### What changed

- **Removed rigid prerequisite enforcement.** Phases no longer block when upstream artifacts are missing. Each phase works with what exists and fills gaps through its own codebase exploration.
- **Lightweight intent.** `/crispy-intent` now accepts anything from a single phrase to a full structured document. Users can confirm a quick restatement and skip the Q&A, or opt into the full flow.
- **`--autoadvance` flag.** Any phase accepts `--autoadvance` to automatically run missing upstream phases before proceeding (e.g., `/crispy-design --autoadvance` runs research-questions and research first). This is opt-in — it never triggers automatically.
- **Adaptive implement phase.** `/crispy-implement` adapts to what exists: follows plan and manifest when available, executes phase docs sequentially when there's a plan but no manifest, or works directly from intent and other available artifacts when no plan exists. Implementation references are progressively loaded based on the scenario.
- **Collaborative plan phase.** When no `design.md` exists, `/crispy-plan` surfaces design decision points and collaborates with the user to resolve them before writing the plan. This enables the RPI flow (intent → research → plan → implement) where the plan phase handles design decisions inline.
- **Iterative workflow support.** `/crispy-plan` detects existing plan artifacts and asks whether to re-plan from scratch or edit in place. When re-planning after intent refinement, it surfaces which prior implementation phases are still valid. This enables tight intent → plan → implement → refine → repeat cycles.
- **Simplified prerequisite script.** `check-prerequisites.sh` now only gates on intent and reports which artifacts are available — no more dependency chains between phases.
- **Better documentation.**
  - Documented why Research Questions exist (middle layer that keeps research objective by hiding intent)
  - Documented why Structure Outline exists (prevents horizontal layer splitting, ensures vertical slices)
  - Clarified that Design options are conversation starters, not a closed list
  - Added workflow examples: Full, RPI, Quick, Direct, Iterative, and Auto-advance flows
  - Added flexible workflow table showing how each phase adapts when upstream artifacts are missing

#### Common shortcuts

- **Full flow** (recommended): intent -> research-questions -> research -> design -> structure -> plan -> implement
- **RPI flow**: intent -> research -> plan -> implement
- **Quick**: intent -> design -> implement
- **Direct**: intent -> implement
- **Iterative**: intent -> plan -> implement -> refine intent -> re-plan -> implement -> ...
