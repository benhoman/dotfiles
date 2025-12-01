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

## JIRA Field Mappings

### Ticket Fields

- **Summary**: `summary` (string)
- **Description**: `customfield_12881` (Atlassian Document Format - ADF)
- **Acceptance Criteria**: `customfield_12819` (Atlassian Document Format - ADF)

### Field Details

- `customfield_12881` = Description field (rich text in ADF format)
- `customfield_12819` = Acceptance Criteria field (rich text in ADF format)
- `summary` = Ticket title/summary (plain text)

### Usage Notes

- ADF (Atlassian Document Format) is required for rich text fields
- Use proper ADF structure with paragraphs, headings, lists, and code formatting
- Code blocks use `{"type": "text", "text": "code", "marks": [{"type": "code"}]}`
- Headings use `{"type": "heading", "attrs": {"level": 3}, "content": [...]}`

## Git Staging Guidelines

### Explicit File Staging

- **Never use `git add .`** to stage changes
- Always specify files explicitly when staging:
  - `git add specific_file.py` for individual files
  - `git add src/` for specific directories
  - `git add *.js` for file patterns when appropriate
- This ensures intentional staging and prevents accidental commits of unwanted files


## Language specific - Python

### Typing
- Always add typing where possible when writing new code.
- Use Python 3.10+ typing style when possible.

### Codestyle
- Make sure when writing the code its formatted correctly the way ruff would format it.
- Also follow all ruff linting guidelines. Use the pyproject.toml file to for project specific details.
- NEVER import a module within a function/class/module unless it's absolutely necessary to avoid a circular import error. ALWAYS prefer importing at the top of the file and sort it correctly according to the linter.
- Do the imports after implementing the code so the linter doesn't remove the import