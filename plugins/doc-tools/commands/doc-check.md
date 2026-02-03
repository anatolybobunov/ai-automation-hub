---
description: "Analyze code changes and update documentation if needed"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git branch --show-current:*)",
    "Bash(git branch -a:*)",
    "Bash(git rev-parse:*)",
    "Bash(git merge-base:*)",
    "Bash(git diff:*)",
    "Bash(git log:*)",
    "Glob",
    "Read",
    "Grep",
    "Edit",
    "Write",
    "Task",
    "AskUserQuestion"
  ]
---

## Context
- Current branch: !`git branch --show-current`
- Repository root: !`git rev-parse --show-toplevel`
- Git status: !`git status --short`

## Task
You are a documentation validation assistant that analyzes code changes and identifies documentation that needs updating.

**Architecture:**
- This command performs READ-ONLY analysis of code and documentation
- When auto-update is approved by the user, this command uses the specialized **doc-writer agent** to generate high-quality documentation content
- The doc-writer agent (defined in `agents/doc-writer.md`) is a technical writing specialist trained to:
  - Match existing documentation style and tone
  - Create clear, intermediate-level English content
  - Generate practical code examples
  - Follow documentation best practices
- You MUST use the doc-writer agent (via Task tool) for all new documentation content generation
- Never write documentation content directly - always delegate to doc-writer agent

### Step 1: Determine base branch and scope

**Find base branch:**
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

**Get merge-base and analyze changes:**
Using the detected BASE_BRANCH from above, run:
```bash
# Find divergence point
MERGE_BASE=$(git merge-base HEAD <BASE_BRANCH>)
echo "Merge base: $MERGE_BASE"

# Get list of changed files (excluding markdown)
echo "Changed code files:"
git diff $MERGE_BASE..HEAD --name-only | grep -v '\.md$'

# Get summary of changes
echo "Change statistics:"
git diff $MERGE_BASE..HEAD --stat
```

**Fallback:** If merge-base fails (detached HEAD, single branch), use:
```bash
git diff HEAD --name-only | grep -v '\.md$'
```

**Edge case handling:**
- If no changed files found (excluding .md), output: "No code changes detected. All documentation is up to date." and stop.
- If only .md files changed, output: "Only documentation files were modified. No code changes to validate." and stop.

### Step 2: Find all documentation files

Use `Glob` tool to find all markdown files with pattern `**/*.md`

**Categorize documentation files:**
- README files: `README.md`, `*/README.md`
- Command documentation: `commands/*.md`
- Agent documentation: `agents/*.md`
- General docs: `docs/*.md`, `CLAUDE.md`, `*.md` in root
- Plugin metadata: `.claude-plugin/plugin.json` (also check these for updates)

**Track statistics:**
- Count total documentation files found
- Note which categories are present

### Step 3: Extract key changes from diff

Analyze the git diff output to extract significant changes:

**For new files:**
- Note any new `.py`, `.js`, `.ts`, `.go`, `.rs`, `.java` files
- Especially track new files in `commands/`, `agents/`, `skills/` directories
- Track new configuration files (`.json`, `.yaml`, `.toml`)

**For deleted files:**
- Track removed code files and features
- Track removed command/agent/skill files

**For modified files, extract entities:**

**Python:**
- Functions: `def function_name(`
- Classes: `class ClassName(`
- Decorators: `@app.route(`, `@click.command(`, `@dataclass`

**JavaScript/TypeScript:**
- Functions: `function name(`, `const name = (`, `async function`
- Classes: `class ClassName`
- Exports: `export function`, `export class`, `export default`

**Configuration changes:**
- Added/removed keys in JSON/YAML files
- New environment variables in `.env.example`
- Changed CLI arguments or flags

**Build changes:**
- Only extract key entity names (function/class names)
- Focus on public APIs and exported entities
- Skip internal/private functions unless they're significant

### Step 4: Search for mentions in documentation

For EACH extracted entity (functions, classes, files, commands):

1. **Use Grep tool to search across all *.md files:**
   - Pattern: entity name (case-insensitive)
   - Look for mentions in markdown files
   - Track file paths and contexts

2. **Build mention map:**
   For each entity, track:
   - Entity name and type (function, class, file, command)
   - Change type (NEW, DELETED, MODIFIED)
   - Documentation files that mention it (if any)
   - Line numbers where mentioned (from Grep output)

3. **Determine documentation status:**
   - `NEW entity + NO mentions` → "Not documented" ⚠️
   - `DELETED entity + HAS mentions` → "Outdated (removed feature)" ❌
   - `MODIFIED entity + HAS mentions` → "Needs verification" ⚡
   - `EXISTS entity + HAS mentions` → "Documented (verify current)" ✅

### Step 5: Generate analysis report

Create a comprehensive but concise report following this structure:

```markdown
# Documentation Status Report

**Scope:** Changes from <merge-base-short-hash> to HEAD
**Analyzed:** X code files changed, Y documentation files scanned
**Branch:** <current-branch-name>
**Date:** <YYYY-MM-DD>

---

## Summary
- ⚠️ **N** new features not documented
- ❌ **N** removed features still documented
- ⚡ **N** modified features may need updates
- ✅ **N** documented features are up to date

---

[Only include sections below if they have content - skip empty sections]

## 🚨 Critical Issues

### Removed features still documented
- `entity_name` in `file/path.ext` (removed)
  - Mentioned in: `README.md` line X, `docs/api.md` line Y
  - Action: Remove or update these references

[Repeat for each removed feature]

---

## ⚠️ New Features Not Documented

### `new_entity_name` in `file/path.ext` (NEW)
- Type: [Function/Class/File/Command]
- Description: [Brief description of what it does]
- Not mentioned in any documentation
- Suggested docs to update:
  - `README.md` - Add to [relevant section]
  - `docs/[relevant].md` - Document usage/API

[Repeat for each new feature]

---

## ⚡ Modified Features to Verify

### `modified_entity` in `file/path.ext` (MODIFIED)
- Changes detected in this entity
- Currently documented in:
  - `README.md` line X (check if still accurate)
  - `docs/api.md` line Y (verify parameters/examples)
- Action: Review and update if parameters, behavior, or signature changed

[Repeat for each modified feature]

---

## ✅ Up to Date

[Brief list of major entities that are properly documented and current]
- `entity1` in `file1.ext` - documented in README.md
- `entity2` in `file2.ext` - documented in docs/api.md

[Or write: "Other documented features appear up to date."]

---

## Recommendations

**Priority: High** (Critical issues - outdated info can mislead users)
1. [Action item for critical issue 1]
2. [Action item for critical issue 2]

**Priority: Medium** (New features should be documented for discoverability)
1. [Action item for new feature 1]
2. [Action item for new feature 2]

**Priority: Low** (Verify and update if needed)
1. [Action item for modified feature 1]

---

## Next Steps

Review the findings above. You can:
- Update documentation manually based on this report
- Choose "Yes" in the next step to automatically update documentation
```

**Report formatting guidelines:**
- Use emojis for visual scanning: 🚨 ❌ ⚠️ ⚡ ✅
- Include specific file paths and line numbers
- Keep descriptions concise but actionable
- Skip empty sections entirely
- Prioritize by impact: Critical > High > Medium > Low
- Include merge-base hash (short form) for traceability

### Step 6: Ask user for auto-update

After generating and displaying the report, use the `AskUserQuestion` tool:

```json
{
  "questions": [
    {
      "question": "Would you like to automatically update the documentation based on this analysis?",
      "header": "Auto-update",
      "multiSelect": false,
      "options": [
        {
          "label": "Yes, update documentation",
          "description": "Automatically apply recommended changes to documentation files using AI-generated content. You can review changes with git diff before committing."
        },
        {
          "label": "No, I'll update manually",
          "description": "Keep documentation as-is. Use the report above to make manual updates."
        }
      ]
    }
  ]
}
```

### Step 7: Conditional auto-update

**If user selected "Yes, update documentation":**

#### 7.1 Plan updates for each issue

For each documentation issue identified, determine the update strategy:

**For new features (⚠️):**
- If it's a new command file → Update README.md with command reference
- If it's a new function/class → Add API documentation section
- If it's a config change → Update configuration docs
- Strategy: ADD new sections or entries

**For removed features (❌):**
- Locate exact lines mentioning the removed entity (from Grep results)
- Strategy: REMOVE references using Edit tool
- If entire section is about removed feature → Remove whole section
- If mixed content → Remove only the relevant parts

**For modified features (⚡):**
- Locate documentation sections
- Check what changed (parameters, behavior, return values)
- Strategy: UPDATE existing sections using Edit tool

#### 7.2 Generate new content using doc-writer agent

For features that need NEW content (not just removal), you MUST use the specialized doc-writer agent.

**When to invoke doc-writer agent:**
- Adding documentation for new commands/features
- Creating new documentation sections
- Writing API documentation for new functions/classes
- Generating usage examples
- Creating new documentation files

**How to invoke the doc-writer agent:**

Use the `Task` tool with `subagent_type="doc-writer"`. The agent is a technical writing specialist that will generate high-quality documentation following project conventions.

**Example invocation for a new command:**
```
Task(
  subagent_type="doc-writer",
  description="Document new command",
  prompt="Generate documentation for the new command '/doc-check' in the README.md file.

  Context:
  - Entity: /doc-check command
  - Location: plugins/doc-tools/commands/doc-check.md
  - Purpose: Analyzes code changes and validates documentation, offers auto-update
  - Current README structure: Commands are listed under '## Available Commands' section

  Code analysis:
  [Include relevant code snippets or command functionality details]

  Requirements:
  - Match the existing documentation style in README.md
  - Include usage example showing the command workflow
  - Explain what the command does and when to use it
  - Keep description concise (2-3 sentences for overview, detailed steps in example)
  - Use intermediate-level English

  Provide ONLY the markdown content to insert into the '## Available Commands' section."
)
```

**Example invocation for a new function:**
```
Task(
  subagent_type="doc-writer",
  description="Document API function",
  prompt="Generate API documentation for the function 'validateDocumentation' in src/validator.js.

  Function signature:
  async function validateDocumentation(baseCommit, options = {})

  Context:
  - Purpose: Compares code changes against base commit and validates documentation
  - Parameters: baseCommit (string), options (object with optional flags)
  - Returns: Promise<ValidationReport>
  - Current docs location: docs/api.md

  Code details:
  [Include function implementation or key details]

  Requirements:
  - Match existing API documentation format in docs/api.md
  - Document all parameters with types and descriptions
  - Include return value structure
  - Provide a practical usage example
  - List any exceptions or error conditions
  - Use intermediate-level English

  Provide the markdown section to add to docs/api.md."
)
```

**Prompt template for doc-writer:**

When invoking the doc-writer agent, always structure your prompt like this:

```
Generate documentation for [entity_name] in [target_file].

Context:
- Entity type: [command/function/class/file/config]
- Location: [file path]
- Purpose: [what it does and why it exists]
- Current documentation structure: [describe the section/format where this will be added]

[Entity details:]
[Include relevant code, signatures, configuration, or command structure]

Requirements:
- Match existing documentation style in [target_file]
- Include usage examples with [specific context]
- [Any specific requirements: format, length, sections needed]
- Use intermediate-level English
- [Any additional constraints]

Provide ONLY the markdown content to [insert/replace] in [target_file].
```

**Key principles:**
- Provide enough context about the code entity
- Reference existing documentation for style consistency
- Request specific output format (section, full file, etc.)
- Include code snippets or signatures when relevant
- Always ask for intermediate-level English
- Specify exactly where the content will be used

#### 7.3 Apply updates

For each planned update:

**Removals:**
```
Use Edit tool:
- file_path: [doc file]
- old_string: [section or paragraph to remove, from Grep context]
- new_string: [empty or updated text]
```

**Additions:**
```
Use Edit tool to insert new sections:
- Find appropriate insertion point
- Add new content from doc-writer agent
```

**Modifications:**
```
Use Edit tool:
- old_string: [outdated content]
- new_string: [updated content from doc-writer]
```

**Special case - New files:**
If a completely new doc file is needed:
```
Use Write tool:
- file_path: [new doc file path]
- content: [full generated content from doc-writer]
```

#### 7.4 Generate update summary

After applying all changes, create a summary:

```markdown
# Documentation Update Summary

**Updated files:** X
**Changes applied:** Y

---

## Files Modified

### README.md
- ✅ Added section: "[New feature name]"
- ✅ Updated parameters for `function_x()`
- ❌ Removed reference to deprecated `old_function()`

### docs/api.md
- ✅ Updated API endpoint documentation for `/new-endpoint`
- ⚡ Verified and updated `ClassName` usage examples

### plugins/doc-tools/.claude-plugin/plugin.json
- ✅ Updated description to reflect new commands

[List all modified files and changes]

---

## Review Changes

Run the following command to review all changes before committing:
\```bash
git diff
\```

If changes look good:
\```bash
git add .
git commit -m "docs: update documentation based on code changes"
\```

If you need to adjust something, modify the files and run git diff again.
```

**If user selected "No, I'll update manually":**

Output:
```markdown
---

Documentation analysis complete.

Please review the report above and update the documentation files manually based on the recommendations provided.

You can refer to the specific file paths and line numbers mentioned in the report to locate what needs updating.
```

## Constraints

- Use **only English** for all output and generated content
- Focus on **actionable insights**, not exhaustive lists
- **Prioritize** by impact: removed features > new features > modified features
- Include **specific file paths and line numbers** for all findings
- Use **markdown formatting** for readability and visual hierarchy
- This is **read-only analysis** until user explicitly confirms update in Step 6
- If update approved, **preserve existing documentation style and tone**
- Make **minimal changes** - only update what's necessary
- **CRITICAL: Always use doc-writer agent (via Task tool) for generating new documentation content** - never write documentation content directly yourself
- The doc-writer agent is specifically trained for:
  - Matching project documentation style
  - Creating clear, intermediate-level English content
  - Following documentation best practices
  - Generating proper code examples
- Only use Edit/Write tools for simple removals or to apply content from doc-writer agent
- Skip binary files, vendor directories (`node_modules`, `vendor`), and generated code
- If analysis is taking too long (>100 changed files), focus on the 50 most significant changes

## Error Handling

**No git repository:**
- Output: "Error: Not a git repository. Please run this command from within a git repository."
- Exit gracefully

**Detached HEAD state:**
- Show warning: "Warning: Detached HEAD detected. Using fallback diff method."
- Use `git diff HEAD` instead of merge-base approach

**No base branch found:**
- Show error: "Error: No base branch found (master, main, or develop). Cannot determine scope of changes."
- Suggest: "Please specify a base branch or ensure you're working in a branch."

**No documentation files found:**
- Output warning: "⚠️ Warning: No documentation files (*.md) found in the repository."
- Suggest: "Consider adding a README.md to document your project."

**No code changes detected:**
- Output: "✅ No code changes detected. All documentation is up to date."
- Show current branch and status
- Exit gracefully

**Large changeset (>100 files):**
- Show warning: "⚠️ Large changeset detected (X files changed)."
- Output: "Analyzing the 50 most significant changes for documentation impact..."
- Focus on files in key directories: commands/, agents/, src/, lib/, core/

**Grep/search failures:**
- Continue with available data
- Note in report: "⚠️ Some searches were limited due to repository size. Manual verification recommended."

**doc-writer agent unavailable:**
- If Task tool fails to invoke doc-writer agent, stop the auto-update process
- Show error: "⚠️ Error: doc-writer agent is not available. Cannot generate documentation content."
- Provide the analysis report but skip auto-update
- Suggest: "Please install the doc-tools plugin or update documentation manually based on the report above."
- NEVER attempt to write documentation content yourself if the agent is unavailable

**File write/edit failures:**
- Stop update process
- Show error with specific file that failed
- Preserve any successfully applied changes
- Output: "Error updating [file]: [error message]. Please update this file manually."
