---
description: "Auto-commit staged changes: analyze diff, generate commit message and execute git commit"
allowed-tools:
  [
    "Task(subagent_type=commit-writer:*)"
  ]
---

## Context
- Current git status: !`git status`
- Staged diff: !`git diff --staged`
- Unstaged diff: !`git diff`
- Current branch: !`git branch --show-current`

## Task

Use the Task tool to invoke the commit-writer agent (haiku model) for fast commit message generation:

```
Task(
  subagent_type="commit-writer",
  description="Generate and execute commit",
  prompt="Analyze the following git context and generate a conventional commit message, then execute git commit.

## Git Status
<git_status>
{status}
</git_status>

## Staged Diff
<staged_diff>
{staged_diff}
</staged_diff>

## Unstaged Diff
<unstaged_diff>
{unstaged_diff}
</unstaged_diff>

## Current Branch
{branch}

## Instructions
1. If there are no staged changes, respond that user needs to stage changes first and stop.
2. Analyze the staged diff to understand what changed.
3. Generate a conventional commit message with:
   - Subject line in imperative tense (feat, fix, docs, refactor, etc.)
   - Optional body if changes need explanation
4. Execute: git commit -m '<generated message>'
5. Return the commit output."
)
```

Replace placeholders with actual context values from above.
