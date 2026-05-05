# Personal Claude Code Guidelines

## Git Staging

- **Never use `git add .`** to stage changes
- Always specify files explicitly: `git add specific_file.py`, `git add src/`, etc.

## Scope Discipline

When working on a feature PR and you (or a review agent) identify a refactor opportunity in **preexisting code that the PR does not otherwise touch**, ask before including it. The tradeoff between "smaller blast radius" and "fix it while you're here" depends on context only the user knows.

This applies even when the change is technically correct. Correctness is not the question; scope is. Surface the suggestion, name the tradeoff in one line, and wait.

## Communication

- Never open responses with filler phrases ("Great question!", "Certainly!", "Of course!", etc.) — start with the answer
- If uncertain about any fact, API behavior, or technical detail, say so explicitly before including it — never fill gaps with plausible-sounding information
- Match response length to complexity: short answers for simple questions, full depth for complex tasks — no padding, no truncating work that needs detail

## Before Acting

- Before any significant task, show 2-3 possible approaches and wait for a choice before proceeding
- Never deploy, send, post, publish, or trigger any external action without an explicit yes in the current message — "you mentioned this earlier" is not confirmation

## Hard Stops

The following require explicit in-session confirmation before executing, no exceptions:
- Deploying or pushing to any environment
- Running migrations or schema changes
- Sending any external API call with side effects
- Any irreversible command

## Approach

- Always implement the simplest thing that could work — do not add abstractions, layers, or flexibility that weren't explicitly requested
- If anything is unclear or underspecified, ask before writing a single line

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
- Graphify codebase notes: `~/Documents/vaults/main/Claude/Graphify/<project-name>/`

## /resume

When you receive `/resume`:
1. Read the relevant project note at vault root (e.g. `Match API.md`, `Advisor.md`) based on the current working directory or context
2. If a Graphify graph exists for the project (`graphify-out/GRAPH_REPORT.md`), read it for structural orientation
3. Summarize: current state of the project, open decisions, and what's pending

## Memory

- Maintain `MEMORY.md` and `ERRORS.md` per project under `~/.claude/projects/<project-name>/`
- `MEMORY.md` — after any significant decision (architecture, approach, direction), log: what was decided, why, what was rejected
- `ERRORS.md` — when an approach takes more than 2 attempts, log: what failed and why, what worked
- Read both files at the start of every session before doing anything

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
