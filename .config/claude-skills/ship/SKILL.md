---
name: ship
description: Commit + push + create-or-update PR in one shot, honoring per-repo conventions (CA project ticket prefixes, ca-worktrees Conventional Commits, generic repos). Detects existing PRs and pushes updates instead of recreating. Runs the post-PR JIRA flow (Code Review transition, story points, #eng-prs Slack reminder) on new CA project PRs. Use when the user says "ship it", "commit and push", "ship this", or runs `/ship`.
argument-hint: "[optional commit message]"
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash(git:*)
  - Bash(gh:*)
  - Bash(wt:*)
  - Bash(test:*)
  - Bash(ls:*)
  - Bash(cat:*)
  - AskUserQuestion
---

# /ship — One-Shot Commit, Push, PR

**Usage**: `/ship [optional commit message]`

**Description**: Single entry point that commits staged changes, pushes to `origin`, and either updates an existing open PR or creates a new one — all while honoring the active repo's conventions. On CA project branches, also runs the post-PR JIRA flow.

The skill **never auto-stages** beyond what's already staged. If nothing is staged but the working tree is dirty, it asks which files to stage before proceeding.

## When to invoke

- User says "ship it", "ship this", "commit and push", "send it", or runs `/ship`.
- User has finished a unit of work and wants the full commit→push→PR flow.

## When NOT to invoke

- User explicitly asked for only a commit (`/worktree:commit`) or only a PR (`/create-pr-enhanced`) — honor the narrower request.
- Working in detached HEAD or directly on `main` / `qa` / `master` / `dev` — abort with a clear message.

---

## Phase 1 — Repo + branch detection

Run these in parallel:

```bash
git rev-parse --abbrev-ref HEAD                    # current branch
git rev-parse --show-toplevel                      # repo root
git status --porcelain                             # staged + unstaged
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null  # upstream (may fail)
test -f .worktrees/config.toml -o -f .worktree.toml && echo "worktree-enabled"
test -f .claude-plugin/plugin.json && echo "ca-worktrees-repo"
```

Classify the repo into one of three modes:

| Mode | Detection | Commit format | PR flow |
| --- | --- | --- | --- |
| **CA project** | branch matches `^[A-Z]+-[0-9]+` AND not in `ca-worktrees` repo | `PDW-XXXX Description` (hook enforces) | Read `.github/PULL_REQUEST_TEMPLATE.md`, populate from JIRA, post-PR flow runs |
| **ca-worktrees** | `.claude-plugin/plugin.json` exists in repo root | Delegate to `/worktree:commit` (Conventional Commits) | Plain PR, no JIRA |
| **Generic** | Neither of the above | Plain `git commit -m "<msg>"` | Plain PR, no JIRA |

**Abort conditions:**
- Detached HEAD (`git rev-parse --abbrev-ref HEAD` returns `HEAD`)
- Branch is `main`, `master`, `qa`, `dev`, or `develop`
- Working tree completely clean AND `git log @{u}..HEAD` is empty (nothing to ship)

In all abort cases, print a one-line reason and stop.

---

## Phase 2 — Staging

Read `git status --porcelain` output:

- **Lines starting with non-space in column 1** = staged.
- **Lines starting with space then non-space in column 2** = unstaged modifications.
- **`??`** = untracked.

Decision tree:

1. **Anything staged + nothing else dirty** → proceed with what's staged.
2. **Anything staged + other modifications/untracked** → use `AskUserQuestion`:
   ```
   You have N staged file(s) plus M unstaged change(s) and K untracked file(s):
     <list each unstaged/untracked path, max 15>
   What should I do?
   ```
   Options:
   - "Ship only what's staged" — proceed with current staging
   - "Stage everything and ship" — `git add` each listed file explicitly (never `git add .`)
   - "Let me stage manually" — abort, tell user to stage and re-run
3. **Nothing staged + dirty working tree** → use `AskUserQuestion` listing files (max 15), options:
   - "Stage all listed and ship"
   - "Let me stage manually" — abort
4. **Nothing staged + clean tree + commits ahead of upstream** → skip to Phase 4 (commit phase is a no-op).
5. **Nothing staged + clean tree + nothing ahead** → abort, "Nothing to ship."

When staging files in option 2/3, list each path explicitly: `git add "path/to/file1" "path/to/file2"`. Per global config, never use `git add .`.

---

## Phase 3 — Commit

Skip this phase entirely if nothing is staged after Phase 2 (commits-ahead-only case).

### Mode: ca-worktrees

Invoke the plugin's commit skill via the `Skill` tool:

```
Skill(skill: "worktree:commit")
```

Pass through the user's commit message argument if provided. The plugin handles Conventional Commits formatting, GH issue trailer detection, and the `wt-reviewer` opt-in (which `/ship` does not pass).

If the skill invocation fails or the user cancels inside it, abort `/ship` cleanly — don't push or create a PR with no commit.

### Mode: CA project

Build the commit message:

1. **If user passed an argument** to `/ship`, use it as the description.
2. **Otherwise**, generate a one-line description from the diff:
   ```bash
   git diff --cached --stat
   git diff --cached
   ```
   Summarize as a single imperative sentence (e.g., "Filter CA employee emails from ChurnZero"). Do not write a multi-line commit body unless the diff is large enough to warrant it.

3. **Extract ticket prefix** from branch: `echo "$BRANCH" | grep -oE '^[A-Z]+-[0-9]+'`
4. **Final message**: `<TICKET> <Description>` — exactly the format `enforce-ticket-prefix.sh` expects.

5. **Confirm with user** via `AskUserQuestion` before committing:
   ```
   AskUserQuestion(
     question: "Commit message:\n\n  <full proposed message>\n\nProceed?",
     options: [
       { label: "Commit as-is",  description: "Use this message" },
       { label: "Edit subject",  description: "Type a replacement subject" },
       { label: "Cancel",        description: "Abort without committing" }
     ]
   )
   ```
   If "Edit subject", prompt for the new subject and rebuild the message, then re-confirm. Loop until the user approves or cancels.

6. Commit using a HEREDOC for safety:
   ```bash
   git commit -m "$(cat <<'EOF'
   PDW-XXXX Description here
   EOF
   )"
   ```

If the hook blocks the commit, surface the hook's stderr verbatim and abort. Don't try to "fix" the message automatically — the user needs to see what was rejected.

### Mode: Generic

Same as CA project but without the ticket prefix. Use the user's message argument or generate a one-line description from the diff. Confirm with `AskUserQuestion` (same options as CA project mode) before committing. Plain `git commit -m "..."` via HEREDOC.

---

## Phase 4 — Push

Determine push target:

```bash
git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null
```

- **No upstream set** → `git push -u origin "$BRANCH"`
- **Upstream is `origin/<branch>`** → `git push`
- **Upstream is something other than origin** (rare) → `git push origin "$BRANCH"` (always push to origin per CA convention; don't push to upstream remote)

If push fails (rejected, conflicts, network), surface the error and abort. Don't try to `--force` or rebase automatically.

---

## Phase 5 — PR detection

Check for an existing open PR for this branch:

```bash
gh pr list --head "$BRANCH" --state open --json number,url,title,baseRefName --limit 1
```

- **Empty result** → Phase 6 (create PR)
- **One PR** → Print "Updated existing PR: <url>" and stop. The push in Phase 4 already updated the PR. **Skip the post-PR JIRA flow** — that ran when the PR was first created.

If `gh` isn't authenticated or fails, surface the error and tell the user to run `gh auth login`. Don't fall back to a different workflow.

---

## Phase 6 — Create PR

### Determine base branch

CA conventions: target `qa` unless the user specified otherwise via the user's prompt context. Verify the base exists on upstream:

```bash
git ls-remote --heads upstream qa
```

If `upstream` remote isn't configured, fall back to `origin`. If neither has the base branch, ask the user via `AskUserQuestion` which base to target.

### Read the PR template

```bash
test -f .github/PULL_REQUEST_TEMPLATE.md && cat .github/PULL_REQUEST_TEMPLATE.md
test -f .github/pull_request_template.md && cat .github/pull_request_template.md
test -f PULL_REQUEST_TEMPLATE.md && cat PULL_REQUEST_TEMPLATE.md
```

If none exists, generate a minimal body (overview + test plan).

### Mode: CA project — populate template from JIRA

Fetch ticket details. Try `wt jira` first, fall back to MCP:

```bash
# Preferred (works in worktree-enabled projects)
wt jira get "$TICKET" --full 2>/dev/null
```

If `wt jira` isn't available or fails, use MCP:
```
mcp__atlassian__getJiraIssue(cloudId, "$TICKET")
```
(Cloud ID via `mcp__atlassian__getAccessibleAtlassianResources` — first resource.)

Populate the template:
- Replace any `PDW-XXXX` / `PDW-XXX` placeholders with the actual ticket key
- Add the JIRA link: `# [<TICKET>](https://consumeraffairs.atlassian.net/browse/<TICKET>)` if the template has no header line
- Drop the JIRA description (from `customfield_12881`, with fallback to `description` for legacy tickets) into the Overview section
- Convert AC (from `customfield_12819`) into unchecked `- [ ]` checkboxes
- **Leave all checkboxes unchecked** — per global rule
- Use the JIRA ticket title as the PR title prefixed with the ticket: `<TICKET> <Title>`

### Mode: ca-worktrees / Generic — minimal body

- PR title: extracted from the most recent commit message subject
- Body: read template if exists, otherwise:
  ```markdown
  ## Summary

  <one to three bullets summarizing the diff>

  ## Test plan

  - [ ] <inferred from changed files>
  ```

### Submit

```bash
gh pr create \
  --base "$BASE_BRANCH" \
  --head "$BRANCH" \
  --title "$PR_TITLE" \
  --body "$(cat <<'EOF'
$PR_BODY
EOF
)"
```

Capture the PR URL from `gh pr create` output. Print it.

---

## Phase 7 — Post-PR JIRA flow (CA project mode, new PR only)

Skip this phase if:
- Mode is `ca-worktrees` or `generic`
- An existing PR was updated (Phase 5 hit), not newly created

### Step 1 — Ask about JIRA updates

```
AskUserQuestion(
  question: "PR created: <url>\n\nMove the ticket to Code Review and update story points?",
  options: [
    { label: "Yes", description: "I'll provide story points" },
    { label: "No", description: "I'll handle JIRA manually" }
  ]
)
```

### Step 2 — If yes, ask for story points

```
AskUserQuestion(
  question: "How many story points should I set on BE Story Points (actual)?",
  options: [
    { label: "0.5", description: "Trivial" },
    { label: "1", description: "Small" },
    { label: "2", description: "Medium" },
    { label: "3", description: "Large" },
    { label: "5", description: "Very large" },
    { label: "Other", description: "I'll type a value" }
  ]
)
```

If "Other", prompt for the numeric value via a follow-up.

### Step 3 — Apply transition + story points

Try `wt jira` first:
```bash
wt jira transition "$TICKET" "Code Review"
wt jira set-field "$TICKET" be-story-points "$POINTS"
```

Fall back to raw MCP if `wt jira` isn't available:
```
mcp__atlassian__transitionJiraIssue(cloudId, "$TICKET", { transition: { id: "431" } })
mcp__atlassian__editJiraIssue(cloudId, "$TICKET", { fields: { customfield_12750: <POINTS> } })
```

Note: per global config, `customfield_12750` is **not** on the transition screen, so transition and edit must be two separate calls. Don't combine them.

### Step 4 — Slack reminder

Print exactly:

```
Please post in #eng-prs Slack channel:

Ticket: <TICKET>
Title: <ticket title from JIRA>
PR URL: <pr url>
```

Don't post for the user. Don't auto-copy. Just print the block.

---

## Final output

End with a one-line summary:

- New PR created: `Shipped <TICKET>: <pr url>`
- Existing PR updated: `Updated <TICKET>: <pr url> (no JIRA changes)`
- Commit-only (no upstream changes pushed because nothing to push): `Committed <TICKET>: <sha>`

---

## Failure modes — what to do

| Failure | Action |
| --- | --- |
| Commit hook rejects message | Surface stderr verbatim, abort. Don't auto-fix. |
| `git push` rejected (non-fast-forward) | Surface error, suggest `git pull --rebase` or `/worktree:rebase`. Abort. |
| `gh` not authenticated | Tell user to `gh auth login`. Abort. |
| `gh pr create` fails | Surface error. Branch is pushed but no PR — user can re-run `/ship` to retry the PR step (Phase 5 will detect no PR exists and try again). |
| `wt jira transition` fails | Try MCP fallback. If MCP also fails, print the manual JIRA URL and ticket details, abort the post-PR flow but keep the PR. |
| User cancels at any AskUserQuestion | Treat the in-progress phase as cancelled. Stop cleanly — don't unwind earlier phases. |

---

## Notes for the model

- This skill orchestrates other skills (`/worktree:commit`) and tools (`gh`, `wt`, MCP). It's an integration layer, not a reimplementation.
- Never use `git add .` or `git add -A`. Stage files by explicit path.
- Never use `--no-verify` to bypass the commit hook. The hook is correct; if it rejects, the message is wrong.
- Never `git push --force` or `--force-with-lease` from this skill. If a normal push fails, abort and let the user resolve.
- The post-PR flow is **only on first creation**. Updating an existing PR doesn't re-run JIRA transitions because the ticket should already be in Code Review.
- If anything in Phase 6 fails after a successful push, the branch is on origin without a PR. That's recoverable — the user can re-run `/ship` and Phase 5 will see no PR and proceed to Phase 6 again. Make sure not to re-commit in that case (Phase 2 will see nothing staged and Phase 3 is skipped).
