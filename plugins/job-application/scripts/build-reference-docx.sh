#!/usr/bin/env bash
# build-reference-docx.sh — generate the ATS-optimised Pandoc reference.docx used to style CV/letter
# exports. Single-column, black-only, typographic hierarchy. Reproducible: run this to regenerate the
# committed assets/reference.docx after changing styles here.
#
# Requires: pandoc and python3 on PATH. (This is a maintainer-only build script; end users never
# run it — they consume the committed assets/reference.docx.)
# Output: <plugin>/assets/reference.docx

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS="$SCRIPT_DIR/../assets"
mkdir -p "$ASSETS"
OUT="$ASSETS/reference.docx"

for dep in pandoc python3; do
  if ! command -v "$dep" >/dev/null 2>&1; then
    echo "ERROR: $dep is required to build the reference.docx." >&2
    exit 3
  fi
done

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# 1) Start from Pandoc's own default reference so all required styles exist.
#    --print-default-data-file writes to stdout; capture it. (No -o: that flag is meaningless in
#    print-data-file mode and produces a contradictory double-write.)
pandoc --print-default-data-file reference.docx > "$WORK/base.docx"

# 2) Patch word/styles.xml with python3 (zip-safe edit). Black-only, ATS-clean styling.
python3 - "$WORK/base.docx" "$OUT" <<'PY'
import sys, zipfile, re, shutil, os

src, out = sys.argv[1], sys.argv[2]
tmp = out + ".tmp"
shutil.copyfile(src, tmp)

# Read styles.xml
with zipfile.ZipFile(tmp, "r") as z:
    names = z.namelist()
    styles = z.read("word/styles.xml").decode("utf-8")

W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

def set_run_props(style_xml, *, bold=None, caps=None, size_half=None, color=None, font=None):
    """Inject/replace rPr props inside a given <w:style> block."""
    # Ensure an <w:rPr> exists
    if '<w:rPr>' not in style_xml and '<w:rPr/>' not in style_xml:
        style_xml = re.sub(r'(</w:pPr>)', r'\1<w:rPr></w:rPr>', style_xml, count=1)
        if '<w:rPr>' not in style_xml:
            style_xml = re.sub(r'(<w:name[^>]*/>)', r'\1<w:rPr></w:rPr>', style_xml, count=1)
    style_xml = style_xml.replace('<w:rPr/>', '<w:rPr></w:rPr>')
    props = ''
    if bold:      props += '<w:b/><w:bCs/>'
    if caps:      props += '<w:caps/>'
    if color:     props += f'<w:color w:val="{color}"/>'
    if font:      props += f'<w:rFonts w:ascii="{font}" w:hAnsi="{font}" w:cs="{font}"/>'
    if size_half: props += f'<w:sz w:val="{size_half}"/><w:szCs w:val="{size_half}"/>'
    # strip existing of the kinds we set, then prepend ours
    for tag in (['b','bCs'] if bold else []) + (['caps'] if caps else []) + \
               (['color'] if color else []) + (['rFonts'] if font else []) + \
               (['sz','szCs'] if size_half else []):
        style_xml = re.sub(rf'<w:{tag}[^/]*/>', '', style_xml)
    style_xml = re.sub(r'(<w:rPr>)', r'\1' + props, style_xml, count=1)
    return style_xml

def patch_style(styles, style_id, fn):
    m = re.search(rf'(<w:style[^>]*w:styleId="{style_id}"[^>]*>)(.*?)(</w:style>)', styles, re.S)
    if not m:
        return styles
    block = m.group(0)
    return styles[:m.start()] + fn(block) + styles[m.end():]

def add_border_bottom(style_xml):
    """Add a thin bottom rule under the paragraph (section heading underline)."""
    pbdr = '<w:pBdr><w:bottom w:val="single" w:sz="6" w:space="2" w:color="000000"/></w:pBdr>'
    if '<w:pPr>' in style_xml:
        style_xml = re.sub(r'(<w:pPr>)', r'\1' + pbdr, style_xml, count=1)
    return style_xml

def set_spacing(style_xml, before=None, after=None):
    sp = '<w:spacing'
    if before is not None: sp += f' w:before="{before}"'
    if after  is not None: sp += f' w:after="{after}"'
    sp += '/>'
    style_xml = re.sub(r'<w:spacing[^/]*/>', '', style_xml)
    if '<w:pPr>' in style_xml:
        style_xml = re.sub(r'(<w:pPr>)', r'\1' + sp, style_xml, count=1)
    return style_xml

BODY_FONT = 'Calibri'   # widely available, clean, ATS-safe; Word maps it everywhere

# NOTE on mapping: Pandoc maps Markdown headings by LEVEL, not by role:
#   '# Name'      -> Heading1
#   '## Section'  -> Heading2
#   '### Job'     -> Heading3
# So we style to that reality: Heading1 = the candidate name (Title look),
# Heading2 = section headers (ruled), Heading3 = job titles. This makes the CV's
# visual hierarchy land correctly with NO special syntax in the Markdown.

# Heading1 = candidate name: large, bold, black.
styles = patch_style(styles, 'Heading1',
    lambda s: set_spacing(set_run_props(s, bold=True, caps=False, size_half='40', color='000000', font=BODY_FONT), before='0', after='40'))
# Heading2 = section names (SUMMARY, EXPERIENCE...): bold, uppercase, bottom rule.
styles = patch_style(styles, 'Heading2',
    lambda s: add_border_bottom(set_spacing(set_run_props(s, bold=True, caps=True, size_half='24', color='000000', font=BODY_FONT), before='240', after='80')))
# Heading3 = job titles: bold, slightly smaller, no rule.
styles = patch_style(styles, 'Heading3',
    lambda s: set_spacing(set_run_props(s, bold=True, size_half='22', color='000000', font=BODY_FONT), before='140', after='20'))
# Title/Subtitle kept styled too, in case a CV uses Pandoc title-block metadata.
styles = patch_style(styles, 'Title',
    lambda s: set_spacing(set_run_props(s, bold=True, size_half='40', color='000000', font=BODY_FONT), before='0', after='40'))
styles = patch_style(styles, 'Subtitle',
    lambda s: set_spacing(set_run_props(s, bold=False, size_half='24', color='404040', font=BODY_FONT), before='0', after='160'))
# Normal + Compact (Pandoc uses Compact for tight bullet lists): clean body.
styles = patch_style(styles, 'Normal',
    lambda s: set_run_props(s, size_half='21', color='000000', font=BODY_FONT))
styles = patch_style(styles, 'Compact',
    lambda s: set_run_props(s, size_half='21', color='000000', font=BODY_FONT))
# FirstParagraph (the contact line right under the name): give it a touch of space below.
styles = patch_style(styles, 'FirstParagraph',
    lambda s: set_spacing(set_run_props(s, size_half='21', color='404040', font=BODY_FONT), before='0', after='120'))

# Neutral document properties so the shipped template carries no stray author/title metadata.
CORE_XML = (
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    '<cp:coreProperties '
    'xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
    'xmlns:dc="http://purl.org/dc/elements/1.1/" '
    'xmlns:dcterms="http://purl.org/dc/terms/" '
    'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
    '<dc:title></dc:title><dc:creator></dc:creator><cp:lastModifiedBy></cp:lastModifiedBy>'
    '</cp:coreProperties>'
)

# Rewrite the archive with patched styles.xml and neutral core.xml.
import zipfile
newtmp = out + ".zip"
with zipfile.ZipFile(tmp, "r") as zin, zipfile.ZipFile(newtmp, "w", zipfile.ZIP_DEFLATED) as zout:
    for item in zin.namelist():
        data = zin.read(item)
        if item == "word/styles.xml":
            data = styles.encode("utf-8")
        elif item == "docProps/core.xml":
            data = CORE_XML.encode("utf-8")
        zout.writestr(item, data)
os.replace(newtmp, out)
os.remove(tmp)
print("wrote", out)
PY

echo "Reference DOCX built: $OUT"
