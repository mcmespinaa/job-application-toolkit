#!/usr/bin/env bash
# export-docs.sh — convert an application's cv.md + letter.md into document files in final/.
# Primary format: DOCX (via Pandoc). Fallback: self-contained HTML (no dependencies).
# Idempotent and non-destructive to the source .md files.
#
# Usage: export-docs.sh <application-dir>
#   <application-dir>  a folder under 02_applications/ containing cv.md and/or letter.md
#
# Exit codes: 0 = at least one file exported; 4 = nothing to export; 3 = bad args.
# Prints, on the last line, a machine-readable summary: RESULT=docx|html|none

set -euo pipefail

APP="${1:-}"
if [ -z "$APP" ]; then
  echo "ERROR: no application directory given." >&2
  echo "Usage: export-docs.sh <application-dir>" >&2
  exit 3
fi

case "$APP" in
  "~"/*) APP="$HOME/${APP#~/}" ;;
  "~")   APP="$HOME" ;;
esac

if [ ! -d "$APP" ]; then
  echo "ERROR: not a directory: $APP" >&2
  exit 3
fi

mkdir -p "$APP/final"

# Detect a converter.
HAVE_PANDOC=0
if command -v pandoc >/dev/null 2>&1; then HAVE_PANDOC=1; fi

# ATS reference template (styled, single-column, black-only). Used if present.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REFERENCE="$SCRIPT_DIR/../assets/reference.docx"
REF_ARGS=()
if [ -f "$REFERENCE" ]; then REF_ARGS=(--reference-doc="$REFERENCE"); fi

# Minimal CSS for the HTML fallback so it prints cleanly to PDF / pastes into Word.
# SECURITY: HTML_CSS MUST stay a static constant. It is injected into the fallback HTML's <style>
# block without escaping; if it ever became dynamic/user-controlled, a `</style>` in it could break
# out (XSS). Document content, by contrast, IS HTML-escaped before insertion (see esc() below).
read -r -d '' HTML_CSS <<'CSS' || true
body{font-family:-apple-system,Segoe UI,Roboto,Helvetica,Arial,sans-serif;max-width:46rem;margin:2rem auto;padding:0 1rem;line-height:1.4;color:#111}
h1{font-size:1.6rem;margin:0 0 .2rem}h2{font-size:1.1rem;border-bottom:1px solid #ccc;padding-bottom:.2rem;margin-top:1.4rem}
h3{font-size:1rem;margin-bottom:0}ul{margin:.3rem 0 .6rem 1.1rem}li{margin:.15rem 0}
@media print{body{margin:0;max-width:none}}
CSS

exported_any=0
result="none"

# convert_one <source.md> <basename-without-ext>
convert_one() {
  local src="$1" base="$2"
  [ -f "$src" ] || return 0
  if [ "$HAVE_PANDOC" -eq 1 ]; then
    if pandoc "$src" -f markdown -t docx "${REF_ARGS[@]}" -o "$APP/final/$base.docx" 2>/dev/null; then
      local styled=""; [ ${#REF_ARGS[@]} -gt 0 ] && styled=" (ATS-styled)"
      echo "  docx:  final/$base.docx$styled"
      exported_any=1; result="docx"; return 0
    fi
    echo "  WARN: pandoc failed on $base, falling back to HTML" >&2
  fi
  # Fallback: very small md->html (headings, bullets, paragraphs) via a Node one-liner if available,
  # else a literal <pre> wrapper that still opens and prints. Node is a soft prereq already listed.
  if command -v node >/dev/null 2>&1; then
    # shellcheck disable=SC2016  # single quotes are intentional: this is a Node program, not shell.
    # The $-refs inside are JS reading process.env (SRC/OUT/TITLE/CSS), passed as env vars above —
    # they must NOT be expanded by the shell.
    SRC="$src" OUT="$APP/final/$base.html" TITLE="$base" CSS="$HTML_CSS" node -e '
      const fs=require("fs");
      let md=fs.readFileSync(process.env.SRC,"utf8").split("\n"),out=[],inList=false;
      const esc=s=>s.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;");
      const inline=s=>esc(s).replace(/\*\*(.+?)\*\*/g,"<strong>$1</strong>").replace(/\*(.+?)\*/g,"<em>$1</em>");
      for(const line of md){
        if(/^\s*-\s+/.test(line)){ if(!inList){out.push("<ul>");inList=true;} out.push("<li>"+inline(line.replace(/^\s*-\s+/,""))+"</li>"); continue; }
        if(inList){out.push("</ul>");inList=false;}
        if(/^#\s+/.test(line)) out.push("<h1>"+inline(line.replace(/^#\s+/,""))+"</h1>");
        else if(/^##\s+/.test(line)) out.push("<h2>"+inline(line.replace(/^##\s+/,""))+"</h2>");
        else if(/^###\s+/.test(line)) out.push("<h3>"+inline(line.replace(/^###\s+/,""))+"</h3>");
        else if(line.trim()==="") out.push("");
        else out.push("<p>"+inline(line)+"</p>");
      }
      if(inList)out.push("</ul>");
      const html=`<!doctype html><html><head><meta charset="utf-8"><title>${process.env.TITLE}</title><style>${process.env.CSS}</style></head><body>${out.join("\n")}</body></html>`;
      fs.writeFileSync(process.env.OUT,html);
    ' 2>/dev/null && { echo "  html:  final/$base.html (Pandoc not found — open and Print to PDF, or paste into Word)"; exported_any=1; [ "$result" = "none" ] && result="html"; return 0; }
  fi
  # Last resort: wrap raw markdown in printable HTML so SOMETHING lands in final/.
  { printf '<!doctype html><meta charset="utf-8"><title>%s</title><style>%s</style><pre>' "$base" "$HTML_CSS"
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$src"
    printf '</pre>'; } > "$APP/final/$base.html"
  echo "  html:  final/$base.html (plain fallback)"
  exported_any=1; [ "$result" = "none" ] && result="html"
}

echo "Exporting documents into: ${APP}/final/"
convert_one "$APP/cv.md" "cv"
convert_one "$APP/letter.md" "letter"

if [ "$exported_any" -eq 0 ]; then
  echo "Nothing to export (no cv.md or letter.md found)." >&2
  echo "RESULT=none"
  exit 4
fi

if [ "$HAVE_PANDOC" -eq 0 ]; then
  echo ""
  echo "NOTE: Pandoc was not found, so HTML was produced instead of DOCX."
  echo "      For native Word files, install Pandoc (https://pandoc.org/installing.html) and re-run."
fi

echo "RESULT=$result"
