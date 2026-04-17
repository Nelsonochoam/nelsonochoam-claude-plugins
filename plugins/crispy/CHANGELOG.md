# Changelog

## 1.5.2

### Research Questions — External Research Directives

The research-questions phase now explicitly supports directives for researching third-party frameworks, libraries, or external APIs when understanding them is a prerequisite for making sense of the codebase.

#### What changed

- **New item type: External research.** Step 2 now lists `External research` alongside questions, directives, and focus areas as a valid form. Use it when an external knowledge gap would block understanding the codebase (e.g. "Research how [framework X] handles [topic Y] — understand its API before diving into our integration code").
- **New guideline #6.** Important Guidelines now includes explicit permission and framing guidance for external research items.

## 1.5.1

### Intent — `CRISPY_FEATURE` Env Var Priority

The intent skill now respects the `CRISPY_FEATURE` environment variable as the highest-priority source for the feature name, before ticket IDs and intent title derivation. This allows external tooling or session hooks to pin the active feature without the skill overriding it.

#### What changed

- **Feature name priority order updated.** Intent now checks `CRISPY_FEATURE` first, then ticket ID, then kebab-case title.
- **`FEATURE` generic env var support.** Feature discovery now falls back to the generic `FEATURE` env var (shared cross-plugin convention) if `CRISPY_FEATURE` is not set.

## 1.5.0

### Skill Naming — Namespace Format

Skill names no longer carry the `crispy-` prefix. All skills are now invoked using the `crispy:` namespace format (e.g. `/crispy:intent`, `/crispy:research`, `/crispy:design`). This aligns with standard plugin naming conventions and keeps command names shorter.

#### What changed

- **Skill directories renamed.** `skills/crispy-intent` → `skills/intent`, and so on for all eight skills.
- **Skill `name` fields updated.** Each `SKILL.md` frontmatter now declares the unprefixed name (e.g. `name: intent`).
- **All command references updated.** Every "Recommended next" prompt, prerequisite check message, auto-advance script output, and doc example now uses the `/crispy:X` format.

## 1.4.3

### Bug Fixes

- **Auto-advance now correctly detects missing pipeline phases.** `auto-advance.sh` previously relied on `ok` from `check-prerequisites.sh`, which is `true` whenever intent exists — causing auto-advance to exit immediately without running any missing phases. The script now computes missing phases by comparing the pipeline order against the `available` artifact list, so phases like `research-questions` are correctly detected and run before the target phase.

## 1.4.2

### Changes

- **Numbered artifact filenames.** Phase output files now carry a numeric prefix matching their position in the workflow: `1-intent.md`, `2-research-questions.md`, `3-research.md`, `4-design.md`, `5-structure-outline.md`, `6-plan.md`. Numbers are fixed per phase — skipped phases leave gaps, which makes the workflow path visible at a glance.

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
