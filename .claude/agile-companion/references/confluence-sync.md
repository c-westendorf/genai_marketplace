# Confluence Sync Reference

Team 3P artifact architecture using Confluence database.
Read this file when syncing a person's 3P to the team Confluence space.

---

## Architecture Overview

```
SKILL INSTANCE (per person)
    └── generates 3P entry
    └── person approves via editorial review
    └── writes row to Confluence Database
              ↓
CONFLUENCE DATABASE (team-shared, single source of truth)
    └── one row per person per week
    └── typed columns — queryable, filterable
    └── upsert on {person, week} — safe to re-file
              ↓
CONFLUENCE TEAM PAGE (PM-configured view)
    └── reads from database — never hand-edited
    └── filter: current week / current sprint / by status
    └── sort: by status signal, product area, or person
    └── configured once, stays current automatically
```

No concurrent write risk. Each person writes their own row.
Two people filing simultaneously write to different rows — no collision possible.

---

## Database Schema

One row per person per week. All fields required except `problems`.

```
FIELD           TYPE        NOTES
─────────────────────────────────────────────────────────────────
person          text        username — matches team-config.yml
week_start      date        Monday of the week (ISO: YYYY-MM-DD)
sprint          text        sprint name or number
product_area    text        plain language — "Churn Prediction Model"
status          select      on_track | at_risk | blocked
progress        long_text   2-4 bullets — what moved
problems        long_text   1-2 bullets — optional if no cross-team issues
plans           long_text   2-3 bullets with confidence signals
confidence      select      high | medium | low  (overall week confidence)
filed_at        datetime    timestamp of last write
week_days       number      days worked this week (1-5) — normalizes short weeks
```

**The status field** is the PM's primary filter. One classification per week.
**The week_days field** handles 1-4 day weeks gracefully — a 3-day week with
one "at risk" item reads differently than a 5-day week with the same.

---

## Status Signal Elicitation

After the editorial review is complete, ask one classification question:

> "Last thing — how would you characterize this week overall for the team view?
> On track, at risk, or blocked on something that needs cross-team attention?"

**on_track**: Work is progressing as planned. No action needed from others.
**at_risk**: Something could slip. Team should know but no immediate action required.
**blocked**: Cross-team action needed. Someone else must do something for this to move.

If the person says "blocked" — confirm the Problems section names the blocker owner.
If it doesn't: offer to add it before filing.

Also ask:
> "How many days did you work this week?"

Accept any answer. Default to 5 if not provided.
This normalizes the team view — a 3-day week is labeled as such.

---

## MCP Call Patterns

Read `references/atlassian-patterns.md` → Confluence Database section
for the full MCP call implementations.

### Check if row exists for this person/week

```javascript
// Query database for existing entry
mcp_call: confluence.database.query
database_id: "[from team-config.yml → confluence.database_id]"
filter: {
  and: [
    { field: "person", operator: "equals", value: "[username]" },
    { field: "week_start", operator: "equals", value: "[YYYY-MM-DD]" }
  ]
}
```

If row exists → offer to update: "You already filed a 3P for this week.
Want to update it with this version?"
If no row → insert new row.

### Insert new row

```javascript
mcp_call: confluence.database.createRow
database_id: "[database_id]"
fields: {
  person: "[username]",
  week_start: "[Monday of current week]",
  sprint: "[current sprint name]",
  product_area: "[from editorial review]",
  status: "[on_track|at_risk|blocked]",
  progress: "[approved progress text]",
  problems: "[approved problems text or empty]",
  plans: "[approved plans text]",
  confidence: "[high|medium|low]",
  filed_at: "[ISO timestamp]",
  week_days: [number]
}
```

### Update existing row (re-file)

```javascript
mcp_call: confluence.database.updateRow
database_id: "[database_id]"
row_id: "[from query result]"
fields: {
  // only the fields being updated
  status: "[new status]",
  progress: "[updated text]",
  // ... etc
  filed_at: "[new timestamp]"
}
```

Both insert and update are safe to call concurrently across team members —
each person's row is independent.

---

## Team Page View

The team parent page renders a database view — it is never hand-edited.

**Recommended PM view configuration:**

Primary view — current week status board:
```
Filter: week_start = [current Monday]
Sort: status (blocked first, then at_risk, then on_track)
Columns shown: person, product_area, status, progress (first bullet), confidence
Group by: status
```

Secondary view — sprint history:
```
Filter: sprint = [current sprint]
Sort: filed_at descending
Columns shown: all
```

The PM configures these views once in Confluence.
As people file their entries, the view updates automatically.
No manual aggregation, no page editing, no overwrite risk.

**Useful filter combinations:**
- "Show me everyone blocked this week" → status = blocked
- "Show me low-confidence plans" → confidence = low
- "Show me the DS product area" → product_area contains "DS"
- "Who hasn't filed yet?" → absence from current week's rows

That last one — absence detection — is a PM superpower.
By Friday afternoon, the PM can see exactly who hasn't filed
without asking anyone. No Slack messages needed.

---

## Sync Flow (from person's perspective)

After 3P editorial review is approved:

**Step 1: Status elicitation** (one question, ~10 seconds)
Ask status signal + week days. Add to the approved entry.

**Step 2: Check for existing row**
Query the database. If exists: show existing entry, ask if they want to update.
If not exists: proceed to file.

**Step 3: Confirmation gate**
```
Filing to team database:
  Person: Jordan
  Week: [date]
  Product area: Churn Prediction Model
  Status: at_risk
  Days worked: 5

File it?
```

Wait for explicit yes. Never auto-file.

**Step 4: Write row**
Execute insert or update. Confirm:
```
✓ Filed to team — week of [date]
  Status: at_risk
  [N] people have filed this week so far.
```

The "[N] people filed" count is a small but meaningful signal —
it tells the person where they are in the team's weekly rhythm.

**Step 5: Personal page update (optional)**
After database write, offer to update the person's personal Confluence page:
> "Want me to update your personal Confluence page too?
> It's a readable archive of your history."

This is separate from the database — the personal page is the human-readable
version, the database is the structured version. Both have value.

---

## Personal Confluence Page

Each person has their own page under the team parent.
Structure: most recent week at top. Prepend pattern on each update.

```
[Name] — Weekly 3P Log

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Week of [date] · Sprint [N] · [status badge] · [N] days
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROGRESS
• ...

PROBLEMS
• ...

PLANS
• ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Week of [previous date] · ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
...
```

MCP write: read current page content, prepend new week section, write back.
This is one person writing to their own page — no concurrency risk.

---

## First-Time Setup

When a user first runs COMMS mode or WEEK_CLOSE with no database configured:

> "To file your 3P to the team — do you have the team config set up?
> It's a file at .agile-companion/team-config.yml in your team repo."

If yes: read config, proceed.
If no: "Ask your team lead for the config file, or run the setup:
`bash scripts/team-setup.sh` to configure it."

See `scripts/team-setup.sh` for interactive first-time configuration.

---

## Short Week Handling

1-4 day weeks are first-class citizens. The skill never implies a short week
is incomplete work. Language adjustments:

- "3-day week" is labeled in the filing confirmation
- The status question acknowledges it: "Given your [N]-day week, how would
  you characterize what you got done — on track for the time you had,
  at risk, or blocked?"
- The PM view shows week_days so context is visible

Someone on a Monday holiday has a 4-day week. Someone at a conference has
a 2-day week. Both are valid. The database records what they filed.
The absence of a full week's output is context, not failure.
