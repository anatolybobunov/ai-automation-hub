---
description: "Review the last N commits (default: 1 commit)"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git branch --show-current:*)",
    "Bash(git log:*)",
    "Bash(git diff:*)",
    "Bash(git rev-parse:*)",
    "Bash(git show:*)",
    "Bash(date:*)",
    "Read",
    "Grep"
  ]
---

## Context
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Task
You are an expert code reviewer performing a comprehensive review of the last N commit(s).

### Step 1: Parse command parameter

The user may provide:
- `/review-last` - Review last 1 commit (default)
- `/review-last N` - Review last N commits (where N is a positive integer)

**Examples:**
- `/review-last` → Review 1 commit
- `/review-last 3` → Review last 3 commits
- `/review-last 5` → Review last 5 commits

**Parameter extraction:**
- The parameter is the first argument after the command name
- If no parameter provided, use default: `N = 1`
- If parameter provided, parse it as an integer

**Validation:**
1. If parameter is not a valid integer:
   ```
   ERROR: Invalid parameter '<param>'. Must be a positive integer.
   Usage: /review-last [N]
   Examples:
     /review-last     - Review last commit
     /review-last 3   - Review last 3 commits
   ```

2. If N is less than 1:
   ```
   ERROR: Number of commits must be at least 1.
   Usage: /review-last [N]
   ```

3. If N is greater than 20:
   ```
   WARNING: Reviewing >20 commits may be slow. Consider reviewing in smaller batches.
   Proceeding with review of last <N> commits...
   ```

Save validated number as COMMIT_COUNT for next steps.

### Step 2: Check if enough commits exist

Verify we have enough commits in the repository:
```bash
TOTAL_COMMITS=$(git rev-list --count HEAD)
echo "Total commits in branch: $TOTAL_COMMITS"

if [ $TOTAL_COMMITS -lt <COMMIT_COUNT> ]; then
  echo "WARNING: Only $TOTAL_COMMITS commits exist, will review all available"
  COMMIT_COUNT=$TOTAL_COMMITS
fi
```

If repository has fewer commits than requested, review all available commits and note this in the output.

### Step 3: Get commit range

Determine the commit range to review:
```bash
# Get the hash of the commit before the range
if [ <COMMIT_COUNT> -eq 1 ]; then
  # For single commit, compare with its parent
  COMMIT_HASH=$(git rev-parse HEAD)
  PARENT_HASH=$(git rev-parse HEAD^)
  echo "Reviewing commit: $COMMIT_HASH"
  echo "Comparing with parent: $PARENT_HASH"
else
  # For multiple commits, get range
  START_COMMIT=$(git rev-parse HEAD~<COMMIT_COUNT>)
  END_COMMIT=$(git rev-parse HEAD)
  echo "Reviewing commits from $START_COMMIT to $END_COMMIT"
fi

# Get commit details
git log -<COMMIT_COUNT> --format="%H|%an|%ae|%ai|%s%n%b%n---" HEAD
```

**This provides:**
- Commit hashes in the range
- Author information
- Timestamps
- Commit messages and bodies
- Boundaries for diff analysis

### Step 4: Get detailed diff for the range

Retrieve the complete diff:
```bash
if [ <COMMIT_COUNT> -eq 1 ]; then
  # Single commit: show changes introduced by this commit
  git show HEAD --stat
  git show HEAD
else
  # Multiple commits: show cumulative changes
  git diff HEAD~<COMMIT_COUNT>..HEAD --stat
  git diff HEAD~<COMMIT_COUNT>..HEAD
fi
```

**Output includes:**
- File change statistics
- Line-by-line diffs
- File paths and line numbers
- Added/modified/deleted content

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

### Step 6: Review commit messages

Analyze commit messages for quality:
```bash
git log -<COMMIT_COUNT> --format="%h %s" HEAD
```

Check:
- Are commit messages descriptive and clear?
- Do they explain WHY changes were made (not just WHAT)?
- Do they follow conventional commit format (feat:, fix:, docs:, etc.)?
- Are they appropriately detailed?
- Do commit bodies provide additional context when needed?

### Step 7: Generate structured report

Create a comprehensive report following this structure:

```markdown
# Code Review Report

**Scope:** Last <N> commit(s) on <current-branch>
**Date:** <YYYY-MM-DD>
**Commits Reviewed:** <N>
**Total Changes:** <X> files changed, <Y> insertions(+), <Z> deletions(-)

---

## Commits Analyzed

<For each commit, show:>
- `<hash>` <commit-subject> - <author> (<date>)

---

## Summary
[2-3 sentence overview: What do these commits accomplish? Overall code quality? Any major concerns?]

---

[ONLY INCLUDE SECTIONS BELOW IF THEY HAVE CONTENT - SKIP EMPTY SECTIONS]

## Critical Issues

[List critical issues that MUST be fixed]

### [Issue Title]
**Location:** `path/to/file.ext:line_number`
**Commit:** `<hash>`
**Severity:** Critical
**Category:** [Bug/Security/Performance/Architecture]

**Description:**
[Clear explanation of what's wrong and why it's critical]

**Recommendation:**
[Specific steps to fix the issue]

**Example:**
```language
// Current problematic code
[code snippet from commit]

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
- [List any commit message or structure problems]

**Good practices observed:**
- [List positive aspects of commit history]

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

**If Issues Found:**
1. [List actions needed to address critical issues]
2. [List recommended improvements]

**If No Issues:**
The code in these commits meets quality standards. Consider:
1. [Any optional enhancements]
2. [Best practices to maintain going forward]
```

### Step 8: Special considerations for single commit review

When reviewing a single commit (N=1), add extra detail:

**Include commit metadata:**
- Full commit message (subject + body)
- Author and date
- Changed files with line counts
- Whether this is a merge commit

**Provide more context:**
- Show the specific intent of the commit
- Check if commit message matches actual changes
- Verify commit is atomic (does one thing)

**Example section for single commit:**
```markdown
## Commit Details

**Hash:** `<full-hash>`
**Author:** <name> <<email>>
**Date:** <timestamp>
**Message:**
```
<subject>

<body if present>
```

**Analysis:**
- Commit intent: [What the commit claims to do]
- Actual changes: [What actually changed]
- Alignment: [Do changes match intent? Yes/No/Partially]
- Atomicity: [Is this one logical change? Yes/No]
```

### Step 9: Language-specific checks

Apply language-specific rules:

**Python (.py):**
- Check for proper use of type hints
- Look for mutable default arguments
- Check exception handling patterns
- Verify proper use of context managers
- Check for PEP 8 compliance

**JavaScript/TypeScript (.js, .ts, .tsx, .jsx):**
- Check for proper async/await usage
- Look for == instead of ===
- Check for missing error handling in promises
- Verify proper React hooks dependencies
- Check for memory leaks in event listeners

**Java (.java):**
- Check for proper resource closure
- Look for missing @Override annotations
- Check exception handling patterns
- Verify proper equals/hashCode implementations

**Go (.go):**
- Check for proper error handling
- Look for goroutine leaks
- Check for proper defer usage
- Verify proper context usage

**SQL files (.sql):**
- Check for missing indexes
- Look for SELECT * patterns
- Check for missing WHERE clauses

**Configuration files (.json, .yaml, .env.example):**
- Check for exposed secrets
- Verify configurations are documented

## Constraints

- Use **only English** for all output
- **Skip empty sections** - only include sections with actual findings
- Focus on **actionable insights** with specific file locations and line numbers
- Provide **code examples** for all critical issues and most warnings
- Keep descriptions **concise but complete**
- **Prioritize findings** by severity: Critical > Warning > Suggestion
- **Be constructive** - focus on improving code
- Include **specific line numbers and commit hashes** when referencing issues
- If reviewing >10 commits, provide high-level summary and focus on most significant issues
- If no issues found, acknowledge good code quality
- Use **markdown formatting** for readability

## Error Handling

**Not in a git repository:**
```
ERROR: Not in a git repository. Please run this command from within a git repository.
```

**Invalid parameter:**
```
ERROR: Invalid parameter '<param>'. Must be a positive integer.
Usage: /review-last [N]
Examples:
  /review-last     - Review last commit
  /review-last 3   - Review last 3 commits
```

**No commits in repository:**
```
ERROR: No commits found in this repository.
Please make at least one commit before using this command.
```

**Requested more commits than exist:**
```
INFO: Repository only has <X> commits. Reviewing all available commits instead of requested <N>.
```

**Initial commit requested:**
```
INFO: Reviewing initial commit in repository.
Note: This commit has no parent, comparing with empty tree.
```

**Detached HEAD state:**
```
WARNING: Repository is in detached HEAD state.
Reviewing last <N> commits from current HEAD position.
```

**Large commit review (>10 commits):**
```
WARNING: Reviewing <N> commits. This may take some time.
Consider breaking into smaller batches for more detailed review.
```
