# Intent Document Template

```markdown
---
task: <ticket-id-kebab-description>
type: intent
---

# Intent: <short title>

## Summary
<2–3 sentences: what will change and why, written so someone unfamiliar can understand in 30 seconds>

## Background
<Current system state and how we got here. What exists today, what's been tried before, links to prior art or relevant discussions. This is factual context, not argumentation.>

## Motivation
<The problem being solved and who it affects. Why now? What's the cost of not doing this?>

## Scope

### In scope
- <bullet list of what IS included>

### Out of scope
- <bullet list of what is explicitly NOT included, and why>

## Acceptance Criteria

**AC-1: <short descriptive name>**
Given <precondition>
When <action or event>
Then <observable outcome>

**AC-2: <short descriptive name>**
Given <precondition>
When <action or event>
Then <observable outcome>

## Gotchas & Risks
- <non-obvious pitfalls, edge cases to watch for, things that could go wrong>
- <legacy behavior, race conditions, migration concerns, anything a developer would wish they knew before starting>

## Constraints
- <technical, business, or timeline constraints>

## Visual References
<!-- Optional — include only if the user shared images (screenshots, mockups, diagrams, etc.) that don't belong inline in a specific section above. Images stored in the artifacts/ subfolder. -->
![Description of what the image shows](artifacts/descriptive-name.png)

## Open Questions
- <anything unresolved — to be answered during research or planning>
```
