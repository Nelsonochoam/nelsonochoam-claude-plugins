# Planning With Design Document

A `4-design.md` exists — all design decisions are already resolved. Your job is to translate those decisions into a mechanical plan.

## Step 1: Load All Context

Read whatever exists, in this order:
1. The Intent Document or user's request arguments (acceptance criteria, scope, what we're not doing)
2. The Design Document (resolved design questions, patterns to follow)
3. The Structure Outline Document (phase names, phase goals, key finding, open questions)
4. The Research Document (exact file paths, types, existing code patterns, test locations)

**Read all files completely** — no limit or offset parameters.

After reading, extract and hold in mind (skip items whose source doc doesn't exist):
- **Phases**: Take the phase list verbatim from the structure outline. Do not add, remove, or reorder phases without flagging it first. If no structure outline exists, derive phases from the design or intent.
- **Resolved decisions**: From the design doc — every resolved question is a closed decision that must be reflected in the plan as-is. Do not re-open or substitute alternatives.
- **Patterns**: From the design doc's "Patterns to follow" section — each step should mirror these patterns, not invent new ones.
- **File references**: From the research doc — use these exact paths and line numbers in each step entry. If no research doc exists, resolve all file paths through direct codebase lookup before writing the plan.
- **Out of scope**: From the intent doc's "What we're NOT doing" — anything listed there must not appear in the plan.

## Step 1b: Scope Verification

Per-phase file-level research (exact function signatures, prop types, import lists, test patterns, data shapes) is delegated to each phase's subagent — do not do it here.

Only do a narrow targeted lookup here if reading the artifacts leaves a phase's scope ambiguous at a structural level (e.g., it's unclear which subsystem is involved, or the structure outline references a file that doesn't appear in the research doc). Resolve the ambiguity, then proceed.
