---
name: dots
description: Use when the user asks to update, commit, push, or manage dotfiles, or when Claude has made changes to files tracked in the dotfiles bare repo.
---

# Dotfiles Management

## Overview

Dotfiles are tracked in a bare git repo at `~/.dotfiles/`, managed via the `dots` alias. The working tree is `$HOME`. Always use the bare repo git command, never plain `git`.

## The Alias

```bash
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME
```

This is what `dots` expands to. Use it directly in tool calls since aliases aren't available in Bash.

## Workflow

### 1. Show Status

Always start by showing what's dirty:

```bash
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME status
```

Summarize to the user: which files changed, and which are unrelated to the current task.

### 2. Stage Only Relevant Files

Stage files explicitly by path — never use `-A` or `.`:

```bash
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME add ~/.config/tmux/tmux.conf ~/.config/zsh/zshrc
```

Skip unrelated dirty files. If unsure whether to include something, ask.

**Known ignored paths:** `.claude/` is gitignored — don't attempt to stage it.

### 3. Commit with Context

Write a conventional commit message that describes what changed and why:

```bash
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME commit -m "$(cat <<'EOF'
perf: lazy-load thefuck to cut shell startup time

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Group related changes into one commit. Split unrelated changes into separate commits.

### 4. Push

```bash
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push
```

Only push when the user explicitly asks.

### 5. Update Obsidian Vault

After any significant dotfile session, append a brief summary to the vault:

**File:** `~/Documents/vaults/main/Claude/Claude Code - My Custom Setup.md`

Add a dated entry describing what changed and why. Keep it to 2-4 bullet points.

## Key Files & Locations

| Purpose | Path |
|---------|------|
| Shell config | `~/.config/zsh/zshrc` |
| Shell aliases | `~/.config/shell/aliases` |
| Shell functions | `~/.config/shell/functions` |
| tmux config | `~/.config/tmux/tmux.conf` |
| tmuxp profiles | `~/.config/tmuxp/*.yaml` |
| Brewfile | `~/.config/brew/Brewfile` |

## Common Mistakes

- **Using plain `git`** — won't find the bare repo; always use the full `--git-dir` form
- **Staging everything** — unrelated dirty files (e.g. `.claude/`) will cause errors or noise
- **Forgetting to push** — commits stay local until the user asks to push
- **Skipping the Obsidian update** — the vault is the long-term record of setup decisions
