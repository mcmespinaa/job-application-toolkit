#!/usr/bin/env python3
"""test_reference_docx.py — verify the ATS reference.docx is a valid, correctly-styled template.

This guards the most breakage-prone code in the toolkit: build-reference-docx.sh patches Pandoc's
default reference.docx with regex-based OOXML surgery. If a future Pandoc changes its styles.xml
shape, the regex can silently no-op and ship an UNSTYLED template with no error. This test asserts
the specific style injections the build script claims to make actually landed.

Usage:
    python3 tests/test_reference_docx.py            # test the committed assets/reference.docx
    python3 tests/test_reference_docx.py --build    # rebuild from scratch first, then test
                                                    # (requires pandoc + python3)

Exit codes: 0 = all checks passed; 1 = a check failed; 2 = setup/environment error.
Zero third-party dependencies — stdlib only (zipfile, xml, subprocess).
"""

import os
import sys
import zipfile
import subprocess
import xml.etree.ElementTree as ET

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PLUGIN = os.path.join(ROOT, "plugins", "job-application")
REFERENCE = os.path.join(PLUGIN, "assets", "reference.docx")
BUILD_SCRIPT = os.path.join(PLUGIN, "scripts", "build-reference-docx.sh")

W = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"


class CheckError(Exception):
    """A named assertion failure, reported with a clear message."""


def check(condition, message):
    if not condition:
        raise CheckError(message)
    print(f"  ok: {message}")


def maybe_build():
    """Rebuild the reference.docx from source if --build was passed."""
    if "--build" not in sys.argv:
        return
    for dep in ("pandoc", "python3"):
        if subprocess.run(["command", "-v", dep], shell=False,
                          capture_output=True).returncode != 0 and \
           not any(os.access(os.path.join(p, dep), os.X_OK)
                   for p in os.environ.get("PATH", "").split(os.pathsep)):
            print(f"SETUP ERROR: --build needs '{dep}' on PATH.", file=sys.stderr)
            sys.exit(2)
    print(f"Rebuilding reference.docx via {BUILD_SCRIPT} ...")
    r = subprocess.run(["bash", BUILD_SCRIPT], capture_output=True, text=True)
    if r.returncode != 0:
        print("SETUP ERROR: build-reference-docx.sh failed:", file=sys.stderr)
        print(r.stdout + r.stderr, file=sys.stderr)
        sys.exit(2)


def load_styles(docx_path):
    """Return (styles_xml_text, parsed_root) for word/styles.xml inside the docx.

    A .docx is a zip; this also exercises that the archive is well-formed and openable,
    which is the "does it open in Word" proxy — Word refuses a corrupt zip or malformed XML.
    """
    if not os.path.isfile(docx_path):
        print(f"SETUP ERROR: no reference.docx at {docx_path}. "
              f"Run with --build, or commit the asset.", file=sys.stderr)
        sys.exit(2)
    try:
        with zipfile.ZipFile(docx_path, "r") as z:
            bad = z.testzip()
            if bad is not None:
                raise CheckError(f"corrupt zip entry: {bad}")
            names = z.namelist()
            if "word/styles.xml" not in names:
                raise CheckError("word/styles.xml missing from docx")
            if "word/document.xml" not in names:
                raise CheckError("word/document.xml missing — not a valid docx")
            styles_xml = z.read("word/styles.xml").decode("utf-8")
            core_xml = z.read("docProps/core.xml").decode("utf-8") \
                if "docProps/core.xml" in names else ""
    except zipfile.BadZipFile:
        raise CheckError(f"{docx_path} is not a valid zip/docx (Word would refuse it)")
    # Parsing proves the XML is well-formed (Word's other hard requirement).
    root = ET.fromstring(styles_xml)
    return styles_xml, root, core_xml


def style_block(root, style_id):
    """Return the <w:style> element for a given styleId, or None."""
    for st in root.findall(f"{{{W}}}style"):
        if st.get(f"{{{W}}}styleId") == style_id:
            return st
    return None


def run_props(style_el):
    """Return the set of run-property child tags (local names) under <w:rPr> of a style."""
    rpr = style_el.find(f"{{{W}}}rPr") if style_el is not None else None
    if rpr is None:
        return set(), {}
    tags = {child.tag.split("}")[-1] for child in rpr}
    vals = {child.tag.split("}")[-1]: child.get(f"{{{W}}}val") for child in rpr}
    return tags, vals


def main():
    maybe_build()
    print(f"Testing: {REFERENCE}")
    styles_xml, root, core_xml = load_styles(REFERENCE)

    # 1) The styles the build script targets must all still exist.
    required = ["Heading1", "Heading2", "Heading3", "Title", "Subtitle",
                "Normal", "Compact", "FirstParagraph"]
    for sid in required:
        check(style_block(root, sid) is not None,
              f"style '{sid}' present (build script targets it)")

    # 2) The build script's key injections must actually be in place — this is what
    #    catches a silent regex no-op against a future Pandoc.
    h1 = style_block(root, "Heading1")
    h1_tags, h1_vals = run_props(h1)
    check("b" in h1_tags, "Heading1 (candidate name) is bold")
    check("sz" in h1_tags and h1_vals.get("sz") == "40",
          "Heading1 size is 40 half-points (20pt name)")
    check(h1_vals.get("color") == "000000", "Heading1 color is black (ATS-safe)")

    h2 = style_block(root, "Heading2")
    h2_tags, h2_vals = run_props(h2)
    check("b" in h2_tags, "Heading2 (section header) is bold")
    check("caps" in h2_tags, "Heading2 is uppercased (w:caps injected)")
    # The section-heading underline rule (pBdr/bottom) must be present.
    check("<w:pBdr>" in styles_xml and "w:bottom" in styles_xml,
          "Heading2 carries a bottom border rule (pBdr)")

    normal = style_block(root, "Normal")
    _, n_vals = run_props(normal)
    check(n_vals.get("color") == "000000", "Normal body text is black")

    # 3) Font must be the ATS-safe body font the script sets everywhere.
    check('w:ascii="Calibri"' in styles_xml,
          "Calibri (ATS-safe font) applied via rFonts")

    # 4) The shipped template must carry NO stray author/title metadata (privacy hygiene).
    if core_xml:
        check("<dc:creator></dc:creator>" in core_xml or "<dc:creator/>" in core_xml,
              "core.xml creator is blank (no stray author metadata)")

    print("\nALL CHECKS PASSED — reference.docx is valid and correctly styled.")


if __name__ == "__main__":
    try:
        main()
    except CheckError as e:
        print(f"\nFAILED: {e}", file=sys.stderr)
        sys.exit(1)
