---
name: job-export
description: "Export a finished application's CV and cover letter into document files (ATS-styled DOCX, or HTML if Pandoc is absent) in the application's final/ folder. Use when the user says /job-export, 'export my CV to Word', 'generate the docx', 'make the PDF', 'turn this into a document', or has edited a cv.md/letter.md and wants fresh document files. Produces single-column, ATS-safe, black-only styled documents that land directly in the local folder, no Obsidian or Google Drive needed. NOT for writing or editing CV content (use /job-application for that); this only renders existing cv.md and letter.md into documents."
---

# Job-Export

Turn the Markdown drafts of a finished application into real document files in `final/`, so they
land in the local folder regardless of whether the user has Obsidian or Google Drive. The documents
are **ATS-optimised**: single-column, standard heading styles, black-only typographic hierarchy. They
look designed, not default, while staying fully parseable by applicant tracking systems.

## Inputs
- A target **application folder** (under `02_applications/`) containing `cv.md` and/or `letter.md`.
  If the user doesn't name one, infer the most recently created application folder, or ask which one.

## What it does
1. Run the export script against the application folder (the folder must resolve to a path under
   `02_applications/`; quote it). Bash is used **only** to invoke this one bundled script, with the
   application folder as its single argument; it runs no other shell commands.
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/export-docs.sh" "<application-folder>"
   ```
2. The script:
   - Uses **Pandoc** with the bundled ATS reference template (`assets/reference.docx`) to produce
     `final/cv.docx` and `final/letter.docx`: styled, single-column, black-only.
   - If **Pandoc is not installed**, falls back to a clean self-contained `final/cv.html` /
     `letter.html` the user can open and "Print to PDF" or paste into Word. It says clearly that it
     produced HTML, not DOCX, and how to get DOCX (install Pandoc).
3. Report exactly what was produced (`.docx` vs `.html`) and where, reading the script's `RESULT=` line.

## Output

When Pandoc is present (the normal case), the script prints:

```
Exporting documents into: 02_applications/2026-06-Acme-Manager/final/
  docx:  final/cv.docx (ATS-styled)
  docx:  final/letter.docx (ATS-styled)
RESULT=docx
```

When Pandoc is absent, it falls back to HTML and says so:

```
Exporting documents into: 02_applications/2026-06-Acme-Manager/final/
  html:  final/cv.html (Pandoc not found — open and Print to PDF, or paste into Word)
  html:  final/letter.html (Pandoc not found — open and Print to PDF, or paste into Word)

NOTE: Pandoc was not found, so HTML was produced instead of DOCX.
RESULT=html
```

Read the final `RESULT=docx|html|none` line and tell the user plainly which format landed in `final/`.

## Rules
- **Never silently downgrade.** If the output is HTML because Pandoc is missing, say so plainly; the
  user must know they don't have a Word file yet.
- **Source of truth is the Markdown.** Export reads `cv.md`/`letter.md`; it never rewrites them.
- **ATS-safe only.** Do not introduce multi-column layouts, text boxes, tables for layout, images, or
  headers/footers; they break ATS parsing. Styling is typographic (weight, spacing, rules) only.
- Re-running is safe; it overwrites the files in `final/` with fresh exports.

## Customising the look
The styling lives in `assets/reference.docx`, generated reproducibly by
`scripts/build-reference-docx.sh`. To change fonts, sizes, or spacing, edit that script and re-run it;
do not hand-edit the binary. Keep it single-column and ATS-safe.

## Relationship to the pipeline
The main `/job-application` pipeline calls this export automatically as its final step (Stage 9.6).
Use `/job-export` on its own when you've hand-edited a draft and want fresh documents without
re-running the whole pipeline.
