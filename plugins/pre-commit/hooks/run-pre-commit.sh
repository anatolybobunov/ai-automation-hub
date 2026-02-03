#!/bin/bash
# Pre-commit hook runner for Claude Code
# Runs pre-commit checks on edited/written files if .pre-commit-config.yaml exists

set -e

# Read JSON input from stdin
input=$(cat)

# Extract file path from tool_input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Exit if no file path
if [ -z "$file_path" ]; then
    exit 0
fi

# Check if file exists
if [ ! -f "$file_path" ]; then
    exit 0
fi

# Get project directory (use CLAUDE_PROJECT_DIR if available, otherwise find git root)
if [ -n "$CLAUDE_PROJECT_DIR" ]; then
    project_dir="$CLAUDE_PROJECT_DIR"
else
    project_dir=$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null || echo "")
fi

# Exit if not in a git repo
if [ -z "$project_dir" ]; then
    exit 0
fi

# Check if pre-commit config exists
config_file="$project_dir/.pre-commit-config.yaml"
if [ ! -f "$config_file" ]; then
    exit 0
fi

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "pre-commit is not installed. Skipping checks."
    exit 0
fi

# Run pre-commit on the specific file
cd "$project_dir"
echo "Running pre-commit on: $file_path"
pre-commit run --files "$file_path" || true
