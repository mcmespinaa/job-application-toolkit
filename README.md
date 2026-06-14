# Job Application Toolkit

**Turn any job ad into a tailored, ready-to-send application, a fit score, a CV, a cover letter, and answers to the application form's questions, all written from _your own_ real experience, never invented.**

You give it a job link. It reads the ad, scores how well you match, then writes a CV and cover letter tuned to that specific role, cleans them up, and saves them as Word documents you can upload. Everything stays on your computer.

> **It never makes things up.** The toolkit ships with **blank** templates. You fill in your real CV details once, and every application is built only from those facts. If a job wants something you don't have, it tells you honestly instead of inventing it.

If you've never used a tool like this before, follow the steps below in order. It takes about 15 minutes to set up the first time, then a couple of minutes per job after that.

> **Prefer a visual guide?** There's a friendly landing page with a step-by-step walkthrough at
> **[mcmespinaa.github.io/job-application-toolkit](https://mcmespinaa.github.io/job-application-toolkit/)**.

---

## Table of contents

1. [What "ATS-ready" means (and why it matters)](#what-ats-ready-means)
2. [What you'll need first](#step-0-what-youll-need)
3. [Step 1: Install Claude Code](#step-1-install-claude-code)
4. [Step 2: Install this toolkit](#step-2-install-this-toolkit)
5. [Step 3: Create your workspace](#step-3-create-your-workspace)
6. [Step 4: Fill in your details (do this once)](#step-4-fill-in-your-details-once)
7. [Step 5: Apply to your first job](#step-5-apply-to-your-first-job)
8. [Step 6: Review and send](#step-6-review-and-send)
9. [Everyday use after setup](#everyday-use-after-setup)
10. [Optional extras](#optional-extras-pandoc-google-drive-obsidian)
11. [Troubleshooting](#troubleshooting)
12. [How it works under the hood](#how-it-works-under-the-hood)
13. [FAQ](#faq)
14. [Support](#support) · [License](#license)

---

## What "ATS-ready" means

Most companies run your CV through an **ATS** (Applicant Tracking System) before a human ever sees it. That software reads your CV as plain text and looks for the exact words from the job ad. Fancy CVs with columns, sidebars, icons, or photos often confuse it, your experience gets scrambled or skipped, and you're filtered out before page one.

This toolkit writes CVs that **look clean and professional but stay machine-readable**: one column, standard headings, real keywords from the ad (only where you genuinely match them). That's the whole point of "ATS-ready."

---

## Step 0: What you'll need

You install a few free tools once. The toolkit can't install them for you, so here's exactly what and why:

| Tool | Do you need it? | What it's for |
|------|-----------------|---------------|
| **Claude Code** | **Required** | The app that runs this toolkit. (Step 1 below.) |
| **A Claude account** | **Required** | Claude Pro/Max subscription _or_ an Anthropic API key. Either works. |
| **Pandoc** | Strongly recommended | Turns your CV into a real **Word (.docx)** file. Without it you still get a clean web-page version you can print to PDF. |
| **Git** | Usually already installed | Used behind the scenes to fetch the plugin. Check with `git --version`. |
| Google account | Optional | Only if you want copies saved to Google Drive. |
| Obsidian | Optional | Only if you like viewing your applications as a visual board. |

Don't worry about the optional ones yet. You can add them later.

---

## Step 1: Install Claude Code

Claude Code is a free app from Anthropic. Pick the way you prefer:

**Option A, Terminal (recommended, works everywhere):**

```bash
# macOS / Linux
curl -fsSL https://claude.ai/install.sh | bash
```
```powershell
# Windows (PowerShell)
irm https://claude.ai/install.ps1 | iex
```

**Option B, Inside VS Code (if you use the VS Code editor):**

Open VS Code, press `Cmd+Shift+X` (Mac) or `Ctrl+Shift+X` (Windows/Linux), search **"Claude Code"** by Anthropic, and click **Install**.

**Then check it worked:**

```bash
claude --version
```

You should see a version number. Now start it:

```bash
claude
```

The first time, it opens your browser to log in. Sign in with your **Claude Pro/Max** account, or paste an **Anthropic API key** if that's what you have. You only do this once.

> **New to all this?** A "terminal" is the black text window on your computer, **Terminal** app on Mac, **PowerShell** on Windows. Copy a command, paste it in, press Enter.

---

## Step 2: Install this toolkit

With Claude Code running (you'll see a prompt waiting for input), type these two lines, pressing Enter after each:

```text
/plugin marketplace add mcmespinaa/job-application-toolkit
```
```text
/plugin install job-application@job-application-toolkit
```

- The **first** line tells Claude Code where to find this toolkit (this GitHub page).
- The **second** line installs it.

If the new commands don't show up right away, type `/reload-plugins` and press Enter.

> **What just happened?** Claude Code downloaded this repository and registered its commands (`/job-setup`, `/job-application`, `/job-export`). Nothing ran on your files yet, that's the next step.

---

## Step 3: Create your workspace

Now build the folder where all your applications will live. Run:

```text
/job-application:job-setup ~/Documents/Job Applications
```

(You can use any folder path you like. `~/Documents/Job Applications` is a good default.)

You'll see it create a set of folders and report each one, ending with **"Done. Next: …"**. Here's what it made and what each part is for:

```
Job Applications/
├── 00_master/              ← YOUR facts live here (you fill these in next)
│   ├── master-cv.md          your CV: contact, jobs, education, skills
│   ├── voice.md              how your cover letters should sound
│   └── experience-bank.md    reusable phrases (built from your old applications)
├── 01_intake/              ← where a new job ad gets scored before you commit
├── 02_applications/        ← one folder per company you apply to (the results)
├── _archive/               ← drop your OLD CVs/letters here for the tool to learn from
├── _templates/             ← blank starting templates (leave these alone)
├── Applications Board.md   ← a Kanban board tracking every application's status
└── TRACKER.md              ← deeper notes per application
```

It's **safe to run again**, it never overwrites anything you've already filled in.

---

## Step 4: Fill in your details (once)

This is the only part that takes real effort, and you only do it once. Open the new `Job Applications` folder in any text editor (or in VS Code).

**4a. Your CV facts.** Open `00_master/master-cv.md` and replace every `[FILL IN]` with your real information: name, contact details, each job you've held, education, and skills. Write plainly and truthfully, this is the single source the toolkit draws from.

**4b. Your voice.** Open `00_master/voice.md` and fill in how you like your cover letters to sound (warm? formal? direct?). There are prompts to guide you.

**4c. (Recommended) Learn from your past applications.** Drop any old CVs or cover letters (any format, `.pdf`, `.docx`, `.md`) into the `_archive/` folder. Then run:

```text
/job-application:job-setup --mine-archive
```

This reads your past writing and fills in `experience-bank.md` (reusable bullet points) and refines your `voice.md`, so future drafts sound like _you_. It shows you what it found and asks before saving. If your archive is empty, just skip this; it won't invent anything.

> **Tip:** The more honest detail you put in `master-cv.md`, the better every application will be. Include the real tools and systems you've used, the toolkit matches those against job ads.

---

## Step 5: Apply to your first job

Find a job ad online and copy its link. Then run:

```text
/job-application:job-application <paste-the-job-link-here>
```

For example:

```text
/job-application:job-application https://careers.example.com/jobs/12345
```

If the link is behind a login (some LinkedIn or Workday pages are), the toolkit will ask you to paste the ad's text or a screenshot instead. That's normal.

**What it does, in order:**

1. **Reads the ad**, pulls out the role, must-haves, nice-to-haves, and the exact keywords.
2. **Scores your fit**, gives you a number out of 100 with a clear breakdown of where you match and where you fall short (honestly).
3. **Picks the right tone**, matches how the company writes (plain and formal, or warm and energetic).
4. **Writes your CV**, tuned to this role, leading with your strongest matches.
5. **Writes your cover letter**, one page, in your voice, tied to the company.
6. **Drafts form answers**, salary range (researched for your role + city), notice period, work authorisation, marking anything only _you_ can answer with `[FILL IN]`.
7. **Cleans everything**, removes "AI-sounding" phrasing and over-the-top language.
8. **Saves the documents**, as Word files in a new folder.

When it finishes, you'll have a new folder like this:

```
02_applications/2026-06-Example-Marketing-Manager/
├── brief.md          ← the fit score and where you match / fall short
├── cv.md             ← your tailored CV (editable text)
├── letter.md         ← your tailored cover letter (editable text)
├── form-answers.md   ← salary / notice / work-permit answers
└── final/
    ├── cv.docx       ← ready-to-upload Word CV
    └── letter.docx   ← ready-to-upload Word cover letter
```

---

## Step 6: Review and send

The toolkit ends with a **"Before you submit"** checklist. **Always read it.** It flags:

- Every `[FILL IN]` only you can answer (your exact salary number, notice period, work-permit status).
- Any honest gaps, places where you don't fully match, so you're not caught off guard in an interview.
- The application rule from the ad (e.g. "apply only through our portal," or a required language).

Open the files in `final/` (`cv.docx`, `letter.docx`), do a final read, fill in the blanks, and submit them wherever the ad says to. **You always have the last look before anything is sent, the toolkit never submits for you.**

Edited a draft by hand and want fresh Word files? Re-export just that folder:

```text
/job-application:job-export 02_applications/2026-06-Example-Marketing-Manager
```

---

## Everyday use after setup

Once your details are in, each new application is just **one command**:

```text
/job-application:job-application <job-link>
```

Other handy commands:

| Command | What it does |
|---------|--------------|
| `/job-application:job-application score <link>` | Just score the fit and stop, decide whether it's worth applying before drafting. |
| `/job-application:job-application <link> --no-drive` | Run normally but skip the Google Drive copy. |
| `/job-application:job-export <folder>` | Re-make the Word files after you hand-edit a draft. |
| `/job-application:job-setup --mine-archive` | Re-learn your voice after adding more past applications to `_archive/`. |

Your **Applications Board.md** keeps track of where each company sits (Drafting → Submitted → Interview → etc.). Open it to see everything at a glance.

> **Keeping your CV current?** When your experience changes (new job, new skill), update `00_master/master-cv.md` once. Every future application picks it up automatically, you never edit the toolkit itself.

---

## Optional extras (Pandoc, Google Drive, Obsidian)

### Pandoc, for real Word documents

Without Pandoc, the toolkit still produces a clean, printable **HTML** file (open it in a browser, then "Print → Save as PDF," or paste into Word). With Pandoc, you get proper **.docx** files. To install it:

- **macOS:** `brew install pandoc`
- **Windows:** `winget install pandoc` (or download from [pandoc.org/installing](https://pandoc.org/installing.html))
- **Linux:** `sudo apt install pandoc` (or your distro's package manager)

The toolkit detects Pandoc automatically and always tells you which format it produced, it never silently gives you the lesser one.

### Google Drive, automatic cloud copies

Want each CV + letter also saved as a Google Doc in your Drive? You connect Google Drive once, and
how you do it depends on where you run Claude Code:

- **Desktop app:** click the **+** next to the prompt box, choose **Connectors**, pick **Google Drive**, and sign in.
- **VS Code extension:** there's no Connectors menu here. Type `/mcp` in the chat panel to connect Google Drive. If it isn't listed yet, run `claude mcp add google-drive` in the integrated terminal first, then use `/mcp` to sign in.
- **Terminal CLI:** in a `claude` session, type `/mcp` to connect. If it isn't listed, run `claude mcp add google-drive` once, then `/mcp` to sign in.

Once connected, the toolkit detects it and syncs automatically. Add `--no-drive` to any run to skip it.
Your documents always land in your local `final/` folder regardless.

### Obsidian, a visual application board

Your workspace is plain text, so it opens directly as an [Obsidian](https://obsidian.md) vault if you use one. With the Kanban community plugin, `Applications Board.md` becomes a drag-and-drop board. Entirely optional, the toolkit works fine without it.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| **The `/job-application` commands don't appear** | Run `/reload-plugins`, or restart Claude Code. Confirm install with `/plugin` (your plugin should be listed and enabled). |
| **"Can't find a workspace" / it asks you to run setup** | You haven't scaffolded yet, or you're in the wrong folder. Run `/job-application:job-setup <path>` first, and make sure Claude Code is opened in (or pointed at) that folder. |
| **The job link won't load** | Some sites block automated reading (LinkedIn, some Workday pages). Just paste the ad's text or a screenshot when asked. |
| **I got `.html` files, not `.docx`** | Pandoc isn't installed. Install it (see above) and re-run `/job-application:job-export <folder>`. The HTML is perfectly usable in the meantime, open it and print to PDF. |
| **The CV claims something I didn't do** | It shouldn't, report it. The toolkit is built to use only what's in `00_master/`. Check that your `master-cv.md` is accurate; that's the only source it reads. |
| **Permission prompts on every step** | `/job-setup` writes a `.claude/settings.json` that pre-approves safe, read-only commands. Make sure you ran setup, and that Claude Code is opened in your workspace folder so it reads that file. |

---

## How it works under the hood

This is built on the **ICM (Integrated Context Method)**, a way of organising folders so an AI always has the right context. The short version:

- **`00_master/` is the "factory"**, your stable, real facts. It's the single source of truth and is never changed while drafting.
- **`02_applications/` holds the "products"**, each tailored application, built fresh from the factory for one specific job.
- A job ad flows left to right: **score it** (`01_intake`) → **build the application** (`02_applications`) → **export the documents** (`final/`).

This separation is why the toolkit can be both _tailored_ (every CV fits the specific ad) and _honest_ (every fact traces back to your master file). Learn more about the method: [folder-structure-protocol](https://github.com/mcmespinaa/folder-structure-protocol).

**Repo layout:**

```
job-application-toolkit/
├── .claude-plugin/marketplace.json     # how Claude Code finds the plugin
├── README.md                           # this guide
└── plugins/job-application/
    ├── .claude-plugin/plugin.json      # plugin manifest
    ├── skills/                         # the commands: job-setup, job-application,
    │                                   #   job-export, slop-proof, nordic-style
    ├── templates/                      # the BLANK workspace copied to your machine
    ├── assets/reference.docx           # the ATS Word styling template
    └── scripts/                        # the folder scaffolder + document exporter
```

Everything runs **locally and offline**, the scripts make no network calls, send no data anywhere, and collect nothing about you.

---

## FAQ

**Is my personal data uploaded anywhere?**
No. Your CV and applications live in your local folder. The only optional exception is Google Drive sync, which _you_ turn on and which goes to _your_ own Drive.

**Will it lie to make me look better?**
No, that's the core design rule. It uses only what you put in `00_master/`, scores you honestly, and flags gaps rather than papering over them. Better to get the interview and pass than to over-claim and fail the case study.

**Do I need to know how to code?**
No. You copy and paste a few commands, then fill in a CV template in a text editor. That's it.

**Does it submit applications for me?**
No. It prepares everything and hands it to you with a checklist. You do the final review and submit.

**Can my whole family / team use it?**
Yes. Each person installs it and runs `/job-setup` to make their _own_ workspace with their _own_ facts. The toolkit ships blank, it contains no one's personal data.

**It's missing a skill I want / something broke.**
Open an issue on the GitHub repo. Contributions welcome.

---

## Support

This toolkit is free and open-source. If it helped you land an interview or saved you time, you can say thanks here: **[buymeacoffee.com/mcmespinaa](https://buymeacoffee.com/mcmespinaa)**. No pressure, and no email or sign-up is ever required to use anything in this repo.

## License

MIT, free to use, modify, and share.
