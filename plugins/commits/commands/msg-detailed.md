---
description: "Generate a full detailed git commit message for changes in the current branch"
allowed-tools:
  [
    "Task(subagent_type=commit-writer:*)"
  ]
---

## Context
- Git status: !`git status`
- Diff of staged and unstaged changes: !`git diff --staged && git diff`

## Task

Use the Task tool to invoke the commit-writer agent (haiku model) for detailed message generation:

```
Task(
  subagent_type="commit-writer",
  description="Generate detailed commit message",
  prompt="Generate a full conventional commit message with body for the following changes.

## Git Status
<git_status>
{status}
</git_status>

## Diff
<diff>
{diff}
</diff>

## Instructions
1. Analyze the changes to understand what was modified.
2. Generate a full commit message with:

   **Subject line:**
   - Imperative tense
   - Capitalized first word after type
   - Brief summary (~50 chars max)
   - Format: type(scope): description

   **Blank line**

   **Body description:**
   - Detailed explanation of what was changed
   - Why the change was necessary
   - Any important context or impact
   - Wrap text at ~72 characters per line

3. Output ONLY the commit message text, nothing else.
4. Do NOT run git commit.
5. Do NOT include any Claude signature, metadata, or co-authored footers."
)
```

Replace placeholders with actual context values from above.
