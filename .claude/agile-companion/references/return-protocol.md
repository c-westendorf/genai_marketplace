# Return Protocol Reference

Handles two distinct return scenarios and the attribution problem.
Read this file whenever gap detection fires (see main SKILL.md → Gap Detection).

---

## Gap Detection

At every session open, before any other mode fires, check:

```javascript
// Find last comment written by this user across all their stories
mcp_call: jira.searchIssues
jql: "assignee = currentUser() AND updated >= -30d ORDER BY updated DESC"
fields: [comment, updated, status, assignee]
// Scan comments for last one authored by currentUser
// Compare timestamp to today
```

**Gap thresholds:**
- < 1 day: no gap, proceed normally
- 1–2 days: weekend gap, no gap protocol needed
- 3–6 days: **short gap** — likely focused sprint or long weekend
- 7–13 days: **medium gap** — likely focused sprint or short PTO
- 14+ days: **long gap** — likely PTO, leave, or extended absence

If gap ≥ 3 days: intercept before any other mode and run **Return Opening**.

---

## Return Opening

Never lead with "you haven't logged in N days." That's accusatory.
Never lead with Jira data. That's disorienting before the person has oriented.

Lead with a single, warm, orienting question:

**Short/medium gap (3–13 days):**
> "Welcome back — looks like it's been about [N] days since we last touched
> base. Were you heads-down on something, or were you out?"

**Long gap (14+ days):**
> "Good to have you back — it's been a couple of weeks. Were you on leave,
> or did things just get intense?"

Wait for their answer. The answer determines everything.

**Then offer the choice explicitly:**
> "Want to do a proper catch-up — review what moved while you were away and
> get your stories current — or would you rather just do a fresh start and
> focus on what's ahead?"

Two paths: **CATCH-UP MODE** or **FRESH START MODE**.

---

## Path A: CATCH-UP MODE

For both focused-sprint and PTO returns, but with different opening energy.

### Opening energy calibration

**If focused sprint:** The person has been working, just not documenting.
They have context. They may feel slightly guilty about the log gap.
> "You were in the work — let's get Jira caught up to where you actually are.
> This shouldn't take long."
Frame it as reconciliation, not confession.

**If PTO / leave:** The person has been genuinely away. They need orientation
before they can do anything. They may feel slightly anxious about what they
missed.
> "Let's see what the world looks like and what needs your attention.
> You were out — things either waited or got handled. Let's find out which."
Frame it as a briefing, not a backlog review.

---

### Step 1: Pull the delta — what changed while they were away

Run the full portfolio fetch, then specifically surface **changes during the gap**:

```javascript
// Stories assigned to user — changes during gap period
jql: "assignee = currentUser() AND updated >= -[N]d ORDER BY updated DESC"
fields: [summary, status, comment, assignee, issuelinks]

// Stories where user is mentioned or watching
jql: "watcher = currentUser() AND updated >= -[N]d"

// Stories that block the user's work — did they resolve?
// (fetch dependency links on user's active stories)
```

**Present the delta in three buckets — not a raw list:**

```
Here's what moved while you were away:

✓ RESOLVED (good news first)
  • [DATA-3] Schema migration — completed by team, merged Thu
  • [DS-42a] Investigation spike — your blocker resolved (Mira delivered pipeline)

⚡ CHANGED (needs your attention)
  • [DS-42b] Implementation — still assigned to you, In Progress, no updates
  • [ML-9] Stakeholder review — due date moved to [new date]

⏸ WAITING ON YOU (someone may be blocked)
  • [PROJ-8] API contract — [teammate] has a "blocked by" link to this
    They've been waiting since [date].
  • [PROJ-11] Feature review — no activity, assigned to you
```

The "waiting on you" bucket is the most important. Name it first emotionally,
even if it's presented third. These are the loops the returning person
must close for their teammates.

**If the returning person was on PTO:** add one line after the delta:
> "None of this is a problem — this is just where things stand. 
> What needs you, and what can wait, is yours to decide."

---

### Step 2: Team impact scan — dependency check

For every story in the "waiting on you" bucket, fetch the full dependency chain:

```javascript
mcp_call: jira.getIssue
issueKey: "[story]"
fields: [issuelinks]
// Find all "blocks" links — who is downstream waiting
```

For each downstream blocker:
> "[Teammate] has [PROJ-X] blocked waiting on [your story]. 
> That's been sitting since [date]. Want to reach out to them 
> before we do anything else?"

Don't proceed with catch-up until the person has acknowledged
the teammate impact. These are the most urgent loops.

---

### Step 3: Retrospective log — per story, not a dump

For each story that was active during the gap, ask one at a time.
Don't present all stories and ask for a global narrative —
that produces vague, useless Jira comments.

**Opening per story:**
> "Let's go through each story. Starting with [story name] —
> what happened with this while you were away?"

**If focused sprint (person was working):**
> "What happened with [story]? Even rough notes — I'll turn it into a proper comment."

**If PTO (person wasn't working):**
> "What's the status of [story] now that you're back — 
> is it where you left it, or did something change?"

**Three sub-questions per story (ask only what's needed):**

1. **What moved?**
   "What actually happened — progress, findings, decisions?"
   
2. **What's the current state?**
   "Where does this stand right now — same status, or should we move it?"
   
3. **What's next?**
   "What's your first move on this when you get back into it?"

**Write to Jira after each story — don't batch:**

For focused sprint return:
```
Retrospective log [date range]:
Work completed during sprint focus:
[what they said]
Current state: [status]
Next step: [their stated next move]
```

For PTO return:
```
Return from leave [date]:
Status on return: [what they described]
Changes during absence: [anything that moved per delta scan]
Next step: [first move]
```

---

### Step 4: Sprint context reconciliation

If they've been away long enough that the sprint may have turned over:

```javascript
// Check if sprint changed during absence
mcp_call: jira.getSprint
boardId: "[boardId]"
state: "active"
// Compare sprint start date to gap start date
```

**If sprint changed:**
> "You left in Sprint [N] and you're back in Sprint [N+1]. 
> The sprint goal changed — it's now: '[goal]'.
> [X] of your stories carried over. [Y] were deprioritized.
> Want to see what the new sprint looks like before we do the story review?"

Always show the sprint change before asking about individual stories.
A person reconciling stories against the wrong sprint goal is wasted effort.

---

### Step 5: Reorientation close

After retrospective log is complete:

> "Okay — you're caught up. Here's where you actually stand:
>
> Stories updated: [N]
> Teammate loops to close: [list names if any]
> Your focus for today: [top 1–2 stories by priority]
>
> Want to do a proper standup from here, or just get started?"

Give them agency over what comes next.

---

## Path B: FRESH START MODE

For when the person doesn't want to backfill — they want to move forward.

Respect this without friction. Don't suggest they "should" catch up.

> "Fresh start it is. Let me pull your current board and we'll focus on what's ahead."

**But do one thing before dropping it:**

Check for "waiting on you" dependency blockers. If any exist:
> "One thing before we move forward — [teammate] has [story] blocked
> waiting on you. Want to send them a quick note now, or handle it
> when you get to that story?"

This is non-negotiable. A fresh start for the returning person
shouldn't mean their teammates stay blocked. Surface it once,
then honor whatever the person decides.

After that: run STANDUP mode as normal.
Don't mention the gap again.

---

## Attribution Engine

Used at standup, EOD, mid-day log, and catch-up — whenever a user narrates
work without explicitly naming a ticket.

### The cardinal rule

**Never auto-attribute. Always ask which project explicitly.**

This is non-negotiable because:
- Wrong attribution is worse than no attribution (it actively misleads the team)
- The ask takes five seconds and builds trust
- Data scientists often work across projects in ways that don't match
  the portfolio ranking

### Attribution confidence levels

Even though we always ask, the *quality* of the question scales with confidence:

**High confidence** (one story clearly matches, keywords align):
> "That sounds like [DS-42] — the churn model pipeline work. Is that right?"
Single yes/no confirmation. Move on.

**Medium confidence** (two stories could match):
> "Was that [DS-42] the feature pipeline, or [DS-44] the model evaluation?
> They both touch that area."
Present the two options. Let them pick.

**Low confidence** (no clear match, or cross-project):
> "Which story does that belong to? I want to make sure it goes
> to the right place."
Open question. Don't guess.

**No match** (narrated work has no Jira ticket at all):
> "I don't see a story for that — was this unplanned work, or
> is there a ticket I'm not seeing?"
Two paths: create a new story, or log as unplanned (with `unplanned` label).

### Attribution in catch-up mode

During retrospective log, attribution is especially important because
the person is narrating past work from memory. Time pressure and fatigue
can make them imprecise.

After each story review:
> "I'm going to write that to [story key] — [story name]. Right project?"

Always confirm the destination before writing. The person just spent
time giving you their account of the work — writing it to the wrong
place erases that effort.

### Cross-project narration

When one narrated item spans multiple stories or projects:
> "It sounds like that touched both [PROJ-A] and [PROJ-B].
> Want to split the comment — one note to each — or does it
> belong more to one than the other?"

Never split without asking. Never collapse without asking.

### The attribution memory (within session)

Once a user confirms an attribution ("yes, that's DS-42"):
- Remember it for the rest of the session
- Use it to raise confidence on subsequent similar narrations:
  "Still working on DS-42?"
- Don't re-confirm the same mapping twice in a row

Carry attribution context forward aggressively within a session.
Ask fresh at the start of each new session.

---

## The "Wheels Responsibility" Persona

This is the specific person this protocol is designed for:
someone who owns things even when they're not present.

Their particular needs on return:

**They need to close loops, not just catch up personally.**
The catch-up is incomplete until every blocked teammate has been acknowledged.
The companion should make this feel like closing a circle, not doing paperwork.

**They need to know what was handled without them.**
Someone may have made a decision on their story, merged something,
or worked around their absence. They need to know — not to feel territorial,
but because they're responsible for the integrity of the work.

**They need language for what happened.**
"I was in a focused sprint" and "I was on PTO" are both legitimate.
Neither requires apology. The companion should help them write
the narrative that contextualizes the gap for their team —
not as an excuse, but as professional transparency.

**Gap narrative template (for Jira sprint comment):**

Focused sprint:
```
Sprint focus note [date range]:
During this period, primary effort was concentrated on [story/feature].
Below is a retrospective log of activity across all stories.
Resuming full portfolio coverage from [today].
```

PTO / leave:
```
Return from leave [date range]:
Returning from [PTO / leave]. Stories reviewed and updated below.
Teammate dependencies addressed. Resuming active sprint from [today].
```

These comments go on the sprint itself, not individual stories —
they provide context for the whole team reading the sprint history.
