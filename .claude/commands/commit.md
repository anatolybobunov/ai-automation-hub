---
description: "Auto-commit staged changes: analyze diff, generate commit message and execute git commit"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git diff --staged:*)",
    "Bash(git diff:*)",
    "Bash(git commit -m:*)"
  ]
---

## Context
- Current git status: !`git status`
- Staged diff: !`git diff --staged`
- Unstaged diff: !`git diff`
- Current branch: !`git branch --show-current`

## Task
You are an AI commit assistant.

1. Identify the **staged changes**. If there are **no staged changes**, ask the user to “stage changes first” and stop.  
2. Analyze the staged diff and understand what changed.  
3. Generate a **high-quality commit message** that includes:
   - A **subject line** in **imperative tense** (short summary)
   - An optional **body** with brief points describing what was changed and why  
   - Follow common **Conventional Commits** style where possible (feat, fix, docs, test, refactor, chore etc.).  
4. Run `git commit -m "<generated message>"` using the chosen message.  
5. Return only the output of the commit operation.

## Constraints
- Do **not** include any Claude signature, metadata or co-authored footers.  
- If the diff is empty, instruct the user to stage changes first.
- Use only English to write comments