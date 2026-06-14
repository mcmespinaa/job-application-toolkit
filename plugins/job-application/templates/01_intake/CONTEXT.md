# 01_intake — Job ad in, fit brief out

**Layer 2 (stage contract).** Where a raw job ad becomes a scored fit brief before you invest in drafts.

## Inputs
- A job ad: URL, pasted text, or screenshot.

## Process
- Run `/job-application:job-application score <link-or-paste>` to parse + score without drafting.
- The pipeline extracts: company, role, location, must-haves, nice-to-haves, ATS keywords, values, form questions.

## Outputs
- `<company>-jd.md` — the captured ad text.
- `<company>-brief.md` — the fit score + requirement-by-requirement map.

Once a brief scores well enough to pursue, run the full pipeline to produce the `02_applications/` product.
