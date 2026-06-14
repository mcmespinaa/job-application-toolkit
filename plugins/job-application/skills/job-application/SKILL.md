---
name: job-application
description: "End-to-end job application tailoring. Drop a job post (URL, pasted text, or screenshot) and this skill scores the match, then drafts an ATS-optimised CV, a tone-matched cover letter, and a form-answers file, all tailored to that role and grounded in the user's own master CV. Use when the user says /job-application, 'tailor my CV for this', 'apply to this job', 'draft a cover letter for this role', 'how well do I match this job', or pastes/links a job posting in their Job Applications workspace. Reads the 00_master/ factory files. Pairs with slop-proof and nordic-style (both run automatically as a cleaning pass)."
---

# Job-Application

Turn a job post into a complete, tailored, ATS-ready application: match score, CV, cover letter, and form answers. One command, grounded in the user's real experience, never invented.

## Where this runs

This skill runs inside the user's **Job Applications** workspace (the one created by `/job-setup`).
Find it by locating the nearest folder that contains `00_master/master-cv.md`; that folder is the
workspace root. If you cannot find a scaffolded workspace, tell the user to run `/job-setup` first.

It is an ICM pipeline: the **factory** (`00_master/`) is the stable source of truth; each application
is a **product** in `02_applications/`. NEVER invent experience, employers, titles, or metrics not
present in the master files. If the job ad wants something the user lacks, flag it, do not fabricate it.

## Inputs the skill accepts
- A **URL** to a job post -> fetch it (WebFetch). If fetch fails (auth wall, LinkedIn), ask the user to paste the text or a screenshot.
- **Pasted JD text** -> use directly.
- A **screenshot** -> read the image for the JD content.

## The Pipeline

Default behaviour: **run all stages, then pause for review** (present score + CV + letter + form answers together). Do not stop between stages unless the user asked for stage-by-stage mode.

### Stage 1: Ingest and parse the JD
Extract and record: company, role title, location, work model, seniority; **must-have requirements**;
**nice-to-haves**; **ATS keywords** (exact repeated terms, which must appear verbatim in the CV where the
user honestly has them); **stated values / mission**; **form questions** (salary, notice, work
authorisation, "why top choice").

### Stage 2: Load the factory
Read `00_master/master-cv.md`, `00_master/experience-bank.md`, `00_master/voice.md`. These are the
ONLY source of facts about the user. Read the candidate's name, contact details, and city from
`master-cv.md`. Never hardcode an identity.

### Stage 3: Score the match (weighted 0-100)
- **Must-have requirements: 70%.** Each scored Met / Partial / Gap, weighted by centrality.
- **Nice-to-haves: 15%.**
- **Keyword/domain overlap: 10%.**
- **Mission/values fit: 5%.**

Output a table: each requirement, the user's matching evidence (cite the master file), Met/Partial/Gap.
Then the weighted total and a one-line read:
- **80-100:** Strong fit, apply with confidence.
- **60-79:** Credible fit, lead hard on matches, address gaps honestly.
- **40-59:** Stretch. Worth it only if motivated; expect the gaps to be tested.
- **Below 40:** Weak fit. Say so plainly; suggest not applying or a different angle.

**Honesty rule:** a title the user has not held is a Partial at best, never a Met. Surface this explicitly.

### Stage 4: Detect employer tone
Read HOW the JD is written. Baseline = plain Nordic (modest, direct, no hype). Override when the
employer's own copy is warmer/energetic/mission-led; match their temperature and adopt their
vocabulary. State which register was chosen and why, in one line.

### Stage 5: Draft the ATS-optimised CV (`cv.md`)
From `master-cv.md`, retuned: headline aligned to the ad's title (note any honest stretch); summary
front-loading the ad's top keywords the user genuinely matches; experience reordered so matching
bullets lead, using the ad's exact phrasing where honest; skills surfacing the ad's named tools the
user actually has. ATS hygiene: simple headings, no tables/columns/graphics, standard section names,
real keywords not stuffing.

### Stage 6: Draft the cover letter (`letter.md`)
Follow `voice.md` + the Stage 4 register. Pattern: hook on the role's core problem -> evidence mapping
the user's work to the ad -> 3 value bullets -> one honest line of motivation (tied to a real fact) ->
mission-aware close with contact details. One page (~250-350 words). Do not claim titles/metrics the
user lacks.

### Stage 7: Self-clean
Run the **slop-proof** catalog AND **nordic-style** (or the detected register) over both `cv.md` and
`letter.md`. Fix tells before showing the user.

### Stage 8: Generate `form-answers.md`
- **Salary expectation**: research current market range (WebSearch) for the role+location; give a range with "depending on the overall package". Anchor to the user's level honestly. Show the reasoning.
- **Notice period**: `[FILL IN]` unless the user has stated it.
- **Work authorisation**: `[FILL IN]` (fact only the user knows).
- **"Why is this your top choice" (<=400 chars)**: a tight, warm, mission-tied version if warranted.
Mark every item needing the user's real input with `[FILL IN]`.

### Stage 9: Create the folder + tracker card
- Create `02_applications/YYYY-MM-Company-RoleTitle/` with `cv.md`, `letter.md`, `brief.md`, `form-answers.md`, and an empty `final/`.
- Add a card to `Applications Board.md` in the **Drafting** lane: `**Company** — Role, Location. Found via X. Score: N/100. Next: review + fill flagged items.`
- Add a `TRACKER.md` section only when the application needs more than a card: a score below 60, 3+ flagged `[FILL IN]` items, or contact/interview notes to keep.

### Stage 9.5: Sync drafts to Google Drive (optional, best-effort)
If the Google Drive MCP is connected, push the two submittable drafts (`cv.md`, `letter.md`) to Drive
as formatted Google Docs, mirroring the local folder. If Drive is not connected or any call fails,
log it, note the local files are intact, and continue; never block on Drive.

**Find-or-create, never blind-create** (idempotent):
1. **Parent folder.** Search `title = 'Job Applications' and mimeType = 'application/vnd.google-apps.folder' and parentId = 'root'`. Reuse the id, or create the folder. (This MCP's `search_files` does NOT support a `trashed` field — don't add one; it errors.)
2. **Company subfolder.** Search for `<YYYY-MM-Company-RoleTitle>` with `parentId = '<parent id>'`. Reuse or create.
3. **The two Docs.** For each of `cv.md`/`letter.md`, `create_file` with `parentId: <company folder id>`, `contentMimeType: text/plain`, `textContent: <the markdown>`, `title: <Company> <Role> — CV` / `— Cover Letter`. Leave conversion ON (do NOT set `disableConversionToGoogleType`); Markdown headings/bullets import as real Doc structure.
4. Surface the Drive folder link in Stage 10.

Only `cv.md` and `letter.md` go to Drive (they're submittable). `brief.md` and `form-answers.md` stay local (internal scoring + `[FILL IN]`s). Skip this whole stage if the user passed `--no-drive`.

### Stage 9.6: Export documents into `final/` (local, always)
Generate real document files so the application lands in the folder regardless of Obsidian/Drive.
Run the export script against the new application folder (a path under `02_applications/`; quote it).
Bash is used **only** to invoke this one bundled script with the application folder as its single
argument; it runs no other shell commands.
```
bash "${CLAUDE_PLUGIN_ROOT}/scripts/export-docs.sh" "<application-folder>"
```
- Produces **ATS-styled DOCX** (`final/cv.docx`, `final/letter.docx`) via Pandoc + the bundled
  `assets/reference.docx`: single-column, standard heading styles, black-only typographic hierarchy.
- If Pandoc is absent, it falls back to clean **HTML** in `final/` and says so. Never silently downgrade.
- Read the script's `RESULT=docx|html|none` line and report which was produced.
This stage always runs (it has no external dependency beyond an optional Pandoc); it is the local
counterpart to the optional Drive sync.

### Stage 10: Present & flag
Show the score breakdown, the two drafts, the form answers, the exported files in `final/`, and the
Drive link (if synced). Then a
short **"Before you submit"** list of every `[FILL IN]` and every honest gap (metrics, dates, salary,
work authorisation). End by stating the ad's submission rule (platform-only, language, etc.).

## Output summary
```
02_applications/YYYY-MM-Company-Role/
  brief.md · cv.md · letter.md · form-answers.md
  final/
    cv.docx · letter.docx        # ATS-styled documents (or .html if Pandoc absent)
```
Plus a Kanban card, and (if Drive is connected) `cv.md` + `letter.md` as Google Docs in
`Job Applications/<YYYY-MM-Company-Role>/`. The `final/` documents always land locally, with no Obsidian
or Drive required.

## Rules
1. **Never invent.** No experience, employer, title, date, or metric absent from `00_master/`. Flag gaps.
2. **ATS keywords must be earned.** Exact phrasing only where the user genuinely has the experience.
3. **Honest scoring.** A stretch is a stretch. Better to under-claim and get the interview.
4. **Match the employer's register**, not a stereotype.
5. **Always self-clean.** slop-proof + nordic-style before presenting.
6. **Mark what only the user knows** with `[FILL IN]`.
7. **Respect submission rules** in the ad and surface them.
8. **Drive sync is best-effort and idempotent.** Only cv+letter, find-or-create folders, never block on failure.

## Modes (optional args)
- `/job-application <link>` -> full pipeline (default).
- `/job-application score <link>` -> Stage 1-3 only: parse + score + stop.
- `/job-application letter <link>` -> draft only the cover letter.
- `/job-application cv <link>` -> draft only the tailored CV.
- Append `--no-drive` to any mode to skip the Google Drive sync (Stage 9.5).

## Pairing & maintenance
- Reads the **factory** (`00_master/`). If the user's experience changes, update the master, not this skill.
- Calls **slop-proof** and **nordic-style** as the cleaning pass.
- Writes to the **Kanban board** and **TRACKER.md** so the pipeline has memory.
- If the same gap (e.g. "no quantified metrics") blocks scoring across many applications, tell the user; that is a master-file fix, not a per-application one.
- If the workspace is an Obsidian vault, the board and tracker render natively; keep them as plain Markdown.
