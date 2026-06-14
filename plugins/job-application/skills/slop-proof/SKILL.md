---
name: slop-proof
description: "Detect and remove AI-slop writing tells from copy: memos, READMEs, landing pages, blog posts, emails, social posts, docs. Two modes: audit (report every tell with line references and severity) and rewrite (fix flagged text while preserving the author's voice and claims). Use whenever the user says /slop-proof, 'deslop this', 'check for AI slop', 'does this sound like AI', 'humanize this copy', 'make this sound human', 'slop check', or asks to review the tone or voice of a draft before publishing. Also use proactively as a final pass on any user-facing copy you wrote yourself: if you drafted it, slop-proof it. NOT for setting Nordic/Scandinavian register (use /nordic-style), and not for fact-checking or translation."
---

# Slop-Proof

Audit and rewrite copy to remove the tells that make readers think "an AI wrote this." Based on a simple observation: the reader can spot slop instantly, so the writer needs a checklist that catches it first.

## Core Principle

The author's own words, bullets, and claims are the source of truth. Slop happens when AI replaces thinking with pattern-matched language. The fix is never to generate new ideas. It is to strip the filler, restore the concrete, and keep the voice. A rough human sentence beats a polished empty one. The rough bullets a writer hands to an AI are usually worth more than the polished draft it hands back.

Concrete beats abstract, always. "Customers are doing X, so we need to change Y" beats "This signals a shift in customer behavior and underscores the need for a revised approach."

## Modes

**Audit** (default when asked to check, review, or score): scan the text, report every tell with location, severity, and a suggested fix. Do not modify the text.

**Rewrite** (when asked to fix, deslop, humanize, or clean): apply the fixes while preserving the author's voice, claims, facts, and structure. Show what changed and why.

If the request is ambiguous, audit first, then offer the rewrite.

## The Slop Catalog

### Tier 1: Banned phrases (severity: Critical)

Instant tells. Nobody says these in real life. Flag every occurrence:

| Phrase | Human replacement |
|--------|------------------|
| "delve into" / "let's delve" | "look at", "dig into", "break down" |
| "unpack" (ideas, not luggage/files) | "break down", "walk through" |
| "this signals that" | state the fact and the consequence: "X happened, so Y" |
| "this underscores" / "quietly underscores" | "this shows", or cut it and say the point |
| "navigate the complexities of" | name the actual complexity or cut |
| "in an ever-changing landscape" / "in today's fast-paced world" | cut entirely; it says nothing |
| "synergies" / "unlock synergies" | say which two things combine and what that produces |
| "leverage our learnings" | "use what we learned" |
| "holistic approach" | say what is actually included |
| "game-changer" / "paradigm shift" | state the specific change and its size |
| "seamless" / "seamlessly" | describe what the user does NOT have to do |
| "elevate" / "empower" / "supercharge" (marketing filler) | state the concrete benefit |

### Tier 2: Structural tells (severity: Warning)

Patterns, not phrases. These need reading, not grepping:

1. **Transition-word paragraph openers.** Paragraphs starting with "Moreover," "Furthermore," "Additionally," "That said," "Importantly," "Ultimately." Test: read it out loud. If you would not say it, cut it. Usually the paragraph works with the opener deleted.
2. **Bold-word-colon-explanation bullets.** "**Clarity:** Ensure your memo is clear and concise." A list of these is a template, not thinking. Rewrite as plain statements or merge into prose.
3. **Corporate therapist voice.** "This is a powerful opportunity to lean into our strengths and foster a culture of accountability." Sounds warm, commits to nothing. Replace with who does what by when.
4. **The neat bow ending.** A conclusion that could close any document at any company: "Ultimately, the goal is to build a more resilient and agile organization." If the conclusion applies to any company on earth, it is wasted words. End on the specific decision, ask, or next step instead.
5. **Says-everything-means-nothing paragraphs.** It reads smart but cannot be summarized. Test: ask "what would I tell a colleague this paragraph says?" If the answer is fog, rewrite from the underlying fact or cut.
6. **Forced negation.** "It's not just X, it's Y." "Not a product update, but a transformation." One instance is fine in a strong spot; a pattern of them is slop.
7. **Staccato repetition.** "Not faster. Not cheaper. Better." Three-beat fragment rhythm used more than once per piece.
8. **Excessive adverbs.** "quietly underscores", "fundamentally transforms", "deeply resonates". The adverb is doing fake work; the verb should do real work.
9. **Rule-of-three overuse.** Every list and sentence grouping things in threes. One or two triads read fine; wall-to-wall triads read generated.

### Tier 3: House style (severity: Style)

The user's standing house-style preferences, applied to all copy:

1. **No em dashes (—) or en dashes (–).** Rewrite with commas, periods, colons, or parentheses. Use double hyphens (--) only where a dash is unavoidable. Number ranges use plain hyphens: 44-65%, not 44–65%.
2. **No "Let's dive in" / "Let's get started" openers.**
3. **No emoji-decorated headers** unless the user's existing copy already uses them.

## What NOT to Flag

False positives destroy trust in the audit. Skip:

- **Quoted material and citations.** If the author quotes someone saying "delve", the quote stays.
- **Code blocks, commands, file paths, identifiers.** `--flag` is not a dash violation; `unpack()` is a function.
- **Technical senses of catalog words.** "Unpack a tarball", "the handler receives a signal", "navigate to the settings page" are literal usage, not slop.
- **Proper nouns and product names.**
- **A single instance of a Tier 2 pattern in an otherwise human text.** Patterns are about density. One "However," opener in a 1,000-word memo is a human writing; five is a template.

## Audit Report Format

```markdown
# Slop Audit: [document name]

**Verdict:** [Clean / Light slop / Heavy slop]
**Slop density:** [N] tells in [W] words ([N per 500 words])

## Findings

| # | Line | Tell | Tier | Severity | Suggested fix |
|---|------|------|------|----------|---------------|
| 1 | 12 | "delve into" | Banned phrase | Critical | "dig into" |

## Patterns (Tier 2)

[For each structural tell: name it, quote the worst instance, explain the fix in one sentence]

## What reads human

[1-3 things the author did right; rewrites must preserve these]
```

Verdict thresholds: Clean = 0 Critical and at most 1 Warning per 500 words. Heavy slop = 3+ Critical or pervasive Tier 2 patterns. Everything between is Light slop.

## Rewrite Rules

1. **Fix only what the audit flagged.** Do not restyle sentences that were already human.
2. **Preserve every fact, number, name, and claim.** If the original says "124 pull requests" the rewrite says "124 pull requests". Never add claims the author did not make.
3. **Preserve voice.** Casual stays casual, typos-and-all bluntness stays blunt, technical stays technical. The goal is the author minus the slop, not Claude's house style.
4. **Shorter is the default direction.** Most slop fixes are deletions. If the rewrite is longer than the original, something went wrong.
5. **When a sentence says nothing, ask what the author meant** instead of inventing a meaning. If the underlying point is genuinely unrecoverable, flag it: "this sentence has no recoverable claim; what did you want to say here?"
6. **Show your work.** After the rewrite, list the changes in a short table: original phrase, replacement, which catalog rule applied.

## Rewrite Example

Input:
> Moreover, this quarter's results underscore the need to leverage our learnings and take a more holistic approach — navigating the complexities of an ever-changing landscape requires synergies across teams.

Output:
> Q3 came in 12% under target. The checkout redesign worked (conversion up 8%), the ad spend reallocation did not. Next quarter, growth and product plan spend together instead of separately.

(Note: the output requires asking the author for the real numbers and decisions. That is the point. If the source material lacks them, ask. Never invent specifics.)

## The Positive Workflow (advise when relevant)

When a user asks how to avoid slop in the first place, or pastes a topic and asks for a memo from scratch, give them this workflow instead of generating slop:

1. Talk through the idea in your own words first (voice dictation works). That raw material already sounds human.
2. Use AI as an editor, not a ghostwriter. Good asks: "What's missing?", "Where is my language unclear?", "Tighten this without changing my voice", "Does my argument flow logically?"
3. Never paste a topic and ask for the full memo. The bullets you would have sent are worth more than the slop that comes back.
