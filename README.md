# Job Application Toolkit

Turn any job post into a tailored, ATS-ready application — match score, CV, cover letter, and form
answers — grounded in **your own** experience and never invented. It ships as a Claude Code plugin
plus an ICM-structured workspace it scaffolds for you.

> You bring your own facts. The toolkit ships with **blank** templates: you fill in your CV details
> and drop your past CVs / cover letters into `_archive/`. Nothing about any other person is included.

Built on the [ICM five-layer context method](https://github.com/mcmespinaa/folder-structure-protocol):
a stable **factory** (`00_master/`) feeds per-company **products** (`02_applications/`).

---

## What you get

- **`/job-setup`** — scaffolds your job-application workspace (factory, intake, applications, archive, Kanban board, tracker, ICM contracts) on your machine, once.
- **`/job-application <job-url>`** — the full pipeline: parse the ad → score the fit → draft a tailored CV + cover letter → draft form answers → export documents into `final/` → file it in the workspace and (optionally) sync to Google Drive.
- **`/job-export`** — turn a finished application's `cv.md` + `letter.md` into **ATS-styled DOCX** documents in `final/` (or HTML if Pandoc isn't installed). Runs automatically inside the pipeline; use it standalone after you hand-edit a draft.
- **`slop-proof`** and **`nordic-style`** — cleaning passes that run automatically over every draft.

---

## Prerequisites (you install these yourself)

A plugin cannot install system tools for you. Before you start, have:

| Tool | Why | Check |
|------|-----|-------|
| **Claude Code** (CLI, or the VS Code extension) | runs the plugin | `claude --version` |
| **git** | install from GitHub | `git --version` |
| **Node.js + npm** | HTML export fallback; self-hosted MCP | `node --version` |
| **Pandoc** *(recommended)* | export CVs/letters as ATS-styled **Word** docs | `pandoc --version` |
| **Obsidian + Obsidian CLI** *(optional)* | view the board/tracker as a vault | `obsidian --version` |
| **A Google account** *(optional)* | Google Drive sync of drafts | — |

> Without Pandoc you still get documents — the exporter falls back to clean, printable HTML and tells
> you so. Install Pandoc ([pandoc.org/installing](https://pandoc.org/installing.html)) for native `.docx`.

---

## Install (one GitHub link, two commands)

In Claude Code:

```text
/plugin marketplace add mcmespinaa/job-application-toolkit
/plugin install job-application@job-application-toolkit
```

The first command registers this repo as a plugin marketplace; the second installs the plugin from it.
Run `/reload-plugins` if the new commands don't appear immediately.

Then scaffold your workspace:

```text
/job-application:job-setup ~/Documents/Job Applications
```

(Use any path you like. It's created if missing and is **safe to re-run** — it never overwrites a file
you've already filled in.)

---

## First-time setup (the parts that are yours to do)

1. **Fill your factory.** Open the new workspace and replace every `[FILL IN]` in:
   - `00_master/master-cv.md` — your contact details, work history, education, skills.
   - `00_master/voice.md` — how your cover letters should sound.
2. **Seed your archive.** Drop your previous CVs and cover letters into `_archive/`, then run:
   ```text
   /job-application:job-setup --mine-archive
   ```
   This builds `experience-bank.md` (reusable bullets) and refines `voice.md` from **your** past
   writing. Nothing is invented — if the archive is thin, it leaves `[FILL IN]`s for you.
3. **Run your first application:**
   ```text
   /job-application:job-application https://link-to-the-job-ad
   ```

---

## Using it in VS Code

1. Install the **Claude Code** extension from the VS Code Marketplace.
2. Open your workspace folder (`File → Open Folder…` → the `Job Applications` directory).
3. Open the Claude Code panel and run the commands above. The extension reads the project's
   `.claude/settings.json` (created by `/job-setup`) for permissions.
4. **Permissions.** So Claude can scaffold folders and read job ads without prompting on every step,
   `/job-setup` writes a project `.claude/settings.json` allowing only **non-destructive** commands:
   `WebSearch`, `WebFetch`, `curl`, `jq`, `cat`, `ls`, `grep`, `echo`, `which`, `wc`, `file`, `pwd`,
   `mkdir`, `touch`, `head`, `tail`, `find`, `sort`, `tree`, `diff`, `node`, `npm`, `npx`,
   `git status`, `git diff`, `git log`. No file-deleting or history-rewriting commands are allowed.
   Review the file and trim or extend it to taste.

---

## Where your documents land

Every run writes finished documents straight into the application folder — **no Obsidian, no Google
Drive, no account required**:

```
02_applications/2026-06-Acme-Manager/
├── cv.md · letter.md           # editable source
└── final/
    ├── cv.docx                 # ATS-styled Word document (single column, ready to upload)
    └── letter.docx             # (or cv.html / letter.html if Pandoc isn't installed)
```

The `.docx` files are **ATS-optimised**: one column, standard Word heading styles, a clean black-only
typographic hierarchy (bold name, ruled section headers). They look designed but parse cleanly in
applicant tracking systems — which is why there are no multi-column layouts, sidebars, icons, or
tables (all of which break ATS extraction).

Edited a draft? Re-export without re-running the whole pipeline:

```text
/job-application:job-export 02_applications/2026-06-Acme-Manager
```

Want to tweak the CV's look (font, sizes, spacing)? Edit
`plugins/job-application/scripts/build-reference-docx.sh` and re-run it; it regenerates
`assets/reference.docx`, the template every export is styled from. Keep it single-column and ATS-safe.

## Google Drive sync (optional)

The pipeline can save each `cv.md` + `letter.md` as a formatted **Google Doc** in
`Job Applications/<Company>/` on your Drive.

**Recommended:** connect Google Drive through **Claude's built-in connectors**
(Claude Code / claude.ai → Settings → Connectors → Google Drive) and log in once. The pipeline detects
the connection and syncs automatically. Pass `--no-drive` to any run to skip it.

**Advanced (self-hosted):** if you'd rather run your own Drive MCP, copy
`plugins/job-application/.mcp.json.example` to `.mcp.json` and follow that server's auth steps. The
plugin can declare the server but **cannot authenticate it for you** — that login is always manual.

---

## Obsidian (optional)

The workspace is plain Markdown, so it opens directly as an Obsidian vault.

1. Install Obsidian and the [Obsidian CLI](https://github.com/Yakitrak/obsidian-cli) (or the official CLI).
2. Open the `Job Applications` folder as a vault. `Applications Board.md` renders as a Kanban board
   if you have the Kanban community plugin.
3. Claude can read/write the vault via the CLI with the app running. **Always pass the vault name
   explicitly** so you never target the wrong vault, e.g.
   `obsidian vault=JobApplications search query="acme"`.

> The vault is yours and local. Nothing syncs to anyone else unless you connect Obsidian Sync yourself.

---

## What the toolkit will and won't do

**Will:** scaffold the workspace, score honestly, draft from your real facts, mirror the ad's keywords
where you genuinely match, clean every draft, file and (optionally) sync the result.

**Won't:** invent experience, employers, titles, or metrics; claim a title you haven't held as a full
match; install your system tools; or authenticate your Google/Obsidian accounts. Those stay with you.

---

## Repo layout

```
job-application-toolkit/
├── .claude-plugin/marketplace.json        # the marketplace catalogue (install entry point)
├── README.md                              # this file
└── plugins/job-application/
    ├── .claude-plugin/plugin.json         # plugin manifest
    ├── .mcp.json.example                  # optional self-hosted Drive MCP
    ├── skills/                            # job-application, job-setup, job-export, slop-proof, nordic-style
    ├── templates/                         # the BLANK ICM workspace copied by /job-setup
    ├── assets/reference.docx              # ATS-styled Word template (single-column, black-only)
    └── scripts/
        ├── setup-workspace.sh             # idempotent scaffolder
        ├── export-docs.sh                 # md -> ATS DOCX (HTML fallback)
        └── build-reference-docx.sh        # regenerates assets/reference.docx
```

## Support

This toolkit is free and open-source. If it helped you land an interview or saved you time,
you can say thanks here: [buymeacoffee.com/mcmespinaa](https://buymeacoffee.com/mcmespinaa). No
pressure, and no email or sign-up required to use anything in this repo.

## License

MIT.
