---
description: "Auto-commit staged changes and push current branch (handles first push)"
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
- Upstream branch (if exists): !`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no upstream"`

## Task

Use the Task tool to invoke the commit-writer agent (haiku model) for fast commit and push:

```
Task(
  subagent_type="commit-writer",
  description="Commit and push changes",
  prompt="Analyze the following git context, generate a conventional commit message, execute git commit, then push.

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

## Upstream Branch
{upstream}

## Instructions
1. If there are no staged changes, respond that user needs to stage changes first and stop.
2. Analyze the staged diff to understand what changed.
3. Generate a conventional commit message with:
   - Subject line in imperative tense (feat, fix, docs, refactor, etc.)
   - Optional body if changes need explanation
4. Execute: git commit -m '<generated message>'
5. Push the branch:
   - If upstream exists: git push
   - If no upstream (first push): git push -u origin {branch}
6. Return the commit and push output."
)
```

Replace placeholders with actual context values from above.
