---
description: "Generate a full detailed git commit message for changes in the current branch"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git diff --staged:*)",
    "Bash(git diff:*)"
  ]
---

## Context
- Git status: !`git status`
- Diff of staged and unstaged changes: !`git diff --staged && git diff`

## Task
Analyze the changes above and output a **full git commit message** with these parts:

1. **Subject line**
   - Imperative tense
   - Capitalized first word
   - Brief summary (~50 chars max) of what has changed  [oai_citation:0‡Graphite](https://graphite.com/guides/git-commit-message-best-practices?utm_source=chatgpt.com)

2. **Blank line**

3. **Body description**
   - Detailed explanation of what was changed
   - Why the change was necessary
   - Any important context or impact
   - Wrap text at ~72 characters per line  [oai_citation:1‡Gist](https://gist.github.com/tonibardina/9290fbc7d605b4f86919426e614fe692?utm_source=chatgpt.com)

## Constraints
- Do **not** run `git commit`; only generate the commit message text.
- Do **not** include any Claude signature, metadata, or co-authored footers.
- Do **not** stage files.
- If the diff is empty, instruct the user to stage changes first.
- Use only English to write comments
