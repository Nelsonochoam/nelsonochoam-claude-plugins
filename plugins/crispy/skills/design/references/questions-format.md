# Design Questions Format

Present the full set of questions at once. Each question should make the decision, the tradeoffs, and the recommendation clear enough that a reader can evaluate independently.

```markdown
## Design Questions

**1. <Decision Title>**

<Why this decision matters — what depends on it, what changes based on the answer. 1-2 sentences of context.>

- **Option A**: <description>
  ```ts
  // code showing what this looks like in practice
  ```
  - **Pros**: <what you gain — be specific>
  - **Cons**: <what you lose or accept — be specific>

- **Option B**: <description>
  ```ts
  // code showing what this looks like in practice
  ```
  - **Pros**: <what you gain>
  - **Cons**: <what you lose or accept>

- **Option C** *(include only when a third genuinely distinct option exists — not a minor variant of A or B)*: <description>
  ```ts
  // code showing what this looks like in practice
  ```
  - **Pros**: <what you gain>
  - **Cons**: <what you lose or accept>

**Recommendation**: Option A — <specific reason grounded in research or intent>, accepting <specific tradeoff>.

---

**2. <Decision Title>**

<context>

- **Option A**: <description>
  - **Pros**: ...
  - **Cons**: ...
- **Option B**: <description>
  - **Pros**: ...
  - **Cons**: ...

**Recommendation**: Option B — <why>

---
```

After presenting, ask:

```
Go through each question and tell me which option you want, or override with your own direction.
You can also just say "go with all recommendations" if they look right.
```

## Guidelines for Writing Questions

- **Context first**: Start each question with why it matters, not just what the options are. The reader should understand the stakes before evaluating options.
- **Surface the options that genuinely exist**: A question may have one obvious path, two real alternatives, or three distinct approaches. Don't manufacture options to fill a format, and don't merge distinct alternatives to keep it tidy. Show code for each option where the shape meaningfully differs. Use pseudo-code for flows, real code for interfaces/APIs/config.
- **Explicit Pros/Cons**: Every option gets Pros and Cons bullets. Be specific — "simpler" is not a pro, "fewer moving parts — single file vs. three-file module" is.
- **Recommendations acknowledge tradeoffs**: Don't just say "Option A is better." Say "Option A — [reason], accepting [what you give up]."
- **One decision per question**: If two things are separate decisions, split them. If they're entangled, explain the dependency.

## Resolved Design Questions Format

Once the user has responded, confirm what was decided:

```markdown
## Resolved Design Questions

### 1. <Decision Title>
**Chosen**: Option X — <rationale and any notes. If they deviated from the recommendation, note their reasoning.>

### 2. <Decision Title>
**Chosen**: <resolution>
```

If anything is still ambiguous after their response, ask one follow-up before moving on.
