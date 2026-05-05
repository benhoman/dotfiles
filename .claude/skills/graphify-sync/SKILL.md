---
name: graphify-sync
description: Refresh all Graphify codebase knowledge graphs. Use this skill whenever the user wants to update, refresh, sync, or rebuild Graphify graphs. Triggers on: "refresh graphify", "update codebase graphs", "sync graphify", "rebuild the graphs", "graphify is stale", or any mention of wanting fresh/updated graph data across projects.
---

# Graphify Sync

Refreshes all projects registered in `~/Documents/vaults/main/Claude/Graphify/index.md`:
1. Fetch upstream and merge to stable branch for each repo
2. Run `graphify update` to rebuild `graph.json`
3. Update node/community counts and `Last Updated` date in the index

## Index format

Read `~/Documents/vaults/main/Claude/Graphify/index.md`. The Projects table has these columns:
`| Project | Nodes | Communities | Graph Source | Last Updated |`

The **Repo Paths** table maps project names to:
- **Src Directory** — where to run `graphify update` and find `graphify-out/graph.json`
- **Stable Branch** — branch to merge upstream into
- **Bare Repo** — if Yes, the bare repo path is listed in parentheses

## Per-project workflow

### 1. Fetch upstream

**Regular repo** (Bare Repo = No):
```bash
git -C <src_dir> fetch upstream
git -C <src_dir> merge upstream/<stable_branch>
```

**Bare repo** (Bare Repo = Yes, e.g. match-api, advisor):
```bash
git -C <bare_repo_path> fetch upstream
git -C <src_dir> merge upstream/<stable_branch>
```

If fetch/merge fails, skip the merge but still rebuild the graph. Log the skip.

### 2. Rebuild the graph

```bash
cd <src_dir> && graphify update .
```

Parse output for `Rebuilt: N nodes, M edges, K communities`. If not present (cache hit), read counts from existing `graphify-out/graph.json`.

## Run everything in parallel

Fetch and rebuild all projects concurrently — they're fully independent. Mainsite takes longest; don't wait for it before starting others.

```bash
(cd <src1> && git fetch upstream && git merge upstream/<branch> && graphify update .) &
(cd <src2> && ...) &
wait
```

## Edge cases

- **graphify not on PATH**: use `/Users/bhoman/.local/share/mise/installs/python/3.12/bin/graphify`
- **Nothing changed**: cache hit is fine — counts stay the same, still update the date

## Update the index

After all projects complete, update the Projects table in `index.md`:
- Update **Nodes** and **Communities** with fresh counts
- Set **Last Updated** to today's date (`YYYY-MM-DD`)

## Report

Print a summary table when done:

| Project | Nodes | Communities | Status |
|---------|-------|-------------|--------|
| mainsite | 60,760 | 4,924 | ✓ rebuilt |
| ca-worktrees | 6,905 | 180 | ✓ cached |
| ... | | | |
