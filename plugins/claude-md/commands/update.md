---
description: "Recursively validate and update all CLAUDE.md files (root and nested) to keep instructions consistent"
allowed-tools:
  [
    "Bash(find . -name CLAUDE.md:*)",
    "Bash(cat:*)",
    "Bash(git diff:*)",
    "Bash(apply_patch:*)"
  ]
---
Recursively scan the repository and locate all CLAUDE.md files (root and nested).

For each CLAUDE.md:
- Verify that the instructions match the current repository structure, modules, and responsibilities.
- Update outdated paths, folder names, architectural descriptions, and rules.
- Preserve intent and tone; only fix inaccuracies or missing information.
- Do NOT invent new rules or remove existing ones unless they are clearly obsolete.
- Keep instructions concise and consistent across all CLAUDE.md files.

Rules:
- Update files in place.
- If a CLAUDE.md is already correct, leave it unchanged.
- Ensure the root CLAUDE.md remains the source of global rules; nested files may only contain local overrides.
- Do not modify code or any non-CLAUDE.md files.

After completion:
- Output a short summary listing which CLAUDE.md files were updated and why.