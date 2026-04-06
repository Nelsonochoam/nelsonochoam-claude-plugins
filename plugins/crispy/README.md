# Crispy — Structured Agentic Engineering

![crispy hero](assets/crispy.png)

**crispy** is a framework for building software with AI agents. It breaks complex tasks into discrete phases — alignment → research → design → planning → implementation — ensuring nothing gets quietly skipped.

> "If implementation feels creative, something upstream is missing."

Inspired by [QRSPI methodology](https://www.youtube.com/watch?v=5MWl3eRXVQk).

## Why Crispy?

Agents without proper context management can build the wrong thing, misread the codebase or drift mid-implementation. **Long conversations degrade instruction-following** — models stop listening to their instructions and start improvising.

Crispy tries to solve this by doing "intentional compaction" steering the context in the right direction. Each skill reads only what it needs, does its focused job, writes output to a file. The next phase starts clean. No sprawl, no drift.

**Core principle:** *Context is the enemy of focus. Each phase gets exactly what it needs — and nothing more.*

## Quick Start

**1. Install**

```bash
/plugin install crispy@nelsonochoam
```

**2. Configure (optional, one time)**

```bash
/crispy-init
```

Configures where artifacts are stored. Default is `~/.crispy/`, but you can choose any path (e.g., inside an Obsidian vault, Logseq graph, or notes directory). See [Storage & Integration](./docs/markdown-readers.md) for app-specific paths.

**3. Set your feature name**

```bash
CRISPY_FEATURE=my-feature claude
```

**4. Run skills in order**

Each phase produces a file that feeds into the next:

```
/crispy-intent → /crispy-research-questions → /crispy-research → 
/crispy-design → /crispy-structure → /crispy-plan → /crispy-implement
```

Start a fresh session between phases (use `/clear` or `claude --resume`).

## When to Use

**Use crispy when:**
- Work is complex or touches multiple systems
- You need to steer AI carefully and avoid shallow output
- The feature is large enough that a single context window would degrade quality
- You want a reviewable record of decisions before code is written

**Skip crispy when:**
- The task is straightforward and well-defined
- Claude's built-in `/plan` mode is enough
- You're fixing a quick bug or making a small change

Crispy is for deep work — use it when the cost of getting it wrong is high.

## The Seven Phases

1. **Intent** — Define scope, acceptance criteria, and constraints
2. **Research Questions** — Ask what you need to know before exploring the codebase
3. **Research** — Answer those questions by exploring the codebase
4. **Design** — Decide on architecture and approach
5. **Structure** — Break work into vertical phases with dependencies
6. **Plan** — Write the mechanical implementation plan
7. **Implement** — Execute one phase at a time

Each phase reads prior artifacts and writes its output. See [Usage Guide](./docs/usage.md) for detailed workflows and examples.

## Documentation

- **[Usage Guide](./docs/usage.md)** — Detailed workflow examples, flexible entry points, when to skip phases
- **[Artifact Storage](./docs/artifacts.md)** — How files are organized, choosing storage locations, write-first review pattern
- **[Markdown Reader Integration](./docs/markdown-readers.md)** — Store in Obsidian, Logseq, Dendron, or any note app
- **[Implementation Details](./docs/implementation.md)** — Task metadata, execution strategies, Ralph loop integration
- **[Troubleshooting](./docs/README.md#troubleshooting)** — Common issues and solutions

## License

MIT — See [LICENSE](./LICENSE) for details.

## References

- [Long Context Isn't the Answer](https://www.humanlayer.dev/blog/long-context-isnt-the-answer)
- [The Necessary Evolution of RPI](https://betterquestions.ai/the-necessary-evolution-of-research-plan-implement-as-an-agentic-practice-in-2026/)
- [Advanced Context Engineering](https://github.com/humanlayer/advanced-context-engineering-for-coding-agents/blob/main/ace-fca.md)
- [Ralph loops — ruthless context resets](https://linearb.io/blog/dex-horthy-humanlayer-rpi-methodology-ralph-loop)
- [HumanLayer](https://humanlayer.dev)
