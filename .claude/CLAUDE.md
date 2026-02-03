# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is AI Automation Hub - a collection of reusable slash commands and plugins for Claude Code.   
Plugins provide custom slash commands that extend Claude Code's functionality. 
Claude code marketplace official documentation - https://code.claude.com/docs/en/plugin-marketplaces

## Repository Structure

```
plugins/
├── commits/     # Git commit message generation commands
├── code-review/         # Code review commands (in development)
├── testing-api/         # API testing commands (in development)
├── testing-unit/        # Unit testing commands (in development)
└── testing-data-generation/  # Test data generation (in development)
```

## Plugin Architecture

Each plugin follows this structure:
- `.claude-plugin/plugin.json` - Plugin metadata and configuration [Plugins off documentation](https://code.claude.com/docs/en/plugins)
- `commands/*.md` - (optional) Slash command definitions in markdown format [Commands off documentation](https://code.claude.com/docs/en/slash-commands)
- `agents/*.md` - (optional) Agents instructions in markdown format [Sub-agents off documentation](https://code.claude.com/docs/en/sub-agents)
- `SKILL/` - (optional) Skill definitions in markdown format [SKILL off documentation](https://code.claude.com/docs/en/skills)
- `hooks/` - (optional) Event-driven shell scripts triggered by Claude Code actions [Hookd off documentation](https://code.claude.com/docs/en/hooks-guide)
- `mcp/` - (optional) Model Context Protocol server configurations [MCP off documentation](https://code.claude.com/docs/en/mcp)

### Command File Format

Commands are markdown files with YAML frontmatter:

```markdown
---
description: "Brief description of the command"
allowed-tools:
  [
    "Bash(git status:*)",
    "Bash(git diff:*)"
  ]
---

## Context
- Dynamic context using inline shell: !`git status`

## Task
Instructions for Claude to execute
```

Key elements:
- `description`: Shown in command help
- `allowed-tools`: Whitelist of tools the command can use (security boundary)
- `!` backtick syntax: Executes shell commands inline to populate context

## Creating New Plugins

1. Create a new directory under `plugins/`
2. Add `.claude-plugin/plugin.json` with plugin metadata
3. Add command files in optional directory
4. Follow the frontmatter format with description and allowed-tools
