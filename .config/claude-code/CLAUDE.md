# Personal Claude Code Guidelines

## Pull Request Best Practices

When creating pull requests, **always** follow these rules:

### 1. Use the Repository's PR Template
- Check for `.github/pull_request_template.md` in the repo
- Follow the template structure exactly - don't create custom formats
- Copy the template and fill in the appropriate sections

### 2. Leave Checkboxes Unchecked
- **Never** pre-check boxes in acceptance criteria or test cases
- Leave all `- [ ]` checkboxes empty for reviewers/QA team to check off
- This is part of the review process workflow

### 3. Pull Acceptance Criteria from JIRA
- **Don't create your own acceptance criteria**
- Copy the acceptance criteria directly from the JIRA ticket
- If the ticket doesn't have clear criteria, ask for clarification

### 4. Follow Template Structure Exactly
- Don't deviate from the provided template format
- Use the exact sections and formatting provided
- Maintain consistency across all pull requests

### Example Workflow
1. Read `.github/pull_request_template.md` first
2. Copy the template structure exactly  
3. Fill in JIRA ticket number and link: `# [PDW-XXXX](https://consumeraffairs.atlassian.net/browse/PDW-XXXX)`
4. Write overview based on actual changes made
5. Copy acceptance criteria from the JIRA ticket (don't create custom ones)
6. Leave all checkboxes unchecked for reviewers
7. Create clear, actionable test cases

This ensures consistency and proper workflow compliance across all repositories.

## Development Workflow - CA Helper Script

For projects in `~/src/github.com/bhoman-ca/`, use the `ca` shell script instead of docker-compose commands:

### Use `ca` Instead of Docker Compose
- **Run tests**: `ca pytest` instead of `docker-compose run --rm django-brands-api pytest`
- **Django shell**: `ca shell` instead of `docker-compose run --rm django-brands-api python manage.py shell`
- **Run commands**: `ca run [command]` instead of `docker-compose run --rm django-brands-api [command]`
- **Django management**: `ca manage [command]` instead of `docker-compose run --rm django-brands-api python manage.py [command]`

### Available CA Commands
The `ca` script provides these shortcuts:
- `ca app` - Print determined app name
- `ca bash` - Open bash shell
- `ca build` - Build docker image
- `ca manage` - Run manage.py commands
- `ca migrate` - Run migrations
- `ca makemigrations` - Run makemigrations
- `ca shell` - Open django shell (uses shell_plus if available)
- `ca test` - Run tests
- `ca pytest` - Run tests with pytest
- `ca run` - Run command in container

### Why Use CA Script?
- Automatically determines the correct service name
- Handles running vs non-running container states
- Provides consistent interface across CA projects
- Located at `~/.local/bin/ca` and available in PATH