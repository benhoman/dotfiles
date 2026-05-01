#!/bin/bash
# PreToolUse(Bash) hook: blocks `git commit` when the message doesn't start
# with the ticket prefix derived from the current branch.
#
# Branch must match ^[A-Z]+-[0-9]+ (e.g., PDW-11931-..., INFRA-42-...);
# branches without that pattern (main, qa, dev) skip the check.
#
# Reads the standard Claude Code PreToolUse JSON payload on stdin,
# exits 0 to allow, exits 2 with a stderr message to block.

set -u

input=$(cat)
cmd=$(echo "$input" | jq -r '.tool_input.command // ""')

# Only act on git commit
if ! echo "$cmd" | grep -qE '(^|[^a-zA-Z])git[[:space:]]+commit([[:space:]]|$)'; then
  exit 0
fi

branch=$(git branch --show-current 2>/dev/null)
[ -z "$branch" ] && exit 0

ticket=$(echo "$branch" | grep -oE '^[A-Z]+-[0-9]+')
[ -z "$ticket" ] && exit 0

# Extract the commit message body. Try (in order):
#   1. heredoc: -m "$(cat <<'EOF' ... EOF)"  (any label, quoted or not, <<- variant supported)
#   2. -m "..."  (with escaped quote support)
#   3. -m '...'
msg=$(printf '%s' "$cmd" | perl -0777 -ne '
  if (/<<-?\s*[\x27"]?([A-Za-z_][A-Za-z0-9_]*)[\x27"]?\s*\n(.*?)\n\s*\1\s*$/sm) {
    print $2; exit 0
  }
  if (/-m\s+"((?:[^"\\]|\\.)*)"/s) {
    my $m = $1; $m =~ s/\\"/"/g; print $m; exit 0
  }
  if (/-m\s+\x27([^\x27]*)\x27/s) {
    print $1; exit 0
  }
')

# No -m / no heredoc body — editor commit, allow
[ -z "$msg" ] && exit 0

first_line=$(printf '%s' "$msg" | head -n1)

if printf '%s' "$first_line" | grep -qE "^${ticket} "; then
  exit 0
fi

cat >&2 <<EOM
Commit blocked: message must start with ticket prefix '$ticket' (from branch '$branch').

You wrote: '$first_line'

Per CA convention, do NOT use conventional-commit prefixes (chore:, docs:, fix:, feat:) —
use '$ticket Description here' instead.
EOM
exit 2
