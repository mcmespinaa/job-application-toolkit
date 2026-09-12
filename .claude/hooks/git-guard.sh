#!/usr/bin/env bash
# Deterministic git guards for agent sessions sharing this checkout.
#
# CANONICAL COPY. Install into a repo with:
#   ~/Agents/pm-agent/scripts/install-git-guard.sh <repo-path>
# Edit this file, not the per-repo copies, then re-run the installer.
#
# CLAUDE.md states these rules; a hook enforces them. Adapted from
# ~/Workspaces/Projects/shopvibes-acquisitions-site/.claude/hooks/git-guard.sh
# (estate CAPA-009). Rule ids refer to docs/agents-and-branches.md.
#
#
# Exit 0 = allow. Exit 2 = block the tool call and return stderr to the agent.
# Anything unexpected exits 0: a guard that blocks every Bash call because jq
# is missing is worse than the failure it prevents.

set -uo pipefail

input=$(cat 2>/dev/null) || exit 0
command -v jq >/dev/null 2>&1 || exit 0
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

# Cheap gate: ignore everything that is not a git command.
case "$cmd" in *git*) ;; *) exit 0 ;; esac

# Which directory will this command actually run in? This matters: the
# upstream version resolved CLAUDE_PROJECT_DIR, which is the SHARED checkout —
# so a perfectly legitimate `cd <worktree> && git commit` was judged against
# main's branch and blocked. Worktrees are the recommended workflow here, so
# the guard must not punish them.
#
# Precedence: an explicit `cd` in the command, then the session cwd from the
# hook payload, then the project dir.
workdir=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$workdir" ] || workdir="${CLAUDE_PROJECT_DIR:-.}"

if printf '%s' "$cmd" | grep -Eq '(^|[;&|(][[:space:]]*)cd[[:space:]]'; then
  cdarg=$(printf '%s' "$cmd" \
    | grep -oE '(^|[;&|(][[:space:]]*)cd[[:space:]]+[^;&|)]+' \
    | tail -1 | sed -E 's/.*cd[[:space:]]+//; s/[[:space:]]+$//' | tr -d "\"'")
  # A variable, backtick or $( ) means we cannot know the target repo. Guessing
  # would either block valid work or validate the wrong tree — so fail OPEN and
  # let the human-readable rules in docs/agents-and-branches.md carry it.
  case "$cdarg" in
    ""|*'$'*|*'`'*) exit 0 ;;
  esac
  case "$cdarg" in
    /*) cand="$cdarg" ;;
    "~"*) cand="${cdarg/#\~/$HOME}" ;;
    *)  cand="$workdir/$cdarg" ;;
  esac
  [ -d "$cand" ] || exit 0
  workdir="$cand"
fi

cd "$workdir" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0
branch=$(git branch --show-current 2>/dev/null || echo "")

# R3: `git add -A` / `git add .` sweeps another session's uncommitted files
# into your commit. This is what happened here on 2026-09-12.
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+add[[:space:]]+(-A|--all|\.([[:space:]]|$))'; then
  echo "BLOCKED (R3): 'git add -A' / 'git add .' sweeps other sessions' uncommitted files into your commit. Several agents share this checkout. Stage explicit paths instead." >&2
  exit 2
fi

# R4: no direct commits to main. main is the deploy branch: the poll workflow
# runs from it every 3 h and Cloudflare Pages deploys from it.
if [ "$branch" = "main" ] && printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+commit'; then
  echo "BLOCKED (R4): you are on 'main' in the shared checkout. Branch off origin/main in a worktree first (git worktree add <path> -b <branch> origin/main), then open a PR. See docs/agents-and-branches.md." >&2
  exit 2
fi

# R6: a branch switch drags uncommitted tracked work onto the target branch.
# Allow -b/-c/-B (creating a branch keeps your work with you, the normal
# recovery) and allow path-restoring forms (`git checkout -- file`).
if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+(checkout|switch)[[:space:]]' \
   && ! printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+(checkout|switch)[[:space:]]+(-b|-c|-B)' \
   && ! printf '%s' "$cmd" | grep -q -- '--[[:space:]]'; then
  if [ -n "$(git status --porcelain --untracked-files=no 2>/dev/null)" ]; then
    echo "BLOCKED (R6): this checkout has uncommitted tracked changes that would follow you onto the target branch. Commit, stash, or work in a worktree." >&2
    exit 2
  fi
fi

exit 0
