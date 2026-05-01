# Personal Claude Code Guidelines

## Git Staging

- **Never use `git add .`** to stage changes
- Always specify files explicitly: `git add specific_file.py`, `git add src/`, etc.

## Scope Discipline

When working on a feature PR and you (or a review agent) identify a refactor opportunity in **preexisting code that the PR does not otherwise touch**, ask before including it. The tradeoff between "smaller blast radius" and "fix it while you're here" depends on context only the user knows.

This applies even when the change is technically correct. Correctness is not the question; scope is. Surface the suggestion, name the tradeoff in one line, and wait.

## Language — Python

### Typing
- Always add typing where possible when writing new code.
- Use Python 3.10+ typing style.

### Codestyle
- Format code the way ruff would. Follow all ruff linting guidelines; use `pyproject.toml` for project-specific config.
- Never import a module inside a function/class/method unless strictly necessary to avoid a circular import. Always import at the top of the file, sorted correctly.
- Do imports after implementing the code so the linter doesn't remove them.

## Obsidian Vault

- Personal vault: `~/Documents/vaults/main/`
- Claude-related notes: `~/Documents/vaults/main/Claude/`
- Session retrospective log (written by `log-session`, called by `wrap-up`): `~/Documents/vaults/main/Claude/Wrap-Up Log/YYYY-MM.md`
  - Append-only month files, newest entries at top.
  - `_index.md` is hand-curated — do not auto-rewrite it.
