---
description: "Generate a short, compact git commit message for changes in the current branch"
allowed-tools:
  [
    "Task(subagent_type=commit-writer:*)"
  ]
---

## Context
- Current git status: !`git status`
- Diff of staged and unstaged changes: !`git diff --staged && git diff`

## Task

Use the Task tool to invoke the commit-writer agent (haiku model) for fast message generation:

```
Task(
  subagent_type="commit-writer",
  description="Generate short commit message",
  prompt="Generate a single-line conventional commit message for the following changes.

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
2. Generate a single-line commit message:
   - Use imperative tense
   - Follow format: type(scope): description
   - Keep it short and informative (under 72 chars)
3. Output ONLY the commit message, nothing else.
4. Do NOT run git commit."
)
```

Replace placeholders with actual context values from above.
