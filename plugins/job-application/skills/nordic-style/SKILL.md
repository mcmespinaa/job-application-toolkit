---
name: nordic-style
description: "Rewrite English copy into the plain, direct, understated register that Nordic (Danish, Swedish, Norwegian) professionals use and expect. Strips American-style hype, superlatives, and hard-selling; favours short sentences, modesty, and substance over persuasion. Two modes: audit (flag every non-Nordic tell with a fix) and rewrite (apply the fixes, preserving facts and meaning). Use when the user says /nordic-style, 'make this sound Nordic/Scandinavian/Danish/Swedish', 'plain Nordic tone', 'less American', 'understated', 'tone this down for a Nordic audience', or is writing a cover letter, email, or copy aimed at a Nordic company or reader. Pairs well with /slop-proof (run slop-proof first to remove AI tells, then nordic-style for register)."
---

# Nordic-Style

Rewrite English copy into the register Nordic professionals actually use: plain, direct, modest, and efficient. The goal is substance over style, clarity over persuasion, and respect for the reader's time. American business English sells; Nordic business English states.

## Core Principle

Nordic communication is **low-context, understated, and egalitarian**. Shaped by the Law of Jante (Janteloven), it discourages self-promotion, boasting, and exaggeration. A reader in Copenhagen, Stockholm, or Oslo trusts plain claims and distrusts hype. So the rewrite does not add polish. It removes it. It keeps every fact and the author's meaning, and changes how confident, salesy, or ornamental the language sounds.

Two failure modes to avoid in equal measure:
1. **Under-correcting** leaves American hype ("I'm the perfect fit", "world-class", "passionate about leveraging synergies").
2. **Over-correcting** produces stilted, robotic, or broken English, or strips out keywords a recruiter/ATS needs. Plain is the target, not bland or grammatically odd. Never insert fake "Danish-English errors."

## Modes

**Audit** (default when asked to check, score, or review tone): scan the text, report every non-Nordic tell with location, severity, and a suggested fix. Do not modify the text.

**Rewrite** (when asked to make Nordic, tone down, plain-ify, or fix): apply the fixes while preserving facts, claims, meaning, and necessary keywords. Show what changed and why.

If the request is ambiguous, audit first, then offer the rewrite.

## The Nordic Catalog

### Tier 1: Hype and superlatives (severity: High)

American copy reaches for intensity. Nordic copy states the fact and trusts it to land. Flag every occurrence:

| American / salesy | Nordic-plain |
|-------------------|--------------|
| "I am the perfect candidate / a perfect fit" | "I believe I can contribute" / "the role fits what I do" |
| "world-class", "best-in-class", "cutting-edge", "industry-leading" | name the actual thing, or cut the adjective |
| "passionate about", "thrilled", "excited to" (stacked) | "I care about", "I would like to", "I look forward to" (use once, not every line) |
| "proven track record of delivering exceptional results" | "I have done X" (state the work) |
| "I would love the opportunity to" | "I would like to" / "I would be glad to" |
| "leverage", "synergies", "drive impact", "move the needle" | "use", "combine X and Y", "deliver results", name the result |
| "extensive / vast / deep experience" | "X years of experience" / "experience in X" |
| "spearheaded", "championed", "owned and crushed" | "led", "ran", "managed", "was responsible for" |
| exclamation marks in body copy | replace with a period |

### Tier 2: Structural register tells (severity: Medium)

Patterns, read for them:

1. **"I"-heavy self-promotion.** A paragraph where every sentence starts "I am / I have / I excel". Nordic register leans on "we" and on the work itself. Recast some "I" sentences around the task or team, and let achievements be stated plainly rather than praised.
2. **The hard-sell close.** "I am confident I would be a tremendous asset and can't wait to bring my talents to your world-class team." Replace with a calm, modest close: "I would be glad to talk about how I can contribute."
3. **Long, ornamental sentences.** Multiple clauses stacked with em dashes and "moreover/furthermore". Nordic prose is short. Break into plain sentences.
4. **Telling instead of showing soft skills.** "I have outstanding communication skills and a dynamic, results-driven personality." Cut the self-rating; state what you did.
5. **Stacked enthusiasm.** "I am incredibly passionate and deeply excited and would be honoured." One modest line of motivation is enough; more reads as performance.
6. **Status / hierarchy language.** "It would be a privilege to serve under your esteemed leadership." Nordic workplaces are flat; drop deference and write as a peer.

### Tier 3: Word choice and house style (severity: Style)

1. **Plain words over Latinate / corporate.** utilise->use, commence->start, endeavour->try, facilitate->help/run, in order to->to, prior to->before, a number of->several, at this point in time->now.
2. **British/European spelling** for Nordic readers (organise, programme, prioritise, -our endings) unless the source/JD is clearly US-spelled.
3. **No em dashes (--) or en dashes.** Use commas, periods, colons, or parentheses. (Shared house-style rule.)
4. **Sign-off:** "Kind regards" / "Best regards" / "Med venlig hilsen" if appropriate, not "Warmest wishes" or "Cheers".
5. **Dates:** day-month-year (14 June 2026), not month-day-year.

### Tier 4: False-friend and translation traps (severity: High when present)

If the author is a non-native writer translating from a Nordic language, watch for these (do not introduce them; do fix them):

| Written | Likely meant | Note |
|---------|--------------|------|
| "eventually" | "possibly" / "if needed" | DA *eventuelt* = possibly, not finally |
| "actually" | "currently" / "at present" | DA *aktuelt* = current |
| "I mean that..." | "I think that..." | DA *mener* = think/believe |
| "control" (a document) | "check" / "review" | DA *kontrollere* = to check |
| "make" (a decision/exam) | "take" / "do" | DA/SV calque |
| "since 3 years" | "for 3 years" | duration calque |
| "in the same time" | "at the same time" | |

## What NOT to Flag

False positives kill trust. Skip:

- **Necessary domain keywords.** "go-to-market", "B2B SaaS", "self-service", "API" stay even in plain copy, a recruiter and ATS need them. Plain tone never means dropping the terms that prove fit.
- **Quoted material, proper nouns, product names, company taglines.**
- **One instance of a Tier 2 pattern** in otherwise plain text. Register is about density.
- **Genuine, specific enthusiasm tied to a fact** ("I care about this mission" next to a real reason). Nordic modesty is not coldness; one honest line of motivation belongs.
- **Code, commands, file paths, identifiers.**
- **Technical/required certainty.** A safety or legal statement that must be emphatic stays emphatic.

## Audit Report Format

```markdown
# Nordic-Style Audit: [document name]

**Verdict:** [Nordic-plain / Lightly American / Heavily American]
**Register density:** [N] tells in [W] words

## Findings

| # | Line | Tell | Tier | Severity | Suggested fix |
|---|------|------|------|----------|---------------|
| 1 | 4 | "perfect fit for your world-class team" | Hype | High | "the role fits what I do" |

## Patterns (Tier 2)

[For each: name it, quote the worst instance, one-sentence fix]

## What already reads Nordic

[1-3 things to preserve in any rewrite]
```

Verdict thresholds: Nordic-plain = 0 High and at most 1 Medium per 300 words. Heavily American = 3+ High or pervasive Tier 2. In between = Lightly American.

## Rewrite Rules

1. **Fix only what the audit flagged.** Do not restyle already-plain sentences.
2. **Preserve every fact, number, name, claim, and required keyword.** Never invent metrics or experience. Never drop an ATS keyword to sound plainer.
3. **Preserve meaning and the author's intent.** Tone down, do not hollow out. The author's real motivation stays; only the performance of it goes.
4. **Shorter is the default direction.** Most fixes are deletions and word swaps. If the rewrite is longer, something went wrong.
5. **Do not break grammar to sound "more Danish."** The target is correct, plain English, not simulated non-native error.
6. **Keep one honest line of motivation.** Stripping all warmth over-corrects; Nordic modest is not Nordic cold.
7. **Show your work.** After the rewrite, list changes in a table: original, replacement, rule applied.

## Rewrite Example

Input:
> I am beyond thrilled to apply for this incredible opportunity! With my extensive, world-class experience and a proven track record of delivering exceptional results, I am confident I would be the perfect fit and a tremendous asset to your dynamic, industry-leading team. I would absolutely love to leverage my passion to drive impact.

Output:
> I would like to apply for this role. I have several years of experience in [field], and the work it involves is close to what I do now. I would be glad to talk about how I can contribute.

(Note: the rewrite keeps the application intent and would keep any real, specific details the input had. It drops the hype, the self-rating, and the hard sell. If the input named real experience or results, the rewrite keeps them, plainly stated.)

## Cleaning order

When both passes apply to the same draft, run them in this order:

1. **/slop-proof** first, to strip AI tells (banned phrases, generic structure).
2. **/nordic-style** second, to set the cultural register.

They are complementary: slop-proof removes machine-sounding language; nordic-style removes
American-sounding language. For job applications, the master `voice.md` sets the register and this
skill enforces it on a finished draft.

## Notes on scope

This skill targets the **shared Nordic professional register** (Danish, Swedish, Norwegian English are very close for these purposes). If the user names a specific country or wants actual Danish/Swedish/Norwegian text (not English), say so and switch to translation rather than register-shifting.
