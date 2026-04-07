# Research Agent Types

When decomposing research questions, assign each area to the appropriate agent type:

- **codebase-locator** — find where files, components, and entry points live
- **codebase-analyzer** — trace how specific code works, document data flow and component interactions with `file:line` references
- **codebase-pattern-finder** — find existing examples of a pattern in the codebase
- **web-researcher** — search the web for external documentation (framework docs, library APIs, protocol specs) that the codebase depends on but doesn't explain internally. **Use only when the codebase alone cannot answer the question** — e.g., understanding an undocumented third-party API, a framework convention, or a standard the code implements.

Each agent is a documentarian. They describe what IS, not what should be.
