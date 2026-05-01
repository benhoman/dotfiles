# CA Development Guidelines

## Pull Request Workflow

### Template
- Check for `.github/PULL_REQUEST_TEMPLATE.md` (uppercase) and follow it exactly.
- PR title: `PDW-XXXX Ticket title here`
- JIRA link header: `# [PDW-XXXX](https://consumeraffairs.atlassian.net/browse/PDW-XXXX)`
- Overview from the JIRA ticket description; AC copied directly from JIRA as unchecked `- [ ]` checkboxes.
- **Never pre-check boxes** — leave all `- [ ]` empty for reviewers.
- Don't invent acceptance criteria; copy from the ticket or ask.

### Post-PR
After creating a PR: transition ticket to Code Review, set BE Story Points, post in `#eng-prs` Slack. The full automated flow is in the `worktree@ca-worktrees` plugin's `/worktree:wtdev` skill (Phase 7.3).

## Git Commit Convention

- **No** semantic/conventional commit prefixes (`feat:`, `fix:`, `chore:` etc.)
- Prefix with the JIRA ticket number: `PDW-XXXX Description here`
- Example: `PDW-11437 Filter CA employee emails from ChurnZero`

## Git Workflow

- Push to `origin` (your fork), create PRs against `upstream`
- Branch from `upstream/qa` unless told otherwise
- PR target branch is `qa` unless told otherwise

## Worktree Projects

When `.worktrees/config.toml` or `.worktree.toml` exists, use `wt` commands — never `ca script`, raw `docker compose`, `pytest`, or `manage.py` directly. Command mapping is in the `worktree@ca-worktrees` plugin's `/worktree:worktree` SKILL.md.

## JIRA Field Mappings (PDW)

Use this when editing tickets via raw MCP outside the plugin skills.

| Field | Key | Notes |
| --- | --- | --- |
| Ticket Description | `customfield_12881` | Rich text (ADF). **Primary description field.** |
| Acceptance Criteria | `customfield_12819` | Rich text (ADF). |
| Sprint Team | `customfield_12615` | Select. |
| BE Story Points (actual) | `customfield_12750` | Numeric (decimals OK). Set post-PR via separate `editJiraIssue` — not on the Code Review transition screen. |
| Standard `description` | — | **Leave empty.** All description content goes in `customfield_12881`. |
| Code Review transition | id `431` | `transitionJiraIssue` first, then `editJiraIssue` for `customfield_12750` — two separate calls. |

Never invent Components, Sprint Teams, or Labels — fetch existing values from JIRA metadata first and confirm with the user before creating a ticket.

## Testing

- Never use bare `assert` statements — follow existing test patterns in the repo.
- Read 2-3 existing test files before creating a new one to match the project style.
- Use existing fixtures and factories — don't create new ones without checking what's already there.
