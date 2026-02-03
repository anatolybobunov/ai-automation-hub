---
description: "Review all changes in current branch relative to parent branch"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git branch --show-current:*)",
    "Bash(git branch -a:*)",
    "Bash(git rev-parse --verify:*)",
    "Bash(git merge-base:*)",
    "Bash(git log:*)",
    "Bash(git diff:*)",
    "Bash(date:*)",
    "Read",
    "Grep"
  ]
---

## Context
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Available branches: !`git branch -a`

## Task
You are an expert code reviewer performing a comprehensive review of all changes in the current branch.

### Step 1: Validate branch context

Check that we're not on the base branch:
```bash
CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" = "master" ] || [ "$CURRENT_BRANCH" = "main" ]; then
  echo "ERROR: Cannot review master/main branch directly"
  echo "Please switch to a feature branch first"
  exit 1
fi

echo "Reviewing branch: $CURRENT_BRANCH"
```

If on master/main, output error message and stop.

### Step 2: Determine base branch

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

Save the result as BASE_BRANCH for next steps.

### Step 3: Get merge-base and analyze scope

Using the detected BASE_BRANCH from Step 2, run:
```bash
# Find divergence point
MERGE_BASE=$(git merge-base HEAD <BASE_BRANCH>)
echo "Merge base: $MERGE_BASE"

# Get commit count
COMMIT_COUNT=$(git rev-list --count $MERGE_BASE..HEAD)
echo "Commits to review: $COMMIT_COUNT"

# Get change statistics
git diff $MERGE_BASE..HEAD --stat

# Get list of changed files
git diff $MERGE_BASE..HEAD --name-status
```

**Output includes:**
- Merge base commit hash
- Number of commits in the branch
- File change statistics (insertions, deletions)
- List of files with their status (A=added, M=modified, D=deleted)

### Step 4: Get detailed diff

Retrieve the full diff for analysis:
```bash
git diff $MERGE_BASE..HEAD
```

This provides:
- Line-by-line changes for each file
- Context around changes (3 lines before/after)
- File paths and line numbers

### Step 5: Analyze code changes

Perform comprehensive code review across these aspects:

#### A. Code Quality and Architecture

Examine for:
- **Code structure and organization:**
  - Are functions/classes appropriately sized? (Functions >50 lines, classes >300 lines are potential issues)
  - Is code DRY (Don't Repeat Yourself)? Look for duplicated logic
  - Are responsibilities clearly separated? Check for Single Responsibility violations

- **Naming and readability:**
  - Are variables/functions/classes clearly named?
  - Is the code self-documenting or does it need more comments?
  - Are magic numbers used instead of named constants?

- **Design patterns and principles:**
  - SOLID principles adherence
  - Are appropriate design patterns used?
  - Is dependency injection used where needed?
  - Are interfaces/abstractions properly defined?

- **Best practices:**
  - Language-specific conventions followed?
  - Consistent code style?
  - Proper error handling structure?

#### B. Potential Bugs and Issues

Look for:
- **Logic errors:**
  - Off-by-one errors in loops
  - Incorrect conditional logic (wrong operators, missing cases)
  - State management issues

- **Null/undefined handling:**
  - Missing null checks before dereferencing
  - Unhandled optional values
  - Potential NPE (Null Pointer Exception) scenarios

- **Edge cases:**
  - Empty array/collection handling
  - Boundary conditions (min/max values)
  - Unexpected input handling

- **Race conditions and concurrency:**
  - Shared state without synchronization
  - Async operations without proper awaiting
  - Missing locks or transaction boundaries

- **Error handling:**
  - Unhandled exceptions
  - Silent failures (catch without logging)
  - Missing validation of inputs

- **Security concerns:**
  - SQL injection vulnerabilities
  - XSS vulnerabilities
  - Unvalidated user input
  - Exposed secrets or credentials
  - Improper authentication/authorization checks

#### C. Performance Issues

Identify:
- **Database queries:**
  - N+1 query problems (queries in loops)
  - Missing indexes for frequent queries
  - Fetching unnecessary columns (SELECT *)
  - Missing query pagination for large datasets

- **Algorithm efficiency:**
  - Nested loops creating O(n²) or worse complexity
  - Inefficient sorting or searching
  - Unnecessary repeated computations
  - Better algorithm alternatives available

- **Memory management:**
  - Memory leaks (unclosed resources, event listeners)
  - Loading large datasets into memory unnecessarily
  - Missing stream processing for large files
  - Inefficient data structures

- **Resource usage:**
  - Unnecessary file I/O operations
  - Missing caching opportunities
  - Redundant API calls
  - Blocking operations on main thread

### Step 6: Review commit quality

Analyze the commits in the range:
```bash
git log $MERGE_BASE..HEAD --format="%h %s%n%b%n---"
```

Check:
- Are commit messages descriptive?
- Are commits atomic (one logical change per commit)?
- Are there WIP commits that should be squashed?
- Do commits follow conventional commit format?

### Step 7: Generate structured report

Create a comprehensive report following this structure:

```markdown
# Code Review Report

**Scope:** Changes from <BASE_BRANCH> (<merge-base-short>) to HEAD (<current-branch>)
**Date:** <YYYY-MM-DD>
**Commits Reviewed:** <N> commits
**Total Changes:** <X> files changed, <Y> insertions(+), <Z> deletions(-)

---

## Summary
[2-3 sentence overview: What is the main purpose of these changes? Overall code quality assessment? Any major concerns?]

---

[ONLY INCLUDE SECTIONS BELOW IF THEY HAVE CONTENT - SKIP EMPTY SECTIONS]

## Critical Issues

[List critical issues that MUST be fixed before merging]

### [Issue Title]
**Location:** `path/to/file.ext:line_number`
**Severity:** Critical
**Category:** [Bug/Security/Performance/Architecture]

**Description:**
[Clear explanation of what's wrong and why it's critical]

**Recommendation:**
[Specific steps to fix the issue]

**Example:**
```language
// Current problematic code
[code snippet from diff]

// Suggested fix
[improved version]
```

---

## Warnings

[List issues that should be addressed but aren't blocking]

[Same structure as Critical Issues, with Severity: Warning]

---

## Suggestions

[List improvements that would enhance code quality]

[Same structure as Critical Issues, with Severity: Suggestion]

---

## Code Quality Assessment

**Overall Grade:** [A/B/C/D/F]
- A: Excellent code quality, follows best practices
- B: Good code quality, minor improvements possible
- C: Acceptable but needs improvements
- D: Poor quality, significant refactoring needed
- F: Critical issues, code should not be merged

**Strengths:**
- [List 2-3 positive aspects of the code]

**Areas for Improvement:**
- [List 2-3 areas that need work]

**Metrics:**
- Code complexity: [Low/Medium/High] - based on cyclomatic complexity, nesting depth
- Test coverage impact: [Better/Same/Worse/Unknown] - are tests added/updated?
- Documentation: [Good/Needs Improvement/Missing] - are code comments adequate?
- SOLID principles: [Followed/Partially Followed/Violated] - assess architectural quality

---

## Commit Quality

**Assessment:** [Good/Needs Improvement/Poor]

**Issues found:**
- [List commit message or structure problems if any]

**Recommendations:**
- [Suggestions for improving commits if needed]

---

## Files Reviewed

**Modified:** <X> files
**Added:** <Y> files
**Deleted:** <Z> files

### Key Files Changed:
- `path/to/file1.ext` (+X/-Y lines) - [Brief description of changes]
- `path/to/file2.ext` (+X/-Y lines) - [Brief description of changes]
[List up to 10 most significant files]

---

## Next Steps

**Before Merge:**
1. [List critical issues that MUST be addressed]

**Recommended:**
1. [List warnings and suggestions, prioritized]

**Consider:**
1. [List optional improvements for future]
```

### Step 8: Language-specific checks

Automatically detect file types from diff and apply language-specific rules:

**Python (.py):**
- Check for proper use of type hints
- Look for mutable default arguments
- Check exception handling patterns
- Verify proper use of context managers (with statements)
- Check for PEP 8 compliance issues

**JavaScript/TypeScript (.js, .ts, .tsx, .jsx):**
- Check for proper async/await usage
- Look for == instead of ===
- Check for missing error handling in promises
- Verify proper React hooks dependencies
- Check for memory leaks in event listeners

**Java (.java):**
- Check for proper resource closure (try-with-resources)
- Look for missing @Override annotations
- Check exception handling patterns
- Verify proper equals/hashCode implementations

**Go (.go):**
- Check for proper error handling (not ignoring errors)
- Look for goroutine leaks
- Check for proper defer usage
- Verify proper context usage

**SQL files (.sql):**
- Check for missing indexes on foreign keys
- Look for SELECT * patterns
- Check for missing WHERE clauses on UPDATE/DELETE

**Configuration files (.json, .yaml, .env.example):**
- Check for exposed secrets (API keys, passwords)
- Verify required configurations are documented

## Constraints

- Use **only English** for all output
- **Skip empty sections** - only include sections with actual findings
- Focus on **actionable insights** with specific file locations and line numbers
- Provide **code examples** for all critical issues and most warnings
- Keep descriptions **concise but complete** - explain both the problem and the fix
- **Prioritize findings** by severity: Critical > Warning > Suggestion
- **Be constructive** - focus on improving code, not criticizing
- Include **specific line numbers** from diff output when referencing issues
- If no issues found, that's okay - say so and focus on positive aspects
- If reviewing >50 files, focus on the most critical changes
- Use **markdown formatting** for readability

## Error Handling

**Not in a git repository:**
```
ERROR: Not in a git repository. Please run this command from within a git repository.
```

**On master/main branch:**
```
ERROR: Cannot review master/main branch directly.
Please switch to a feature branch first:
  git checkout -b feature/your-branch-name
```

**No base branch found:**
```
ERROR: No base branch found (master, main, or develop).
Cannot determine what to compare against.
Please ensure you have a master, main, or develop branch.
```

**No changes detected:**
```
INFO: No changes detected between current branch and <BASE_BRANCH>.
The branches are in sync.
```

**Large changeset (>1000 lines or >50 files):**
```
WARNING: Large changeset detected (<X> files, <Y> lines changed).
Focusing review on the most critical changes. Manual review recommended for complete coverage.
```
