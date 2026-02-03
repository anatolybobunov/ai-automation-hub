---
description: "Generate a short, compact git commit message for changes in the current branch"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git diff --staged:*)",
    "Bash(git diff:*)"
  ]
---

## Context
- Current git status: !`git status`
- Diff of staged and unstaged changes: !`git diff --staged && git diff`

## Task
Analyze the changes above and output a **single-line git commit message**:
- Use imperative tense
- Keep it short and informative
- Do not run `git commit`, only generate the message
- Use only English to write comments