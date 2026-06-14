#!/usr/bin/env bash
# setup-workspace.sh — scaffold an ICM job-application workspace from the plugin templates.
# Idempotent: safe to re-run. Never overwrites a file the user has already edited.
#
# Usage: setup-workspace.sh <target-dir> [--force-context]
#   <target-dir>      where to create the workspace (created if missing)
#   --force-context   refresh CONTEXT.md / CLAUDE.md scaffolding files even if present
#                     (never touches 00_master/*.md user content)
#
# Env: TEMPLATES_DIR may override the templates source (defaults to ../templates next to this script).

set -euo pipefail

# Parse args position-independently: --force-context may appear before or after the target path;
# the first non-flag argument is the target directory.
TARGET=""
FORCE_CONTEXT=""
for arg in "$@"; do
  case "$arg" in
    --force-context) FORCE_CONTEXT="--force-context" ;;
    -*)              echo "WARN: ignoring unknown flag: $arg" >&2 ;;
    *)               [ -z "$TARGET" ] && TARGET="$arg" ;;
  esac
done

if [ -z "$TARGET" ]; then
  echo "ERROR: no target directory given." >&2
  echo "Usage: setup-workspace.sh <target-dir> [--force-context]" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${TEMPLATES_DIR:-$SCRIPT_DIR/../templates}"

if [ ! -d "$TEMPLATES_DIR" ]; then
  echo "ERROR: templates dir not found at $TEMPLATES_DIR" >&2
  exit 3
fi

# Expand a leading ~ in the target path.
case "$TARGET" in
  "~"/*) TARGET="$HOME/${TARGET#~/}" ;;
  "~")   TARGET="$HOME" ;;
esac

mkdir -p "$TARGET"
echo "Scaffolding ICM job-application workspace at: $TARGET"

# copy_if_absent SRC DEST  — copy only when DEST does not exist (protects user edits).
copy_if_absent() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ]; then
    echo "  skip (exists): ${dest#$TARGET/}"
  else
    cp "$src" "$dest"
    echo "  create:        ${dest#$TARGET/}"
  fi
}

# Walk every file in templates and place it, preserving structure.
while IFS= read -r -d '' src; do
  rel="${src#$TEMPLATES_DIR/}"
  dest="$TARGET/$rel"
  base="$(basename "$rel")"

  # Scaffolding files (the map + room contracts) can be refreshed with --force-context.
  if [ "$base" = "CONTEXT.md" ] || [ "$base" = "CLAUDE.md" ]; then
    if [ "$FORCE_CONTEXT" = "--force-context" ] && [ -e "$dest" ]; then
      cp "$src" "$dest"
      echo "  refresh:       ${rel}"
      continue
    fi
  fi
  copy_if_absent "$src" "$dest"
done < <(find "$TEMPLATES_DIR" -type f -print0)

# Ensure the empty working dirs exist even though git/templates may not carry them.
mkdir -p "$TARGET/02_applications" "$TARGET/_archive" "$TARGET/_templates"

# A project-local settings.json with the non-destructive allowlist, if absent.
SETTINGS="$TARGET/.claude/settings.json"
if [ ! -e "$SETTINGS" ]; then
  mkdir -p "$TARGET/.claude"
  cat > "$SETTINGS" <<'JSON'
{
  "permissions": {
    "allow": [
      "WebSearch",
      "WebFetch",
      "Bash(curl:*)", "Bash(jq:*)", "Bash(cat:*)", "Bash(ls:*)", "Bash(grep:*)",
      "Bash(echo:*)", "Bash(which:*)", "Bash(wc:*)", "Bash(file:*)", "Bash(pwd)",
      "Bash(mkdir:*)", "Bash(touch:*)", "Bash(head:*)", "Bash(tail:*)", "Bash(find:*)",
      "Bash(sort:*)", "Bash(tree:*)", "Bash(diff:*)", "Bash(node:*)", "Bash(npm:*)",
      "Bash(npx:*)", "Bash(git status:*)", "Bash(git diff:*)", "Bash(git log:*)"
    ]
  }
}
JSON
  echo "  create:        .claude/settings.json (non-destructive allowlist)"
else
  echo "  skip (exists): .claude/settings.json"
fi

echo ""
echo "Done. Next:"
echo "  1. Fill 00_master/master-cv.md and voice.md with your real facts."
echo "  2. Drop past CVs / cover letters into _archive/ to build experience-bank.md."
echo "  3. Run the pipeline:  /job-application:job-application <job-url>"
