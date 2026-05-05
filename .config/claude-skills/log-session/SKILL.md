---
name: log-session
description: Append a session retrospective entry to the personal Obsidian log at ~/Documents/vaults/main/Claude/Wrap-Up Log/YYYY-MM.md. Called automatically by the `wrap-up` skill when present, or invoked directly via `/log-session` to record a one-off incident with no config change. Personal — only useful if the vault path exists.
argument-hint: "[entry payload as Markdown, or empty to be prompted]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(date:*)
  - Bash(mkdir:*)
  - Bash(test:*)
  - Bash(ls:*)
---

# /log-session — Append to Obsidian Wrap-Up Log

**Usage**: `/log-session [entry payload]`

**Description**: Append a single retrospective entry to the personal Obsidian wrap-up log. Designed to be called by the `wrap-up` skill (which collects friction points and proposes config changes) but also runnable directly to record a one-off incident.

This skill is intentionally **personal**. It only does anything if `~/Documents/vaults/main/Claude/Wrap-Up Log/` exists. If the directory is missing, the skill exits silently (so `wrap-up` can be shared with others without forcing them to maintain a log).

---

## Procedure

1. **Check vault path exists.** Run `test -d ~/Documents/vaults/main/"Claude Wrap-Up Log"`. If it doesn't exist, exit with a one-line message: `log-session: vault path not configured, skipping`. Do not create the directory automatically — its absence is the opt-out signal.

2. **Resolve filenames.**
   - Today's date: `date +%Y-%m-%d`
   - Month file: `~/Documents/vaults/main/Claude/Wrap-Up Log/$(date +%Y-%m).md`
   - Index (read-only reference): `~/Documents/vaults/main/Claude/Wrap-Up Log/_index.md`

3. **Collect the entry.** Prefer the structured payload passed by the caller (the `wrap-up` skill). If invoked directly with no `$ARGUMENTS`, ask the user for:
   - Short title
   - Friction (1-2 lines)
   - Category: `behavior` | `knowledge gap` | `tooling` | `already-covered`
   - Root cause (optional, 1 line)
   - Change made (file edited + summary, or "none")
   - Tags (e.g. `#jira #git`)

4. **Format the entry:**
   ```markdown
   ## YYYY-MM-DD — <title>
   **Friction:** <…>
   **Category:** <…>
   **Root cause:** <…>
   **Change:** <…>
   **Tag:** <#tags>
   ```

5. **Append to the month file.**
   - If the month file doesn't exist, create it with this header:
     ```markdown
     ---
     tags: [claude-code, wrap-up-log]
     ---

     # YYYY-MM
     ```
     Then append the entry below the heading.
   - If it exists, insert the new entry **immediately after the `# YYYY-MM` heading** (newest at top), separated by a blank line from the next entry.

6. **Never modify `_index.md`.** That file is hand-curated by the user.

7. **Output one line** confirming what was written: `Logged: <month file>`.

---

## Constraints

- **Read first.** Always `Read` the month file before editing so the insertion point is correct.
- **One entry per call.** Multiple findings from a single `/wrap-up` should each be a separate `/log-session` call (or, if called with a multi-entry payload, the caller pre-formats them and this skill writes them as a single block under one date heading).
- **Don't dedupe.** If two entries look similar across days, that's signal — let the user notice it via the index, don't squash automatically.
- **No secrets.** Never write tokens, credentials, or API keys to the log.
