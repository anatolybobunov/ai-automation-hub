---
description: "Generate changelog from merge commits for specified authors and period"
allowed-tools:
  [
    "Bash(git log --merges:*)",
    "Bash(git log --format:*)",
    "Bash(git rev-parse --verify:*)",
    "Bash(git branch --show-current:*)",
    "Bash(git show:*)",
    "Bash(date:*)",
    "Bash(grep:*)",
    "Bash(echo:*)",
    "Bash(cat:*)",
    "Bash(sed:*)",
    "Bash(awk:*)"
  ]
---

## Context
- Current branch: !`git branch --show-current`
- User will provide authors and optional period in command arguments

## Task
You are a changelog generator that creates structured changelogs from GitLab merge commits.

### Step 1: Parse command arguments

The user will provide:
- **Author nicknames** (GitLab usernames): e.g., "ban john alice"
- **Optional period flag**: `--period=<value>` where value is 1month, 2months, or 3months
- **Default**: If no period specified, use 1month

**Examples:**
- `/changelog ban john --period=2months`
- `/changelog alice` (uses 1month by default)

**Validation:**
- If no authors provided, show error: "Usage: /changelog <author1> [author2] ... [--period=<1month|2months|3months>]"
- If invalid period, show error and valid options

Extract:
1. Authors list (all arguments before --period)
2. Period value (from --period flag or default to 1month)

### Step 2: Determine base branch

Run this bash command:
```bash
if git rev-parse --verify master >/dev/null 2>&1; then
  echo "master"
elif git rev-parse --verify main >/dev/null 2>&1; then
  echo "main"
else
  echo "ERROR: No master or main branch found"
  exit 1
fi
```

Save result as BASE_BRANCH.

### Step 3: Get merge commits for specified period and authors

**Convert period to git --since format:**
- `1month` → `"1 month ago"`
- `2months` → `"2 months ago"`
- `3months` → `"3 months ago"`

**Build git log command:**

For multiple authors, you can either:
- Use multiple `--author` flags: `git log --merges --author=ban --author=john`
- Or use regex pattern: `git log --merges --author="ban\|john"`

**Run:**
```bash
git log --merges \
  --since="<SINCE_DATE>" \
  --author="<AUTHOR_PATTERN>" \
  --format="%H|%an|%ae|%ai|%s%n%b%n---END---" \
  <BASE_BRANCH>
```

**Format explanation:**
- `%H` - commit hash
- `%an` - author name
- `%ae` - author email
- `%ai` - author date (ISO 8601 format)
- `%s` - subject (first line)
- `%b` - body (remaining lines)
- `---END---` - delimiter between commits

### Step 4: Extract information from each merge commit

For EACH merge commit, extract the following:

**1. MR Number (required):**
- Search in body for: `See merge request !<number>`
  - Pattern: `See merge request !(\d+)`
- Or in subject for: `(!<number>)` at the end
  - Pattern: `\(!(\d+)\)$`
- **If MR number not found:** Skip this entry and log warning

**2. Branch Name:**
- Parse from subject: `Merge branch '<branch-name>' into '<target>'`
  - Pattern: `Merge branch '(.+?)' into`

**3. Task ID (optional):**
- Extract from branch name using pattern: `[A-Z]+-\d+`
  - Examples: EXA-123, PROJ-456, ABC-789
- **If not found:** Use `"N/A"`

**4. Description:**
- Take branch name and clean it up:
  - Remove task ID prefix if present (e.g., `EXA-123-` or `feature/EXA-123-`)
  - Remove common prefixes: `feature/`, `bugfix/`, `hotfix/`, `fix/`, `refactor/`
  - Replace hyphens/underscores with spaces
  - Capitalize first letter
  - Example: `feature/EXA-123-add-user-auth` → `Add user auth`

**5. Author (nickname):**
- Extract from email: `ban@exante.eu` → `@ban`
- Or from name if email doesn't match pattern
- Format: `@<nickname>`

**6. Date:**
- Parse from `%ai` (ISO 8601 format)
- Convert to `YYYY-MM-DD` format

**7. Type (category):**
Categorize by analyzing:
- **Branch name prefixes:**
  - `feature/` → Features
  - `bugfix/`, `hotfix/`, `fix/` → Fixes
  - `refactor/` → Refactoring
  - Other → Other
- **Conventional commit prefixes in branch name or commits:**
  - `feat:` or `feat(` → Features
  - `fix:` or `fix(` → Fixes
  - `refactor:` → Refactoring
  - `docs:`, `test:`, `chore:`, `build:`, `ci:`, `style:` → Other
- **Default:** If no clear indicator, use "Other"

### Step 5: Categorize and sort

**Group entries by type:**
1. **Features** - New functionality (feat:, feature/)
2. **Fixes** - Bug fixes (fix:, bugfix/, hotfix/)
3. **Refactoring** - Code improvements (refactor:, refactor/)
4. **Other** - Everything else (docs, test, chore, etc.)

**Within each category:**
- Sort by date (newest first)

### Step 6: Generate changelog output

**Header:**
```markdown
# Changelog
Period: <start_date> - <end_date>
Authors: @ban, @john, @alice
```

**Calculate dates:**
- `<end_date>`: Today's date (YYYY-MM-DD)
- `<start_date>`: Today minus period (YYYY-MM-DD)

**For each non-empty category:**

```markdown
## <Category Name>
- <TASK_ID> [!<MR_NUM>] <Description> (@<author>) - <date>
- <TASK_ID> [!<MR_NUM>] <Description> (@<author>) - <date>
...
```

**Example output:**
```markdown
# Changelog
Period: 2024-11-12 - 2025-01-12
Authors: @ban, @john

## Features
- EXA-123 [!456] Add user authentication (@ban) - 2024-01-15
- EXA-124 [!458] Add dashboard UI (@john) - 2024-01-10

## Fixes
- EXA-125 [!460] Fix login bug (@ban) - 2024-01-12
- N/A [!462] Fix typo in docs (@john) - 2024-01-08

## Refactoring
- EXA-126 [!464] Refactor API client (@ban) - 2024-01-05

## Other
- N/A [!466] Update dependencies (@john) - 2024-01-03
```

### Constraints
- Use **only English**
- **Skip empty categories** (if no features, don't include "## Features" section)
- If task ID not found, use **"N/A"**
- If MR number not found, **skip that entry** entirely (log a warning)
- Sort by date **newest to oldest** within each category
- Date format: **YYYY-MM-DD**
- Author format: **@nickname**
- Output **only the changelog** in markdown format
- Do not include any metadata, signatures, or additional commentary

### Error handling
- **No authors provided:** Show usage message
- **Invalid period:** Show valid period options
- **No base branch:** Show error and exit
- **No merge commits found:** Return empty changelog with message
- **Unable to parse commit:** Log warning and skip
