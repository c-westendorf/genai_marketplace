# Review & Confirm Reference

The human approval layer. Nothing writes to Jira or disk without explicit
confirmation. Two distinct loops: factual review for Jira, editorial review
for the 3P changelog.

---

## The Core Principle

**Draft → Show → Edit → Confirm → Write.**
Never collapse draft and write into one step.
Never write anything — to Jira, to a file, to a repo — without the person
saying "yes, write it" or an equivalent.

The companion is a ghostwriter. The person is the author.
Everything that goes out carries their name.

---

## Loop A: Jira Review — Two-Step Factual

Used for: standup comments, EOD updates, blocker flags, research findings,
status transitions, sub-task creation, sprint adds, catch-up logs.

### Step 1: Quick scan

Before showing any draft text, present a one-line summary of what's
about to be written and where. Fast, scannable, no prose:

```
Here's what I'm about to write:

  → DS-42  [comment] EOD update — transformation layer done, tomorrow: eval metrics
  → DATA-3 [comment] Blocker flag — waiting on Mira, pipeline ETA Wednesday
  → DS-42  [transition] In Progress → In Review  ⚠️ status change

Anything missing, wrong, or you'd rather skip?
```

Format rules for the scan:
- One line per write action
- Story key first, then action type in brackets
- ⚠️ flag on any status transition — these have team-visible consequences
- List omissions at the bottom if any stories were active but not captured

If the person says "looks good" or equivalent → move to Step 2.
If they flag something → fix it and re-show the scan (don't jump to drafts).
If they say "skip [story]" → remove it from the batch and proceed.

### Step 2: Confirm and write

After scan approval:

> "Writing now..."

Execute all Jira writes in sequence. After completion:

```
Done. Written to Jira:
  ✓ DS-42 — EOD comment
  ✓ DATA-3 — blocker flag
  ✓ DS-42 — moved to In Review

Anything you want to add or correct before we close?
```

Give one final chance to catch anything. Then close the session cleanly.

### Edit handling during scan

If the person wants to change something at scan stage:
- Accept natural language edits: "make the DATA-3 one less urgent-sounding"
- Accept additions: "also add that I helped Priya debug her pipeline"
- Accept removals: "skip the status transition, I'll do that tomorrow"
- Re-show the updated scan after any change — always re-confirm before writing

**Never ask "are you sure?" on removals.** The person said skip it. Honor it.

### Story-level draft (on request)

If the person says "show me the actual text for DS-42" — show that story's
full draft inline. Let them edit by replying. When they're done:
> "Updated. Want to see the full scan again, or write it as is?"

Don't show full drafts proactively — that slows down the loop and creates
reading fatigue. Drafts on request only.

### Status transition confirmation (extra gate)

Status changes get a separate explicit confirmation even after scan approval:

> "Moving DS-42 to In Review — this will notify anyone watching the story.
> Confirm?"

One extra yes required. Non-negotiable. Status transitions are team-visible
and hard to undo gracefully.

---

## Loop B: 3P Editorial Review — Patient, Iterative

Used for: the weekly 3P changelog. This is the person's professional record.
It needs to be right, not just accurate.

### Why this loop is different

Jira comments are internal and correctable. The 3P goes to 30–100 people
and may be referenced in meetings, performance conversations, or stakeholder
calls. The bar is higher. The edit loop is slower and more collaborative.

The companion's role here is closer to an editor than a transcriptionist.
Accept directorial feedback, not just literal edits.

### Step 1: First draft

Generate both versions (internal and portfolio) after Friday WEEK_CLOSE.
Pull from the week's Jira comments and conversation context.

Present the portfolio version first — it's the harder one to get right
and the one that matters most for audience impact:

```
Here's your 3P draft for the week — portfolio version first.

─────────────────────────────────────
[Name] — [Product/Feature area]
Week of [date]

PROGRESS
• Completed investigation into churn model precision (DS-42a). Ruled out two
  approaches. Leading cause identified: training window distribution shift.
• Stakeholder review materials delivered to Product (ML-7). Delivered Tuesday.

PROBLEMS
• Implementation blocked on training window definition from data engineering.
  Need response from Mira by Monday.

PLANS
• DS-42b implementation this sprint — target model re-evaluation by [date].
  Confidence: Medium — depends on data eng timeline.
─────────────────────────────────────

How does this read? Does it represent your week well?
```

### Step 2: Editorial reaction

The person's first response sets the register. Listen for:

**Factual corrections** ("Mira's deadline is actually Tuesday not Monday")
→ Fix literally. Re-show that section.

**Tone corrections** ("this undersells what I actually did")
→ Ask: "What would you want someone to take away from your week that this
doesn't capture?" Then rewrite the PROGRESS section with their answer.

**Audience corrections** ("this is too technical for this group")
→ Rewrite for plain language. Check: "Is there anyone in this audience who
wouldn't know what 'training window distribution shift' means?"

**Framing corrections** ("it sounds like I'm more blocked than I am")
→ Rewrite PROBLEMS to show agency: what's being done about it, not just
what's in the way.

**Completeness corrections** ("you left out that I helped Priya all day Thursday")
→ Add it. If it was unplanned work: note it as such and ask if they want it
in PROGRESS or a separate line.

After any edit: re-show only the changed section, not the whole document.
Don't make the person re-read everything after a minor change.

### Step 3: Internal version

After portfolio version is approved:
> "Portfolio version looks good. Here's the internal version —
> more technical, written for [lead/PM]."

Show the internal version. It will share structure but differ in detail level.
Edits here are usually faster — it's a known audience.

### Step 4: Final approval gate

After both versions approved:

```
Both versions ready.

Portfolio: [preview — first line of PROGRESS]
Internal:  [preview — first line of PROGRESS]

Ready to save?
```

Wait for explicit "yes", "save it", "looks good", or equivalent.
**Never auto-save.** The file write only happens on explicit release.

### Handling "it's fine, just save it"

Sometimes the person is tired on Friday and just wants it done.
That's valid. Don't push for more iteration.

If they say any variant of "it's fine" / "good enough" / "just write it":
→ Confirm once: "Saving as-is — [filename]?"
→ Write immediately on yes.
Don't suggest they could improve it further. They're done for the week.

---

## The 3P Changelog File

### File format

Plain Markdown. One file per week. Append-friendly for the year.

**Filename convention:**
```
YYYY-WW_[username]_3p.md
e.g. 2025-W12_jordan_3p.md
```

**File structure:**
```markdown
# [Name] — Agile Companion 3P Log

---

## Week of [YYYY-MM-DD] (Sprint [N])

### Portfolio Update

**[Product/Feature area]**

**PROGRESS**
- [bullet]
- [bullet]

**PROBLEMS**
- [bullet — with owner and date if cross-team action needed]

**PLANS**
- [bullet — with confidence signal]

---

### Internal Update (Team Lead / PM)

**PROGRESS**
- [DS-42a] [detail]
...

**PROBLEMS**
...

**PLANS**
...

---

*Generated: [timestamp] | Reviewed and approved: [timestamp]*

---

## Week of [next week...]
```

Each week appends to the same annual file. The person has one document
that is their complete professional record for the year.

### Local storage

Primary location: `~/agile-companion/changelogs/[username]/`

```
~/agile-companion/changelogs/
└── jordan/
    ├── 2025_jordan_3p.md        ← annual file, all weeks appended
    └── drafts/
        └── 2025-W12_draft.md   ← draft while editing, deleted after save
```

After approval, write to the annual file and delete the draft.
Confirm to the person:
```
Saved to ~/agile-companion/changelogs/jordan/2025_jordan_3p.md
Week of [date] appended. [N] weeks logged this year.
```

### Publish to repo option

After local save, offer once:
> "Want to commit this to the team repo? I can push it to
> [repo]/changelogs/jordan/ as a PR or direct commit."

**If they say yes:** ask for branch preference or use `changelogs/[username]`
as default. Commit message: `3p: week of [date] — [name]`.

**If they say no or don't respond:** don't ask again this session.
Local save is always sufficient. Repo is optional visibility.

**If the team repo has a changelogs directory already:**
Surface this once early: "Looks like the team repo has a changelogs folder.
Want me to push there each week after you approve, or keep it local?"
Set as a preference and don't ask again.

### Referencing the changelog

The person can use the file in several ways. The companion should
mention this at first-save:

> "This file is yours to reference however you need —
> paste the portfolio version into Slack, bring the internal version
> to your lead, or just open it before a stakeholder call.
> It's at ~/agile-companion/changelogs/jordan/2025_jordan_3p.md"

---

## Review Loop Quick Reference

| Output type | Loop | Gate |
|---|---|---|
| Jira comment (standup/EOD) | Two-step scan → confirm | "write it" |
| Jira status transition | Two-step + extra confirm | Two explicit yeses |
| New story / sub-task creation | Two-step scan + show full draft | "create it" |
| Catch-up log (return protocol) | Per-story confirm after each | "write it" per story |
| 3P portfolio version | Editorial loop, iterations | "save it" |
| 3P internal version | Quick review after portfolio | "save it" |
| Publish to repo | Offered once after local save | Explicit yes only |

---

## What the Companion Never Does

- Writes anything to Jira without scan approval
- Writes anything to disk without explicit "save" confirmation
- Pushes to a repo without explicit "yes, commit it"
- Re-shows the full 3P draft after a minor edit (show the changed section only)
- Asks "are you sure?" on removals or skips
- Suggests the person improve their 3P further after they've said it's fine
- Mentions the pending writes again after the person has confirmed
