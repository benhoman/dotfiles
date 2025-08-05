# Guided Commit Workflow

**Usage**: `/guided-commit`

**Description**: Guides you through creating strategic commits based on implemented functionality, with automatic ticket prefixing and intelligent file grouping.

## What this command does

1. **Context Analysis**:
   - Analyzes current git status to understand staged/unstaged changes
   - Reviews recent commit history to understand existing patterns
   - Extracts ticket number from branch name (format: `PDW-XXXX-description`)
   - Examines changed files to understand the scope of work

2. **Strategic Commit Planning**:
   - Groups related changes logically (features, fixes, refactoring, tests, docs)
   - Suggests meaningful commit messages based on actual changes made
   - Considers creating multiple commits if changes are unrelated
   - Crafts messages that explain the "why" rather than just the "what"

3. **Smart Git Operations**:
   - Uses `git add` with explicit file paths (never `git add .`)
   - Chains git commands efficiently where possible
   - Always pushes to `origin` (never `upstream` directly)
   - Handles pre-commit hook failures with retry logic

4. **Commit Message Format**:
   - Always prefixes with ticket number from branch name
   - Follows format: `PDW-XXXX: descriptive message about the change`
   - Focuses on business value and functionality impact
   - Includes context about why the change was made

## Examples

**Single focused commit**:
```
PDW-9438: add base scraper classes for third-party review extraction

Implements foundational scraper architecture to support extracting 
reviews from external platforms like BirdsEye, Trustpilot, etc.
```

**Multiple strategic commits**:
```
PDW-9438: implement BaseExtractor abstract class for review scraping
PDW-9438: add configuration system for third-party scraper settings  
PDW-9438: create unit tests for base scraper functionality
```

## Workflow Steps

1. **Analysis Phase**: Reviews git status, diff, and recent commits
2. **Planning Phase**: Suggests commit strategy and messages
3. **Confirmation Phase**: Shows planned commits for user approval
4. **Execution Phase**: Executes git commands with explicit file staging
5. **Verification Phase**: Confirms commits were created successfully

## Safety Features

- Never stages files without explicit paths
- Always pushes to `origin` remote only
- Handles pre-commit hooks gracefully with retry logic
- Stops execution if any git command fails
- Shows full diff context before committing

## Prerequisites

- Must be in a git repository
- Changes must exist (staged or unstaged)
- Branch name should follow `PDW-XXXX-description` format
- Remote `origin` must be configured

## Implementation Notes

This command prioritizes thoughtful, strategic commits that:
- Tell a clear story about what was built and why
- Group related functionality appropriately
- Follow team conventions for commit messaging
- Maintain clean git history for effective code review