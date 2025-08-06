# JIRA Start Workflow

**Usage**: `/jira-start <ticket-number>`

**Description**: Automates the git workflow and JIRA ticket processing for starting work on a ticket using Claude's MCP Atlassian integration.

**Example**: `/jira-start PDW-1234`

## What this command does

1. **JIRA Integration** (via MCP):
   - Uses Claude's built-in Atlassian MCP integration to fetch ticket details
   - Automatically discovers your Atlassian cloud ID
   - Displays comprehensive ticket information:
     - Title, description, issue type, status, priority
     - Assignee information
     - Acceptance criteria (from custom fields)
     - JIRA ticket URL for reference

2. **Git Workflow Automation**:
   - Creates a git worktree with a new branch based off upstream qa
   - Command: `mkdir -p worktrees && git fetch upstream qa && git worktree add worktrees/<ticket-number> upstream/qa && cd worktrees/<ticket-number> && git checkout -b <ticket-number>-<sanitized-title>`
   - Ticket number is converted to uppercase
   - Title is converted to lowercase, spaces to dashes, non-alphanumeric removed
   - Creates worktree as a subdirectory to keep everything contained
   - Changes to the worktree directory for continued work
   - **Requires only one permission approval** for all git operations

3. **Worktree Navigation**:
   - Automatically changes to the new worktree directory after creation
   - All subsequent Claude Code operations will happen in the worktree
   - Ensures work is isolated from the main repository

4. **User Review & Confirmation**:
   - Shows ticket details first, then requests approval for assessing the ticket request and coming up with a suggested plan to show the user.
   - Provides planning guidance for implementation

## Prerequisites

- Claude Code must be authenticated with Atlassian (MCP integration handles this)
- Access to the ConsumerAffairs Atlassian instance
- Git repository with `upstream` remote configured
- Current working directory must be the git repository

## Implementation Details

This command leverages Claude's MCP Atlassian integration to:

- Automatically authenticate with your Atlassian instance
- Fetch ticket details without manual API token setup
- Handle Atlassian Document Format (ADF) content parsing
- Extract acceptance criteria from custom fields
- Provide rich ticket information display

The git operations include full error handling and will stop execution if any step fails, ensuring your repository stays in a clean state.
