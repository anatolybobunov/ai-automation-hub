---
description: "Auto-commit staged changes and push current branch (handles first push)"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git diff --staged:*)",
    "Bash(git diff:*)",
    "Bash(git branch --show-current:*)",
    "Bash(git rev-parse --abbrev-ref --symbolic-full-name @{u}:*)",
    "Bash(git commit -m:*)",
    "Bash(git push:*)"
  ]
---

## Context
- Current git status: !`git status`
- Staged diff: !`git diff --staged`
- Unstaged diff: !`git diff`
- Current branch: !`git branch --show-current`
- Upstream branch (if exists): !`git rev-parse --abbrev-ref --symbolic-full-name @{u}`

## Task
You are an AI commit and push assistant.

1. Identify the **staged changes**. If there are **no staged changes**, ask the user to “stage changes first” and stop.
2. Analyze the staged diff and understand what changed.
3. Generate a **high-quality commit message** that includes:
   - A **subject line** in **imperative tense**
   - An optional **body** with brief points describing what was changed and why
   - Follow **Conventional Commits** style where possible (feat, fix, docs, test, refactor, chore, etc.).
4. Run `git commit -m "<generated message>"`.
5. Push the current branch:
   - If an **upstream branch exists**, run `git push`.
   - If **no upstream exists** (first push), run  
     `git push -u origin <current-branch>`.
6. Return only the output of the commit and push operations.

## Constraints
- Do **not** include any Claude signature, metadata, or co-authored footers.
- Do **not** stage files.
- If the diff is empty, instruct the user to stage changes first.
- Use only English to write comments