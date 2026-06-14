---
name: job-setup
description: "Scaffold a fresh ICM job-application workspace on the user's machine. Use when the user says /job-setup, 'set up my job application workspace', 'create the CV workspace', or has just installed the job-application plugin and needs the folder structure. Creates the 00_master factory, 01_intake, 02_applications, _archive, _templates, the Kanban board, tracker, CLAUDE.md map, and a non-destructive permissions allowlist. Idempotent: never overwrites a file the user has already filled in. Also handles --mine-archive to build experience-bank.md and voice.md from the user's past applications dropped in _archive/. NOT for tailoring an individual application (use /job-application for that); this only creates the empty workspace."
---

# Job-Setup

Scaffold an ICM job-application workspace, then point the user at the next steps. This is the
installer the user runs once after installing the plugin.

## Inputs
- An optional **target path** as the argument (`$ARGUMENTS`). If absent, ask the user where they
  want the workspace (suggest `~/Documents/Job Applications`). Never guess silently.
- Optional flag `--mine-archive`: skip scaffolding, instead mine `_archive/` into the factory.

## What it does (default)

1. **Confirm the target path** with the user if not given. Expand a leading `~`.
2. **Run the scaffolding script** (idempotent; will not overwrite filled files). Bash is used **only**
   to invoke this one bundled script with the target path as its single argument; it runs no other
   shell commands.
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/setup-workspace.sh" "<target-path>"
   ```
   This copies the blank template factory, the ICM `CONTEXT.md` contracts, the `CLAUDE.md` map,
   the Kanban board, the tracker, and a project-local `.claude/settings.json` allowlist.
3. **Report what was created vs. skipped** (the script prints this; see `## Output`).
4. **Tell the user the three next steps**, in order:
   - Fill `00_master/master-cv.md` and `voice.md` with their real facts (replace every `[FILL IN]`).
   - Drop past CVs / cover letters into `_archive/`, then run `/job-setup --mine-archive`.
   - Run `/job-application <job-url>` to produce their first tailored application.
5. **Offer to open `master-cv.md`** and walk them through filling it, if they want help.

## Output

The script prints a per-file create/skip report, then the next steps:

```
Scaffolding ICM job-application workspace at: ~/Documents/Job Applications
  create:        00_master/master-cv.md
  create:        00_master/voice.md
  skip (exists): CLAUDE.md
  create:        .claude/settings.json (non-destructive allowlist)

Done. Next:
  1. Fill 00_master/master-cv.md and voice.md with your real facts.
  2. Drop past CVs / cover letters into _archive/ to build experience-bank.md.
  3. Run the pipeline:  /job-application:job-application <job-url>
```

On a re-run, every existing file shows `skip (exists)`, confirming nothing was clobbered.

## --mine-archive mode

When the user has put past applications in `_archive/` and wants the factory populated from them:

1. Read every file in `<workspace>/_archive/` (CVs, cover letters, any format you can read).
2. Extract, into `00_master/experience-bank.md`:
   - Real achievement bullets (verbatim or lightly cleaned, never invented).
   - The target-role angles the user has applied to before.
   - Consistent self-description phrases.
3. Derive the user's letter voice into `00_master/voice.md` (tone, signature phrases, spelling).
4. **Never fabricate.** Only surface what is actually in the archive. If the archive is thin, say so
   and leave `[FILL IN]`s in place rather than inventing content.
5. Show the user a diff of what you added and let them approve before writing.

## Rules
- **Idempotent.** Re-running never clobbers a filled-in file. The script handles this; respect it.
- **No invented identity.** The templates ship blank. You fill them only from what the user gives you
  (their typed facts or their `_archive/` files). Never paste in example data as if it were theirs.
- **One workspace per person.** If the target already looks scaffolded, say so and offer
  `--mine-archive` or `--force-context` instead of re-creating.
- **Gate `--force-context`.** This flag overwrites the scaffolding files (`CONTEXT.md`, `CLAUDE.md`)
  with fresh copies; it never touches `00_master/*.md` user content. Before running with it, show the
  user exactly which files will be replaced and get a clear yes first.
- After scaffolding, the workspace's own `CLAUDE.md` becomes the routing map for all later work there.
