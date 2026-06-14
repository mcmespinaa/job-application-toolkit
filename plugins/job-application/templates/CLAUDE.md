# Job Applications — Map

Your job-application workspace, structured as an ICM tailoring pipeline: a stable **factory**
(`00_master/`) feeds per-company **products** (`02_applications/`). Use it to turn a job ad into a
tailored CV + cover letter that stay true to your real experience.

## Routing
| Task | Go to | Read first |
|------|-------|------------|
| Check / update application status | `Applications Board.md` (Kanban) | drag cards between lanes |
| Read deeper application notes | `TRACKER.md` | `TRACKER.md` |
| Add a new job ad / score fit | `01_intake/` | `01_intake/CONTEXT.md` |
| Draft a tailored CV + letter | `02_applications/<company>/` | `02_applications/CONTEXT.md` |
| Update CV facts / achievements / voice | `00_master/` | `00_master/CONTEXT.md` |
| Mine past applications for phrasing | `_archive/` (read-only) | `_archive/CONTEXT.md` |
| Get a blank export template | `_templates/` (read-only) | `_templates/CONTEXT.md` |

## Pipeline (left to right)
`00_master` (source of truth) → `01_intake` (JD + fit brief) → `02_applications/<company>` (tailored CV + letter → `final/` PDFs)

## Identity
Candidate: **[FILL IN — your name]**, **[FILL IN — your role/discipline]**, based in **[FILL IN — city]**.
All tailoring must read facts from `00_master/`; never invent experience, employers, or metrics.

## Naming conventions
- Application folders: `02_applications/YYYY-MM-Company-RoleTitle/`
- Per-application files: `cv.md`, `letter.md`, `brief.md`; exports in `final/`
- Intake files: `01_intake/<company>-jd.*` and `<company>-brief.md`
- Master files: lowercase-kebab (`master-cv.md`, `experience-bank.md`, `voice.md`)

## Read-only folders
`_archive/` (historical record), `_templates/` (base templates), `00_master/` from inside Stage 2.

## Structure Rules
- New applications ONLY in `02_applications/`, one subfolder per company. Never in `_archive/`.
- Never edit `00_master/` while drafting an application — it's upstream reference.
- Every new folder gets a `CONTEXT.md` before content.
