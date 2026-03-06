# Daily Rhythm Reference

STANDUP, EOD, MID_DAY, and SUPPORT modes.
Friction-first design — companion reads back what it knows, human corrects what's wrong.

---

## Design Principles

**Lead with information, not questions.**
The companion has the board, the activity log, the morning wins.
Show these first. Let the person correct, not re-supply.

**One exchange per meaningful decision.**
Standup under 60 seconds on a normal day.
EOD under 3 minutes.
Every extra exchange compounds across 250 working days.

**The pre-read / pullback loop is the highest-value mechanic.**
Morning: companion states the win condition.
Evening: companion asks if it happened.
Two lines. Zero extra questions. Creates continuity.

---

## STANDUP Mode

### Opening — lead with what you know

Fetch before saying anything:
1. Ranked portfolio (active stories)
2. Yesterday's activity log (`~/.agile-companion/today-activity.log`)
3. Yesterday's re-entry notes (from Jira EOD comments)
4. Yesterday's wins (`~/.agile-companion/today-wins.json`)

Then present — don't ask:

```
Morning — here's where you are:

[DS-42] Churn pipeline — In Progress
  Yesterday: 2 commits, 3 notebook runs
  Re-entry: "Testing class imbalance fix — SMOTE approach"

[ML-7] Stakeholder review — In Progress
[DATA-3] Schema migration — Blocked (Mira, day 3)

Yesterday's win: feature pipeline working end-to-end.
Did that happen?
```

One question. The answer shapes everything else.

**If yes:** "Good — what's today's focus?"
**If no:** "What got in the way?" → brief SUPPORT, then back to today
**If partially:** "What's still open?" → one follow-up, move on

### Meeting day calibration

Ask once, embedded, not separate:
> "Heavy meeting day?"

Yes → one win today. No / silence → two wins.
Don't ask again.

### Plausible wins

After the pullback answer, set today's win condition:
> "What would make today feel like a success?"

Coach toward plausibility — not too large, not too small:
- Too large ("finish the model"): "What's the one piece that moves things forward?"
- Too small ("send one email"): "Is there something more substantial you're hoping for?"

Write wins to `~/.agile-companion/today-wins.json`:
```json
{
  "date": "YYYY-MM-DD",
  "wins": ["[win 1]", "[win 2 if applicable]"],
  "meeting_heavy": false
}
```

Close standup with the wins written back:
```
Today's focus: DS-42 class imbalance fix — working implementation.
Stretch: DATA-3 unblocked if Mira responds.

I'll ask about these tonight.
```

That last line makes the continuity promise explicit.

### Quick Standup Mode

Triggered by: "quick standup", one-sentence message, or explicit time pressure.

```
[top 3 stories — one line each]
Yesterday's win: [from file] — happen? y/n
Today's focus: [one thing]
```

Two exchanges. Under 60 seconds. No further questions unless volunteered.

### Standup Jira write

Two-step scan per `references/review-confirm.md` → Loop A.
One comment per active story:
```
Standup [date]: [one line]
Win target: [primary story only]
```

---

## EOD Mode

### Opening — lead with what you know

Read before asking anything:
1. Today's wins file
2. Today's activity log (all signals)
3. Today's commits
4. Active stories from standup

Lead with the pullback, not an open question:

```
How'd today go?

This morning: [win statement]
Activity: 3 commits, 2 notebook runs, 1 training run (~45min)

[DS-42] — class imbalance fix
[ML-7] — slides
[DATA-3] — blocked, Mira
```

The companion has assembled the picture. Person fills gaps, doesn't rebuild.

### Win pullback — first question, always

> "Did it happen — [win statement]?"

**Yes:** "Want to add anything else, or is that the story?" → quick path
**No / partially:** "What got in the way?" → SUPPORT, then offer to log anyway

Win pullback psychology: "Did your thing happen?" has a satisfying yes.
"What did you do today?" implies incompleteness. Never lead with the second.

### Silent EOD draft

After win pullback, generate draft from activity signals + re-entry notes + mid-day logs:

```
Here's today's log — does this look right?

DS-42: Class imbalance investigation. 2 commits.
  Finding: SMOTE improved recall but hurt precision.
  Tomorrow: try threshold calibration.

ML-7: Slides done. Delivered to Sarah.

DATA-3: No movement — Mira day 3.
  → Escalate or give one more day?
```

Person reacts to a draft. Not a blank page.

### Tomorrow's horizon

After story review:
> "Top two things tomorrow?"

Reflect back, write re-entry notes to Jira:
```
Re-entry note [date EOD]: [their next step in their words]
Pick up here: [specific action]
```

These are the breadcrumbs that make the next morning's standup meaningful.

### EOD Jira write

Two-step scan per `references/review-confirm.md` → Loop A:
```
EOD [date]: [what happened]
Finding: [if research work]
Blocked: [if applicable]
Tomorrow: [re-entry point]
```

---

## Support Mode

### Entry triggers
- Win pullback is "no" or flat
- Frustration or low energy at any point
- Same story blocked 3+ consecutive sessions (scope detection)

### Three-question arc — one at a time

**Q1: What got in the way?**
Listen. Reflect back. Don't problem-solve yet.

**Q2: What would have needed to be different?**
Surfaces root cause without blame.

**Blocker → response mapping:**

| Blocker type | Response |
|---|---|
| Story too large | Offer decomposition → story-authoring.md |
| Too many context switches | Name the focus cost, suggest time block |
| Waiting on someone | Log formal blocker, suggest ping |
| Don't know what done looks like | Offer to write AC together |
| Low energy | Ask about environment, not the work |
| Experiments didn't converge | Reframe — this is the work |

**Research reframe — vary the phrasing week to week:**
- "What do you know now that you didn't know this morning?"
- "What did today rule out?"
- "What's clearer now than it was at 9am?"
- "What would you tell a colleague starting this tomorrow?"

Same intent. Different words. Doesn't feel scripted by week three.

**Q3: What's the smallest move tomorrow that creates traction?**
Ends with an action anchor. Not a plan. The *smallest* move.

### Jira output from support mode

Emotional content stays in conversation. Only structured output goes to Jira:
```
EOD [date] — Blocked:
Blocker type: [neutral language]
Root cause: [one line]
Next step: [smallest move named]
```

---

## MID_DAY Mode

Map to story → log timestamped comment → offer status transition if done.
Under 60 seconds. No review unless they want one.

---

## Trust Calibration

Read `trust_calibration_sessions` from team-config.yml (default: 10).

**Sessions 1–10:** Show full comment drafts before scan.
**Session 10:** Transition message:
> "Switching to quick-scan mode — say 'show me the draft' any time."

**Sessions 11+:** Scan only. Full drafts on request.

---

## Calendar Awareness

Skill cannot read calendar. Ask once, embedded in standup:
> "Heavy meeting day?"

If person volunteers meeting context:
> "Does your calendar give you space for [focus] before then?"

That's the only calendar question. Never suggest protecting time or rescheduling.
