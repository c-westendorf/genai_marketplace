# Stakeholder Communications Reference

Communication patterns for a portfolio-scale data team (30–100 people, many data products).
The 3P is a **personal changelog** — not a Jira artifact. It lives in a file the
individual owns, versions, and references in meetings or async comms.

Read `references/review-confirm.md` → Loop B for the full editorial review process.
Nothing in this file saves or sends without explicit person approval.

---

## The 3P Framework

**Progress · Problems · Plans**

Three sections, strict discipline. No section longer than it needs to be.
The reader should understand the full picture in 90 seconds.

```
PROGRESS   What moved this sprint/week — shipped, learned, closed
PROBLEMS   What's in the way — blockers, risks, decisions needed
PLANS      What's next — this week or next sprint, with confidence signal
```

**Two versions always generated.** Neither version goes anywhere without
the person approving it through the editorial review loop.

- **Portfolio version** — plain language, product-first, 30–100 person audience,
  ~80–150 words. This is the person's public-facing record.
- **Internal version** — technical language acceptable, team lead / PM context,
  ~150–300 words. Shared directly with a known audience.

Both versions save to the person's local changelog file.
The portfolio version may optionally be committed to the team repo.
Neither version writes to Jira.

---

## Audience Profile: Portfolio Team (30–100 people)

This audience:
- Has many data products in flight simultaneously
- Doesn't know the details of your specific work
- Needs to understand *impact and status*, not technical implementation
- Will skim — leads and bullets, not paragraphs
- Cares about: does this affect my work? Is something at risk? Do I need to act?

**What to avoid:**
- Technical jargon without a plain-language translation
- "We made progress on X" without saying progress toward what
- Long explanations of why something didn't happen
- Internal team dynamics or individual performance signals

**What the portfolio audience needs:**
- What product or capability this work serves
- Whether it's on track, at risk, or blocked
- Whether any cross-team action is needed
- What's coming and when

---

## Portfolio Version Template

Target: 80–150 words. Product-first framing. No story keys unless universal.

```
[Name] — [Product/Feature area]

PROGRESS
[2-3 bullets — what shipped or was learned, in terms of the product it serves]

PROBLEMS
[1-2 bullets — risks or blockers that may affect others, or need a decision]
[If nothing cross-team: omit this section entirely]

PLANS
[2-3 bullets — what's next and roughly when, with confidence signal]
```

**Example:**
```
Jordan — Churn Prediction Model

PROGRESS
• Completed investigation into low model precision — ruled out two approaches,
  identified likely root cause (training window definition). Ready to implement fix.
• Stakeholder review materials delivered to Product (Sarah). Delivered Tuesday.

PROBLEMS
• Need data engineering to confirm the production training window definition
  before implementation can begin. (Flagged to Mira — need response by Monday.)

PLANS
• Implement precision fix this sprint — target: model ready for re-evaluation by [date].
  Confidence: Medium — depends on data eng timeline.
• Schema migration (DATA-3) needs team reprioritization — no progress in 2 sprints.
```

---

## Internal Version Template

Target: 150–300 words. Technical language acceptable. Known audience.

```
3P Update — [Name] — Sprint [N] / Week of [date]

PROGRESS
• [Story key] [Story name]: [what happened — one line per story]
  → [For research work]: Finding: [what was learned, including null results]
• [Completed stories marked ✓]

PROBLEMS
• [Blocker — one line]: [what's needed to unblock]
  → Owner: [who needs to act] | By: [when]
• [If none]: No blockers this sprint.

PLANS
• Next sprint / this week priority: [story name and goal]
• Confidence: [High / Medium / Low] — [one-line reason if Medium or Low]
• Cross-team dependencies coming: [who needs to know]
```

---

## The "Decision Needed" Flag

When a blocker requires a decision by someone with authority — not just more work:

```
PROBLEMS
• [Issue]: This requires a decision, not just work.
  → Decision needed: [what needs to be decided]
  → Options: [brief framing of the choice]
  → Recommend: [if the person has a view]
  → Owner: [who makes this call]
```

Companion prompt:
> "It sounds like [issue] isn't something you can resolve yourself —
> it needs someone to make a call. Who owns that decision, and
> what do they need to know to make it?"

---

## Generating the 3P — Conversation Flow

At Friday WEEK_CLOSE (after EOD journal), transition:

> "Before you close — let's do your 3P for the week. I'll draft both
> versions from what we covered. Two minutes."

Pull from the week's Jira comment history and conversation context.
Draft the portfolio version first — it's the harder one and the most
important for audience impact.

**Present the portfolio version and open the editorial loop:**
> "Here's your 3P — portfolio version first. How does this read?
> Does it represent your week well?"

Run the full editorial review (see `references/review-confirm.md` → Loop B).
After portfolio approved: show internal version for quick review.
After both approved: proceed to file save flow.

**File save confirmation:**
```
Both versions ready. Saving to:
~/agile-companion/changelogs/[username]/[year]_[username]_3p.md

Week of [date] will be appended. [N] weeks logged this year.

Save it?
```

Wait for explicit yes. Then run `scripts/publish-changelog.sh --local`.

**Repo publish offer (once per session, after local save):**
> "Want to commit this to the team repo as well?
> It would go to changelogs/[username]/ as a direct commit or PR."

If yes: run `scripts/publish-changelog.sh --repo [repo_dir]` or
`--repo [repo_dir] --pr` depending on their preference.
If no or no response: don't ask again. Local is sufficient.

---

## When to Generate Each Version

| Trigger | Action |
|---|---|
| Friday WEEK_CLOSE | Draft both versions → editorial review → save to changelog |
| Sprint end (not always Friday) | Same as above |
| Ad-hoc stakeholder request | Draft portfolio version → review → person pastes/sends manually |
| Major blocker mid-sprint | Internal version only → review → person sends directly |

The 3P never writes to Jira. It is always a local file first.
Publishing to repo is always optional, always explicit.

---

## Portfolio Communication Principles

**Lead with product, not process.**
"Churn model is on track" beats "DS-42 is In Progress."

**Risk before detail.**
If something is at risk, say so in the first sentence of PROBLEMS.
Don't bury it after a long PROGRESS paragraph.

**Null results are publishable.**
"We learned X doesn't work" saves other teams from the same path.
Frame it as a finding, not a failure.

**One ask per update.**
Multiple asks in one update get ignored. If cross-team action is needed,
make it one clear ask with a named owner.

**Confidence signals matter.**
"Plans: X" is weaker than "Plans: X — High confidence" or
"Plans: X — Low confidence, depends on Y."
The portfolio audience is planning around this person's work.

---

## Referencing the Changelog

At first save of the year, tell the person once:
> "This file is yours — paste the portfolio version into Slack, bring
> the internal version to a lead conversation, or open it before a
> stakeholder call. It lives at:
> ~/agile-companion/changelogs/[username]/[year]_[username]_3p.md"

The companion can help the person pull a specific week's entry on request:
> "Pull my 3P from two weeks ago" → read the annual file and surface
> the relevant week's entry in conversation.

---

## Availability — COMMS Mode Is Always On

The 3P is not owned by WEEK_CLOSE. It is available any time via COMMS mode.

**When people typically file:**
- Friday any time — most common
- Thursday EOD — 4-day weeks, pre-weekend travel
- Wednesday — presenting to stakeholders Thursday
- Any day — sprint closes mid-week, major story delivered

The skill never says "it's not Friday yet." It never gates the 3P on a
day of week or time of day.

**WEEK_CLOSE behavior:** checks if 3P has been filed this week.
- If yes: "Your 3P is already filed — want to update it before closing?"
- If no: "Want to do your 3P before you close the week?"
- If they say no to both: close the week without 3P. Their choice.

---

## Status Signal and Week Days (Database Fields)

After editorial review, two quick classification questions
before filing to the Confluence database:

**Status:**
> "How would you characterize this week overall for the team view —
> on track, at risk, or blocked on something that needs cross-team attention?"

- **on_track**: progressing as planned, no action needed from others
- **at_risk**: something could slip, team should know
- **blocked**: cross-team action needed, someone must do something

If "blocked" and Problems section doesn't name the owner:
> "Want to add who needs to act before we file?"

**Week days:**
> "How many days did you work this week?"

Accept any answer. Default to 5 if not provided or ambiguous.
For short weeks: adjust the status question:
> "Given your [N]-day week, how would you characterize what you got done —
> on track for the time you had, at risk, or blocked?"

These two fields power the PM's database view. They cost one exchange.

---

## Confluence Database Sync

After status + week days collected, proceed to sync.
Read `references/confluence-sync.md` for full database write flow.

Confirmation gate before any write:
```
Filing to team:
  Person: [name] · Week: [date] · Days: [N]
  Product: [area] · Status: [status]

File it?
```

After filing:
```
✓ Filed — [N] people have filed this week so far.
```

The count creates a soft social signal — team rhythm made visible.
