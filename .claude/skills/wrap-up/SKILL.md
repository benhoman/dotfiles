---
name: wrap-up
description: Analyze the current session for friction (corrections, retries, missed conventions, wasted tool calls) and propose concrete edits to user/project Claude config — global CLAUDE.md, project CLAUDE.md / CLAUDE.local.md, auto-memory, settings.json, or a new skill — to prevent recurrence. Trigger when the user asks to "wrap up", "review this session", "what could we improve", "post-mortem this conversation", or runs `/wrap-up`. Read-only until the user approves edits.
argument-hint: "[optional focus, e.g. 'jira' or 'tests'] or empty for full session review"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(ls:*)
  - Bash(cat:*)
  - Bash(find:*)
  - Bash(git log:*)
  - Bash(git diff:*)
  - Edit
  - Write
  - Skill
---

# /wrap-up — Session Retrospective & Config Tuning

**Usage**: `/wrap-up [focus]`

**Description**: Review **this conversation** end-to-end, surface anything that went wrong or required course correction, and propose concrete config changes to prevent it next time. The skill is read-only by default — it produces a structured report and waits for explicit approval before writing anything.

**Examples**:

- `/wrap-up` — full session review
- `/wrap-up jira` — focus only on JIRA-related friction
- `/wrap-up tests` — focus on test/lint/CI friction
- `/wrap-up --log-only` — invoke the `log-session` skill (if present) to record a notable event without proposing config changes
- `/wrap-up --no-log` — skip the optional `log-session` invocation even if it's installed

---

## What this skill does

1. **Scans the conversation transcript** for friction signals:
   - Explicit corrections ("no", "don't", "stop", "actually", "instead", "wait")
   - Retries after a tool failure or wrong-shape output
   - Re-reads of files that should have been read the first time
   - Convention violations (commit format, branch naming, JIRA fields, ruff rules, `wt` vs raw `docker compose`, PR template, etc.)
   - Wasted tool calls (parallelizable calls run serially, redundant searches, exploration that a memory or doc would have short-circuited)
   - Clarifying questions whose answers were already in the existing config
   - Places I should have asked but guessed

2. **Categorizes each finding**:
   - **Behavior** — something I did that an instruction could have prevented
   - **Knowledge gap** — something I didn't know that documentation could have provided
   - **Tooling** — a hook, permission, or skill that would have removed friction
   - **Already-covered-but-ignored** — instruction existed and I didn't follow it (root-cause this; the rule may need to be stronger or repositioned)

3. **Proposes concrete edits**, ranked by impact, to one of:
   - `~/.claude/CLAUDE.md` — global personal rules (every project)
   - `<project>/CLAUDE.md` — checked-in project rules
   - `<project>/CLAUDE.local.md` — gitignored personal project rules
   - `~/.claude/projects/<slug>/memory/` — auto-memory (durable preferences/feedback that don't belong in CLAUDE.md)
   - `~/.claude/settings.json` — hooks, permissions, env vars (delegate to the `update-config` skill when this is the target)
   - A new or updated skill in `~/.claude/skills/` or `.claude-plugin/skills/`

   Each proposed edit shows the **exact diff or new content** so you can approve/reject inline.

4. **Skips the noise.** Don't propose changes for:
   - One-off mistakes unlikely to recur
   - Things already covered well (note them as "working as intended")
   - Changes that would over-constrain me on tasks where flexibility matters

---

## Output format

Single Markdown report:

```
## What went well
- <terse bullets, only if relevant>

## Friction points
### 1. <short title>
- **What happened:** <1-2 lines, reference the turn>
- **Category:** behavior | knowledge gap | tooling | already-covered
- **Root cause:** <why it happened>
- **Proposed fix:** <where + exact text/diff>
- **Impact:** high | medium | low

### 2. ...

## Recommended changes (ranked)
1. <one-line summary> — <target file>
2. ...

## No-action items
- <things noticed but not worth a rule>
```

If the session was clean, output a short "no actionable findings" report and stop. Don't manufacture friction.

---

## Procedure

1. **Read context first.** Before proposing any edit, `Read` the target file (CLAUDE.md, settings.json, memory index, etc.) so the proposed diff is against current reality, not a guess. Skip files that don't exist; mention them as "would create new".

2. **Check auto-memory.** Read `~/.claude/projects/<project-slug>/memory/MEMORY.md` if present — proposed feedback/project memories should update existing entries rather than duplicate them.

3. **Decide scope before file.** For each finding ask: does this apply *everywhere I work* (global), *only this project* (project), *only my workflow in this project* (local), or *only as a reactive correction* (memory)? Pick the narrowest scope that solves it.

4. **Auto-memory vs CLAUDE.md heuristic:**
   - Stable conventions, reference info, command mappings → CLAUDE.md
   - Rules with a clear *why* and *when to apply* (especially correction-driven) → auto-memory (`feedback` or `project` type)

5. **Settings.json changes** (hooks, permissions, env): delegate to the `update-config` skill — don't hand-edit the JSON.

6. **Present the report**, then **wait for approval** before writing any file. Apply only what the user green-lights, in a single batch when possible.

7. **After applying**, summarize what was written in one or two lines. Don't re-explain the rationale — the user already approved it.

8. **Optionally log the session.** Logging is delegated to a separate `log-session` skill so this skill can be shared without forcing anyone to maintain a personal log.
   - **Skip the log step entirely** if the user passed `--no-log`.
   - Otherwise, check whether `log-session` is in the available skills list. If yes, invoke it via the `Skill` tool with a structured payload (one block per friction point — title, friction, category, root cause, change, tags). The `log-session` skill itself will silently no-op if its target vault path doesn't exist, so it's safe to call.
   - If `log-session` is **not installed**, skip silently — don't try to write to a vault directly from this skill.
   - If the user passed `--log-only`, skip the friction analysis and config-edit proposal entirely; just gather a one-line summary of the session's notable event from the user (or the active context) and pass it to `log-session`.

---

## Constraints

- **Read, don't guess.** Never write a CLAUDE.md edit without reading the current file.
- **Don't duplicate.** If a proposed rule overlaps with an existing one, propose an *update* to the existing entry, not a new entry.
- **Don't over-constrain.** Rules should target the specific failure mode, not a broad "always do X" that will mis-fire on different tasks.
- **Never write secrets** to memory or CLAUDE.md.
- **No silent edits.** Even after approval, name each file written so the user can spot-check.
