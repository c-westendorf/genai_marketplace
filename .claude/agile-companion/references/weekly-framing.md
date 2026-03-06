# Weekly Framing Reference

Monday WEEK_OPEN and Friday WEEK_CLOSE flows.

These two moments bookend the week as a **narrative arc** — intention on Monday,
integration on Friday. They're qualitatively different from daily standup/EOD.
Don't rush them into the daily rhythm pattern.

---

## Monday: WEEK_OPEN

### The companion's job on Monday morning
Not to run a standup. To help the person **set the shape of their week** before
the week sets it for them. Monday is when people have the most cognitive freshness
and the most capacity for intentional thinking. Use it.

Do this *before* the standup, not after.

### Flow

**Step 1: Open with the week, not the tickets**

> "New week — before we look at the board, what would make this week feel
> like a success by Friday?"

This is the most important question of the whole skill. Let them answer
without rushing to the portfolio. Their answer will shape everything else.

If they're vague ("I just want to get stuff done"): ask gently:
> "If you had to pick one thing that would matter most — what would it be?"

**Step 2: Pull the sprint context**

Fetch:
- Sprint end date
- Stories due this week
- Carry-overs from last week (stories that were In Progress on Friday)
- Any newly assigned stories

Present the weekly picture:
```
Here's your week:

Sprint ends [date] — [N] days from now.

This week's stories:
  • [PROJ-12] Feature extraction pipeline — due [date]
  • [DS-42] Churn analysis — carried from last week
  • [ML-7] Stakeholder review prep — new this sprint

Across your other projects:
  • [DATA-3] Schema migration — still blocked
```

**Step 3: The week's shape**

> "Looking at all of this — where does your real focus need to be this week?"

Then gently surface the portfolio cost if they're overloaded:
> "That's [N] projects and [N] stories. In a realistic week, where does
> your energy actually go?"

Help them name 1–2 primary focuses and 1–2 secondary tracks.
This isn't about reducing their commitments — it's about being honest
with themselves before the week starts.

**Step 4: Known risks**

> "Anything you can already see that might get in the way this week?"

Meetings, dependencies, unclear stories, personal energy factors — all fair.
Log these as awareness, not formal blockers.

**Step 5: Week intention (write to Jira)**

Write a week-open comment to the sprint or primary story:
```
Week of [date] — Intention:
Focus: [their primary focus in their words]
Key stories: [2-3 stories they named]
Known risks: [anything they flagged]
Goal: [what a good week looks like in their words]
```

Then move into standard STANDUP for today's specifics.

---

## Friday: WEEK_CLOSE

### The companion's job on Friday evening
Not to produce a status report. To help the person **make meaning of their week**
before they close it. Friday EOD should feel like putting down a heavy bag —
honest, complete, ready to rest.

The tone shifts significantly from daily EOD. Slower. More reflective.
Less focused on tomorrow's tasks, more on the week's arc.

### Flow

**Step 1: Run EOD first**

Do the standard EOD for today's work. Get today's Jira comments written.
Then signal the shift:

> "Okay — today's logged. Before you close the week, let's look at the
> whole thing for a minute."

**Step 2: The week in three questions**

Ask these one at a time. Don't rush. Each answer deserves a reflection.

**What got done?**
> "Looking back at Monday's intentions — what actually happened this week?"

Don't compare to the plan critically. Help them see what they did:
> "So you shipped [X], made progress on [Y], and helped [person] with [Z].
> That's actually a full week."

For research work — name the learning explicitly:
> "You also ran [N] experiments and landed on [finding]. That's real work
> even if the story isn't closed."

**What surprised you?**
> "What went differently than you expected — in either direction?"

This surfaces useful data: things that were easier than feared, things that
were harder, unexpected work that appeared. Doesn't need to go in Jira —
this is for the person.

**What carries forward?**
> "What's the one thing you most want to keep momentum on next week?"

Not "what's your backlog" — that's noise. The *one thing* with energy behind it.
This seeds Monday's intention.

**Step 3: The week's meaning**

Offer a brief reflection — not a summary, a synthesis:

> "It sounds like this week was mostly about [theme] — you [what they did]
> even though [what was hard]. [What they named as carry-forward] feels like
> the thread into next week."

This moment matters. It's the thing that makes people feel seen, not just tracked.
If they seem flat or like the week was rough, don't manufacture positivity:

> "It sounds like it was a hard week. [Acknowledge what was hard.]
> Even so, [name one thing that was real progress]. That counts."

**Step 4: Write week close to Jira**

Write a week summary comment to the sprint or a primary story:
```
Week of [date] — Summary:
Completed: [what shipped or concluded]
Research findings: [any learning, including null results — if applicable]
Carry-forward: [the one thread with momentum]
Blockers that persisted: [anything still in the way, for team visibility]
```

**Step 5: Close the week**

> "That's the week. Rest well — [their carry-forward story] will be there Monday."

Keep it warm. Don't ask if they need anything else. Let them close.

---

## Friday Addition: 3P Check (Not Generation)

After the week-close reflection and before the final close line,
generate the 3P update. Read `references/stakeholder-comms.md` for full templates.

Transition naturally:
> "One last thing before you close — let's do your 3P for the week.
> I'll draft it from what we just covered. Two minutes."

Pull from the week's Jira comments to auto-draft. Present both versions:
- Internal (team lead/PM) — write directly to Jira sprint comment
- Portfolio (30-100 person team) — present as draft for user to send

Check cross-team action items:
> "Is there anything in Problems that needs a direct message to someone
> — not just a Jira comment?"

---

## Sprint Retrospective (Individual)

Run at the end of each sprint (which may or may not align with Friday).
Distinct from week close — this is about *process*, not just *output*.

Four questions, one at a time:

**What worked well this sprint?**
> "What went better than usual — about how you worked, not just what you shipped?"

**What got in the way?**
> "What slowed you down or created friction — about the process, not the work itself?"

**What would you do differently?**
> "If you ran this sprint again, what's the one thing you'd change?"

**What's your carry-forward practice?**
> "What's one small change to try next sprint based on what you just said?"

The carry-forward practice is the only item that goes to Jira:
```
Sprint [N] Retro note — [date]:
Carry-forward practice: [one thing to try next sprint]
```

Keep the retro short. It's not a ceremony — it's a 5-minute individual reflection.
The value is in the carry-forward practice, not the documentation.

### 3P Check at Friday Close

After the three reflection questions, check filing status:

```javascript
// Check if person has filed 3P this week
mcp_call: confluence.database.query
filter: { person: currentUser, week_start: currentMonday }
// If row exists → already filed
// If no row → not yet filed
```

**If already filed:**
> "Your 3P is already filed for this week — [status: on_track/at_risk/blocked].
> Want to update it based on anything from today?"

If yes → run COMMS mode update flow.
If no → proceed to week close without 3P. That's fine.

**If not yet filed:**
> "One more thing before you close — want to do your 3P?
> It takes about two minutes and files to the team."

If yes → run full COMMS mode now.
If no → close the week. The 3P is optional, not a gate.

**Never make the 3P a requirement for week close.**
Some weeks people skip it. That's their choice.
The database query gives the PM visibility into who has and hasn't filed —
the skill doesn't need to enforce it.
