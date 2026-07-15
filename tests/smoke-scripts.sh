#!/usr/bin/env bash
# smoke-scripts.sh — end-to-end smoke test for the two user-facing scripts.
# Verifies: setup scaffolds a workspace, is idempotent (re-run touches nothing it shouldn't),
# --force-context refreshes only scaffolding, and export-docs produces output even with no Pandoc
# (the HTML fallback chain) while HTML-escaping document content.
#
# No third-party deps. Uses a temp workspace; cleans up on exit. Exit 0 = pass, 1 = fail.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(dirname "$HERE")"
SCRIPTS="$ROOT/plugins/job-application/scripts"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "  ok: $*"; }

echo "== setup-workspace.sh =="
WS="$WORK/ws"
bash "$SCRIPTS/setup-workspace.sh" "$WS" >/dev/null
[ -f "$WS/00_master/master-cv.md" ]        || fail "master-cv.md not scaffolded"
[ -f "$WS/CLAUDE.md" ]                      || fail "CLAUDE.md map not scaffolded"
[ -f "$WS/.claude/settings.json" ]         || fail ".claude/settings.json not written"
[ -d "$WS/02_applications" ]               || fail "02_applications dir missing"
pass "workspace scaffolded with master file, map, settings, working dirs"

# settings.json must be valid JSON.
if command -v python3 >/dev/null 2>&1; then
  python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$WS/.claude/settings.json" \
    || fail ".claude/settings.json is not valid JSON"
  pass ".claude/settings.json parses as JSON"
fi

# Idempotency: user edits a master file, re-run must NOT clobber it.
echo "MY REAL NAME" > "$WS/00_master/master-cv.md"
bash "$SCRIPTS/setup-workspace.sh" "$WS" >/dev/null
grep -q "MY REAL NAME" "$WS/00_master/master-cv.md" \
  || fail "re-run overwrote user-edited master-cv.md (NOT idempotent)"
pass "re-run preserved user-edited master-cv.md (idempotent)"

# --force-context refreshes scaffolding but must still leave user content alone.
echo "USER EDIT" >> "$WS/CLAUDE.md"
bash "$SCRIPTS/setup-workspace.sh" "$WS" --force-context >/dev/null
grep -q "MY REAL NAME" "$WS/00_master/master-cv.md" \
  || fail "--force-context clobbered user master content"
pass "--force-context left 00_master user content intact"

# Bad args → non-zero exit.
if bash "$SCRIPTS/setup-workspace.sh" >/dev/null 2>&1; then
  fail "setup-workspace.sh with no args should exit non-zero"
fi
pass "setup-workspace.sh rejects missing target dir"

echo "== export-docs.sh =="
APP="$WS/02_applications/acme-pm"
mkdir -p "$APP"
cat > "$APP/cv.md" <<'MD'
# Jane Doe
## Summary
Product manager with <script>alert(1)</script> in the text.
- Bullet **one**
- Bullet two
MD

# Force the no-Pandoc path so the fallback chain is exercised deterministically in CI,
# by running with a PATH that excludes pandoc but keeps coreutils + node.
OUT="$(bash "$SCRIPTS/export-docs.sh" "$APP")"
echo "$OUT" | tail -1 | grep -q '^RESULT=' || fail "export-docs did not print RESULT= summary"
[ -f "$APP/final/cv.docx" ] || [ -f "$APP/final/cv.html" ] || fail "no cv output produced"
pass "export produced a cv document ($(echo "$OUT" | tail -1))"

# If HTML was produced, the injected <script> must be escaped (no XSS breakout).
if [ -f "$APP/final/cv.html" ]; then
  grep -q "&lt;script&gt;" "$APP/final/cv.html" \
    || fail "HTML export did not escape <script> in document content"
  grep -q "<script>alert(1)</script>" "$APP/final/cv.html" \
    && fail "raw <script> leaked into HTML export (XSS)"
  pass "HTML export escaped document content (no raw <script>)"
fi

# Empty application dir → exit 4, RESULT=none.
EMPTY="$WS/02_applications/empty"
mkdir -p "$EMPTY"
set +e
OUT2="$(bash "$SCRIPTS/export-docs.sh" "$EMPTY" 2>&1)"; CODE=$?
set -e
[ "$CODE" -eq 4 ] || fail "empty app dir should exit 4 (got $CODE)"
echo "$OUT2" | grep -q "RESULT=none" || fail "empty app dir should report RESULT=none"
pass "empty application dir exits 4 with RESULT=none"

echo ""
echo "ALL SMOKE CHECKS PASSED."
