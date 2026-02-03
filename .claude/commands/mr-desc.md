---
description: "Generate structured MR description for current branch changes"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git branch --show-current:*)",
    "Bash(git branch -a:*)",
    "Bash(git rev-parse --verify:*)",
    "Bash(git merge-base:*)",
    "Bash(git log:*)",
    "Bash(git diff:*)"
  ]
---

## Context
- Current branch: !`git branch --show-current`
- Available branches: !`git branch -a`
- Recent commits: !`git log --oneline -20`

## Task
You are an AI MR description generator.

**Step 1: Determine base branch**

Run bash command to detect base branch (master/main/develop in priority order):
```bash
if git rev-parse --verify master >/dev/null 2>&1; then
  echo "master"
elif git rev-parse --verify main >/dev/null 2>&1; then
  echo "main"
elif git rev-parse --verify develop >/dev/null 2>&1; then
  echo "develop"
else
  echo "ERROR: No base branch found (master, main, or develop)"
  exit 1
fi
```

**Step 2: Find merge-base and get branch data**

Using the detected BASE_BRANCH from Step 1, run:
```bash
# Find divergence point
git merge-base HEAD <BASE_BRANCH>

# Get commits from merge-base to HEAD
git log <MERGE_BASE>..HEAD --format="%h %s"

# Get diff summary
git diff <MERGE_BASE>..HEAD --stat

# Get full diff
git diff <MERGE_BASE>..HEAD
```

**Step 3: Analyze and categorize changes**

Review all commits and diffs, then categorize changes by type:
- **Features** (feat:) - new functionality
- **Fixes** (fix:) - bug fixes
- **Refactoring** (refactor:) - code improvements without behavior changes
- **Documentation** (docs:) - documentation updates
- **Tests** (test:) - test additions or modifications
- **Other** (chore:, style:, build:, ci:) - other changes

**Step 4: Generate structured MR description**

Create a compact, structured description in markdown format:

```markdown
## Summary
[2-3 compact sentences describing what was done and why]

## What changed

### Features
- [List new features added]

### Fixes
- [List bugs fixed]

### Refactoring
- [List refactoring work]

### Documentation/Tests/Other
- [List other changes]

## Why
[Compact context: why these changes were needed, what problem they solve]

## Testing notes
- [Key scenarios to verify]
- [Important test cases]

## Breaking changes
[If any breaking changes exist, describe them; otherwise write "None"]
```

## Constraints
- Use **compact** text - be concise and to the point
- Focus on **what** and **why**, not implementation details
- Group changes by type/category
- Use bullet points for readability
- Use only English
- **Skip empty sections** (e.g., if no features, don't include "### Features")
- If a category has no items, omit that entire subsection
- Output only the MR description in markdown format
- Do not include any metadata, signatures, or additional commentary
