# Atlassian MCP Patterns

MCP call patterns for all Jira operations this skill performs.
MCP server: configured per team deployment (see SKILL.md compatibility block).

---

## Fetch User Portfolio

Get all stories assigned to the current user across active sprints.

```javascript
// Get active sprint stories for user across all boards
mcp_call: jira.searchIssues
jql: "assignee = currentUser() AND sprint in openSprints() ORDER BY updated DESC"
fields: [summary, status, project, priority, updated, duedate, labels, issuetype]
maxResults: 50
```

Then filter and rank per SKILL.md → Project Portfolio & Focus Ranking.

To get recently touched stories (Tier 2 ranking):
```javascript
jql: "assignee = currentUser() AND updated >= -2d ORDER BY updated DESC"
```

---

## Write Story Comment

Used for standup notes, EOD updates, research findings, blocker flags.

```javascript
mcp_call: jira.addComment
issueKey: "[PROJ-12]"
body: {
  type: "doc",
  version: 1,
  content: [{
    type: "paragraph",
    content: [{ type: "text", text: "[comment text]" }]
  }]
}
```

**Comment templates by type:**

Standup:
```
Standup [YYYY-MM-DD]: [what they said about this story]
Plan today: [their stated intention]
```

EOD standard:
```
EOD [YYYY-MM-DD]: [what happened]
Tomorrow: [their stated next step]
```

EOD research:
```
EOD [YYYY-MM-DD]:
Research progress: [what was explored]
Finding: [what was learned — including null results]
Next step: [what this opens up or closes off]
```

Blocker:
```
Blocked [YYYY-MM-DD]: [what is blocking, neutral language]
Root cause: [one line]
Waiting on: [person/system/data]
Next step: [action anchor from support mode]
```

Week open:
```
Week of [YYYY-MM-DD] — Intention:
Focus: [their words]
Key stories: [list]
Known risks: [if any]
Goal: [what a good week looks like in their words]
```

Re-entry note (context switch or mid-investigation EOD):
```
Re-entry note [YYYY-MM-DD HH:MM]: 
Active hypothesis / next step: [user's own words]
Context when paused: [what was being worked on]
Pick up here: [specific next action]
```

Portfolio drift flag (Friday only — stories with zero activity this week):
```
Portfolio note [date]: This story had no activity this sprint week.
Status: [deliberately deferred / needs team discussion / moving to backlog]
```


Completed: [what shipped or concluded]
Research findings: [learning, including null results]
Carry-forward: [the one thread with momentum]
Blockers that persisted: [for team visibility]
```

---

## Transition Story Status

Always confirm before executing. Pattern:
> "[PROJ-12] looks done — want me to move it to Review?"

```javascript
mcp_call: jira.transitionIssue
issueKey: "[PROJ-12]"
transitionId: "[get from available transitions first]"
```

To get available transitions:
```javascript
mcp_call: jira.getTransitions
issueKey: "[PROJ-12]"
// Returns array of {id, name} — use name to find correct transition
```

Common transition names: "In Progress", "In Review", "Done", "Blocked"
(names vary by team workflow — always fetch before assuming)

---

## Create Sub-task

Used in Support Mode when a story is too large (scope blocker).
Always confirm with user before creating:
> "Want me to break [PROJ-12] into smaller pieces? I can draft the sub-tasks."

```javascript
mcp_call: jira.createIssue
fields: {
  project: { key: "[PROJ]" },
  issuetype: { name: "Sub-task" },
  parent: { key: "[PROJ-12]" },
  summary: "[sub-task description]",
  assignee: { accountId: "[currentUser]" }
}
```

---

## Fetch Sprint Context

Get current sprint details for a project (used on Monday for WEEK_OPEN).

```javascript
mcp_call: jira.getBoard
// Get board ID for project first, then:
mcp_call: jira.getSprint
boardId: "[boardId]"
state: "active"
// Returns: sprint name, startDate, endDate, goal
```

---

## Search for Blocked Stories

For surfacing persistent blockers in standup and weekly framing.

```javascript
jql: "assignee = currentUser() AND status = Blocked ORDER BY updated ASC"
```

---

## Error Handling

If MCP calls fail or return empty:
- Don't surface the technical error to the user
- Fall back gracefully: "I couldn't pull your board — can you tell me what you're
  working on today?" Then proceed with narrative input
- Still write comments when connection recovers
- If Atlassian is consistently unavailable, note it once and work from user narration

---

## Notes on Comment Visibility

All comments written by this skill are visible to the team. This means:
- Never write emotional content, frustration, or personal struggle into Jira
- Support mode output → only structured, professional summary (see daily-rhythm.md)
- The user's narration stays in the conversation; only the distilled output goes to Jira
- If a user says something they probably don't want logged, check: "Want me to
  include that in the Jira comment, or keep it just between us?"

---

## Fetch Backlog for Sprint Planning

Get To Do / Backlog stories for sprint planning pre-work:

```javascript
// Stories assigned to user, not yet in a sprint
mcp_call: jira.searchIssues
jql: "assignee = currentUser() AND sprint is EMPTY AND status in ('To Do', 'Backlog') ORDER BY priority ASC"
fields: [summary, status, priority, storyPoints, labels, issuelinks, parent, duedate]

// Stories in current sprint (to review carry-overs)
jql: "assignee = currentUser() AND sprint in openSprints() ORDER BY priority ASC"
```

## Fetch Dependency Links for a Story

```javascript
mcp_call: jira.getIssue
issueKey: "[PROJ-12]"
fields: [issuelinks, subtasks, parent]
// issuelinks contains: blocks, is blocked by, relates to
```

## Create Issue Link (Dependency)

```javascript
mcp_call: jira.createIssueLink
body: {
  type: { name: "Blocks" },        // or "is blocked by", "relates to"
  inwardIssue: { key: "[DS-42a]" },
  outwardIssue: { key: "[DS-42b]" },
  comment: {
    body: "DS-42a must complete before DS-42b can begin (findings feed implementation)"
  }
}
```

## Add Story to Sprint

```javascript
mcp_call: jira.addIssuesToSprint
sprintId: "[sprint-id]"  // get from getSprint call
issues: ["[PROJ-12]", "[PROJ-15]"]
```

## Log Unplanned Work

Create with unplanned label and note in sprint:
```javascript
mcp_call: jira.createIssue
fields: {
  project: { key: "[PROJ]" },
  issuetype: { name: "Task" },
  summary: "Unplanned: [what was done]",
  labels: ["unplanned", "sprint-[N]"],
  description: "Unplanned work completed [date]. Approx effort: [size]. Displaced: [what it affected if anything]"
}
```

---

## Gap Detection Queries

### Find last user activity (gap measurement)
```javascript
// Get most recently updated stories assigned to user
mcp_call: jira.searchIssues
jql: "assignee = currentUser() AND updated >= -30d ORDER BY updated DESC"
fields: [summary, updated, comment, status]
maxResults: 20
// Iterate comments on top results to find last comment authored by currentUser
// Compare to today's date to compute gap in days
```

### Delta scan — what changed during the gap
```javascript
// All user's stories updated during gap period
jql: "assignee = currentUser() AND updated >= -[GAP_DAYS]d ORDER BY updated DESC"
fields: [summary, status, comment, assignee, issuelinks, changelog]

// Stories where user is a watcher — may have changed without assignment
jql: "watcher = currentUser() AND updated >= -[GAP_DAYS]d AND assignee != currentUser()"
fields: [summary, status, comment, assignee]
```

### Team impact — who is blocked waiting on returning user
```javascript
// For each of the user's active stories, fetch outward "blocks" links
mcp_call: jira.getIssue
issueKey: "[USER_STORY_KEY]"
fields: [issuelinks]
// Filter issuelinks where type.outward = "blocks" or type.inward = "is blocked by"
// These are teammates whose work depends on the returning user
```

### Sprint change detection
```javascript
// Get current active sprint
mcp_call: jira.getBoard  // get boardId for user's primary project
mcp_call: jira.getSprint
boardId: "[boardId]"
state: "active"
// Compare sprint.startDate to gap start date
// If sprint.startDate > gap_start: sprint turned over during absence
```

### Gap narrative — sprint-level comment
```javascript
// Write context comment to the active sprint (not a story)
mcp_call: jira.addComment
issueKey: "[SPRINT_EPIC_OR_SUMMARY_STORY]"
body: {
  // Focused sprint template or PTO/leave template
  // See return-protocol.md → Gap narrative templates
}
```

### Attribution confirmation patterns

After user confirms narration maps to a story, write with explicit attribution note:
```javascript
mcp_call: jira.addComment
issueKey: "[CONFIRMED_STORY_KEY]"
body: {
  content: [{
    type: "paragraph",
    content: [{ type: "text", text:
      "[Catch-up log — [date range]]\n[user narration formatted per work type]"
    }]
  }]
}
```

If narration is unplanned work with no matching ticket:
```javascript
mcp_call: jira.createIssue
fields: {
  issuetype: { name: "Task" },
  summary: "Unplanned: [work described]",
  labels: ["unplanned", "catch-up-log"],
  description: "Logged retroactively during return catch-up. Work occurred: [date range]."
}
```

---

## Confluence Database Operations

### Query database rows
```javascript
mcp_call: confluence.database.query
database_id: "[from team-config.yml]"
filter: {
  and: [
    { field: "person", operator: "equals", value: "[username]" },
    { field: "week_start", operator: "equals", value: "[YYYY-MM-DD]" }
  ]
}
// Returns: { rows: [{id, fields}], total }
```

### Create new row (first filing of week)
```javascript
mcp_call: confluence.database.createRow
database_id: "[database_id]"
fields: {
  person: "[username]",
  week_start: "[YYYY-MM-DD — Monday of week]",
  sprint: "[sprint name]",
  product_area: "[plain language product description]",
  status: "on_track",        // on_track | at_risk | blocked
  progress: "[text]",
  problems: "[text or empty]",
  plans: "[text]",
  confidence: "medium",      // high | medium | low
  filed_at: "[ISO datetime]",
  week_days: 5
}
// Returns: { id, fields }
```

### Update existing row (re-filing)
```javascript
mcp_call: confluence.database.updateRow
database_id: "[database_id]"
row_id: "[from query result .id]"
fields: {
  // only fields being updated — partial update safe
  status: "[updated status]",
  progress: "[updated text]",
  filed_at: "[new timestamp]"
}
```

### Count filings for current week (team progress signal)
```javascript
mcp_call: confluence.database.query
database_id: "[database_id]"
filter: { field: "week_start", operator: "equals", value: "[current Monday]" }
// Use result.total for "N people have filed this week"
```

### Get personal Confluence page (for personal page update)
```javascript
// First time: create page under parent
mcp_call: confluence.createPage
space_key: "[from team-config.yml]"
parent_id: "[personal_page_parent_id]"
title: "[Name] — Weekly 3P Log"
body: "[initial content]"

// Subsequent updates: read current, prepend new week, write back
mcp_call: confluence.getPage
page_id: "[personal_page_id]"
// → read body content

mcp_call: confluence.updatePage
page_id: "[personal_page_id]"
version: "[current_version + 1]"
body: "[new week section] + [existing content]"  // prepend pattern
```

### Check who hasn't filed (PM utility — optional)
```javascript
// Get all team members from config, compare to current week's database rows
// Returns list of usernames with no row for current week_start
mcp_call: confluence.database.query
database_id: "[database_id]"
filter: { field: "week_start", operator: "equals", value: "[current Monday]" }
// Compare result row persons against team_members list in team-config.yml
// Missing persons = not yet filed
```
