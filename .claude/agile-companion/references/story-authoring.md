# Story Authoring Reference

Four onboarding ramps into story creation. All lead to the same output:
a well-formed, dependency-mapped, DoD-equipped Jira story ready for sprint planning.

---

## The Four Ramps

### Ramp 1: Vague narration — no ticket exists
Triggered when: user mentions work that maps to no existing Jira story.
Signal phrases: "I need to work on X", "we should probably do Y", "I've been thinking about Z"

### Ramp 2: Sprint planning pre-work
Triggered when: user enters SPRINT_PLANNING mode (see main SKILL.md).
Context: systematic workshop of all new/backlog stories before the team review meeting.

### Ramp 3: Stuck story — possible scope problem
Triggered when: same story In Progress 3+ consecutive sessions, no movement.
Companion asks: "Is this story scoped right, or has it become more than one story?"
If user confirms oversized → enter story workshop to decompose.

### Ramp 4: Explicit request
Triggered when: "help me write a story", "let's plan this out", "I need to break this down"

---

## The Jira Work Hierarchy

Always establish where a new story sits before writing it.

```
EPIC
└── FEATURE (or Initiative)
    └── STORY (user-facing deliverable)
        ├── TASK (technical work unit, no user value on its own)
        └── SUB-TASK (breakdown of a story or task)
```

**For data science work, a common pattern:**
```
EPIC: Churn Prediction Model
├── FEATURE: Data Pipeline
│   ├── STORY: Ingest raw transaction data
│   ├── STORY: Build feature transformation layer
│   └── STORY: Validate feature schema against contract
├── FEATURE: Model Development
│   ├── STORY: Baseline model (logistic regression)
│   ├── STORY: Feature selection spike [time-boxed]
│   └── STORY: Model evaluation framework
├── FEATURE: Stakeholder Delivery
│   ├── STORY: Performance report for review
│   └── STORY: Pilot deployment plan
```

When a user describes new work, always ask:
> "Where does this live — is it a new epic, a feature under an existing one, 
> or a story under a feature you already have?"

If they don't know: help them find the parent before writing the child.

---

## Story Workshop — The Interview

Run this for every new story. One question at a time. 
Don't present the template — *extract* the answers through conversation.

### Step 1: The user and their goal
> "Who benefits from this, and what do they actually need?"

For data science, the "user" is often internal:
- A downstream model that needs clean features
- A stakeholder who needs a decision-ready report
- Another team that depends on a schema or API contract
- The team itself (tooling, infrastructure)

Acceptable forms:
```
As a [churn model], I need [validated feature vectors] so that [training is reproducible]
As a [product manager], I want [a performance summary] so that [I can present to leadership]
As a [data engineer], I need [a stable schema contract] so that [my pipeline doesn't break]
```

If the user can't name a beneficiary: that's a signal the story may not be a story.
Ask: "Is this actually a task inside a larger story?"

### Step 2: Acceptance criteria
> "What would have to be true for this to be unambiguously done?"

Prompt for 2-4 criteria. Each should be:
- **Testable** — can be verified by someone who didn't write the code
- **Specific** — not "model performs well" but "F1 > 0.72 on held-out test set"
- **Bounded** — not open-ended research

For research/spike stories: acceptance criteria are **time-bound** not scope-bound:
```
Given [N days] of investigation:
- Document hypotheses tested
- Record null results with reasoning
- Identify leading approach or recommend next step
- Time box: [specific date]
```

### Step 3: Definition of Done (by work type)

Apply the right DoD template:

**Feature engineering story:**
```
- [ ] Transformation logic implemented and tested
- [ ] Schema contract documented (field names, types, nullability)
- [ ] Unit tests passing
- [ ] Peer review complete
- [ ] Output validated against downstream consumer requirements
```

**Model training/evaluation story:**
```
- [ ] Training pipeline reproducible (seed set, environment documented)
- [ ] Evaluation metrics computed on held-out set
- [ ] Baseline comparison documented
- [ ] Results written to Jira (including null results)
- [ ] Decision documented: proceed / pivot / stop
```

**Research spike:**
```
- [ ] Hypotheses tested documented
- [ ] Findings written (positive and negative)
- [ ] Follow-on stories created from findings (or explicit "no follow-on" note)
- [ ] Time box respected
```

**Stakeholder communication story:**
```
- [ ] Audience identified
- [ ] 3P summary drafted (see stakeholder-comms.md)
- [ ] Reviewed by [who] before delivery
- [ ] Delivered and acknowledged
```

**Infrastructure / tooling story:**
```
- [ ] Works in target environment (not just local)
- [ ] Documented for teammates who didn't write it
- [ ] Runbook or setup instructions written
```

### Step 4: Estimation — research-aware

Standard story points don't work well for exploratory work.
Use this two-axis approach:

**Effort estimate** (how much work if nothing goes wrong):
- XS: < 1 day
- S: 1–2 days  
- M: 3–5 days
- L: 1–2 weeks
- XL: needs decomposition before estimating

**Uncertainty flag** (how likely is "nothing goes wrong"):
- Low: well-understood, similar work done before
- Medium: some unknowns, but bounded
- High: research/exploration, outcome unclear
- Spike: explicitly time-boxed, scope open

A story that is L + High uncertainty → always decompose before sprint entry.
A story that is XL anything → not sprint-ready, needs breakdown first.

Companion prompt:
> "How much work is this if nothing surprises you — and how confident are you in that?"

### Step 5: Dependencies

Two types. Ask about both.

**Blocking dependencies** (Story B cannot start until Story A is done):
> "Is there anything that has to be finished before you can start this?"
> "Does anything else depend on this being done before it can start?"

Map these explicitly:
```
[DS-42b] Implementation fix
  → BLOCKED BY: [DS-42a] Investigation spike (must be closed first)
  → BLOCKS: [DS-42c] Evaluation and validation
```

**Resource dependencies** (needs an output, not a completion):
> "Does this story need a specific artifact from another story — 
> a schema, a model output, a dataset, an API contract?"

These are softer but critical for data science work. Log them as:
```
Informational dependency: requires [artifact] from [story/team]
Owner: [who produces it]
Expected by: [date]
```

If the dependency owner is on another team: flag for the team planning meeting.
> "This dependency crosses teams — it should be on the agenda for the review."

### Step 6: Write the story to Jira

Once workshop is complete, create the story:

```javascript
mcp_call: jira.createIssue
fields: {
  project: { key: "[PROJ]" },
  issuetype: { name: "Story" },
  parent: { key: "[FEATURE-KEY]" },  // always set parent
  summary: "[verb phrase — what gets built]",
  description: {
    // User story format
    // Acceptance criteria (numbered list)
    // Definition of Done (checklist)
    // Dependencies noted
    // Estimation: [size] / [uncertainty]
  },
  assignee: { accountId: "[currentUser]" },
  labels: ["data-science", "[work-type]", "[uncertainty-level]"]
}
```

Then create dependency links:
```javascript
mcp_call: jira.createIssueLink
type: { name: "Blocks" }  // or "is blocked by"
inwardIssue: { key: "[DS-42a]" }
outwardIssue: { key: "[DS-42b]" }
```

---

## Spike Story Pattern

Spikes deserve special handling because they're time-bounded research containers.

**Creation:**
- Issue type: Story (with label: `spike`)
- Summary format: "Spike: [question being investigated]"
- Acceptance criteria: time box + documented findings
- Always set a due date equal to the time box

**At spike close — the orphan check:**
Before closing any spike, ask:
> "What stories does this spike generate? Let's create them now so the findings
> don't disappear."

If user says "nothing yet": write a Jira comment with the findings and create
a follow-on task: "Review spike findings and create implementation stories."
A spike that closes without spawning follow-on work is institutional knowledge lost.

---

## Decomposition Triggers

Escalate to decomposition whenever:
- Story is L/XL + High/Spike uncertainty
- Story has been stuck 3+ sessions (scope problem detected)
- Acceptance criteria can't be written without saying "and also..."
- User can't describe done without branching ("it depends on what we find")

Decomposition conversation opener:
> "This sounds like it might be more than one story — let me ask:
> are there multiple distinct things that could each be done and 
> valuable independently? Or is there a research phase before an 
> implementation phase?"

Common data science decompositions:
- Investigation spike → Implementation story → Evaluation story
- "Build the model" → Feature pipeline + Training + Evaluation + Deployment
- "Prepare stakeholder report" → Gather metrics + Draft narrative + Review + Deliver

---

## Definition of Ready Checklist

Before any story enters a sprint, confirm:
```
[ ] User story format complete (who, what, why)
[ ] Acceptance criteria written (2-4, testable)
[ ] Definition of Done applied (right template for work type)
[ ] Effort estimated (size + uncertainty)
[ ] Blocking dependencies identified and linked in Jira
[ ] Resource dependencies noted with owners and dates
[ ] Parent epic/feature set
[ ] Cross-team dependencies flagged for planning meeting
```

If any item is unchecked: story is not sprint-ready.
The companion should not add a story to a sprint until this checklist passes.

> "Before I add this to the sprint — [item] isn't set yet. 
> It'll take two minutes now and save confusion later."

---

## Sprint Planning Mode (SPRINT_PLANNING)

Goal: User shows up to the 30-minute team planning meeting with every story
already well-formed, estimated, and dependency-mapped. The meeting focuses on
cross-team complexity — not basic story hygiene.

### The pre-work session

Open with scope:
> "Let's prep your sprint. How many days do you have available next sprint,
> and are there any known interruptions (meetings, OOO, on-call)?"

Establish capacity first. Then pull the candidate stories.

### Fetch backlog candidates
Pull stories in "To Do" or "Backlog" status assigned to the user, ordered by priority.
See `references/atlassian-patterns.md` → "Fetch backlog for sprint planning."

Present the candidate list:
```
Your sprint candidates (ranked by priority):

Ready to pull in:
  • [DS-42b] Implement precision fix — S / Medium uncertainty
  • [DATA-3] Schema migration — M / Low uncertainty

Need story workshop before sprint entry:
  • [DS-44] "Improve model performance" — too vague, no AC
  • [ML-9] "Stakeholder reporting" — no DoD, unclear scope

Backlog (lower priority):
  • [DS-47] Feature store evaluation
```

### Workshop the "not ready" stories first
For each story missing Definition of Ready criteria: run the Story Workshop interview.
Don't skip this. A story that enters a sprint without AC will cause confusion mid-sprint.

> "Before we add [DS-44] — it doesn't have acceptance criteria yet.
> That'll take five minutes now and save a week of ambiguity."

### Capacity check
After workshopping stories, check if the sprint is realistic:

Total estimated effort vs. available days.
Flag stories that are High/Spike uncertainty:
> "You have [N] days and [X] points of High-uncertainty work.
> High-uncertainty stories typically run 1.5-2x estimates.
> Want to timeboxed DS-44 rather than scope-committing?"

### Cross-team dependency flag list
Before closing pre-work, produce a dependency summary for the planning meeting:

```
For the planning meeting — cross-team dependencies to raise:

1. DS-42b BLOCKED BY data eng (Mira): Training window definition needed.
   → Raise with: data engineering team
   → Need by: [date]

2. DATA-3 informational dependency: Requires pipeline completion from [team].
   → Raise with: [team]
   → Impact if late: [what slips]
```

> "These are the items that need the room to resolve — your own stories are
> ready. Take this list into the meeting."

### What "sprint-ready" means for the planning meeting

The user's job in the meeting is NOT to explain their stories.
It's to surface cross-team complexity:
- Dependencies on other people's work
- Risks that require team decisions
- Stories where someone else's output feeds their input

If the pre-work is done, the user can say in the meeting:
"My stories are ready — the one thing I need from this room is confirmation
on [dependency] from [team]."

---

## Edge Cases

### The invisible collaborator
User mentions working with a teammate on a story that's only assigned to them.
> "Sounds like [person] is working on this with you — should we add them as
> a co-assignee or watcher? That way they get visibility on comments too."

### The orphaned spike (no follow-on stories created)
When closing any spike: always check before marking done.
> "Before we close this — what stories does this generate?
> Even one follow-on task keeps the findings from disappearing."
If none: create a task "Review [spike] findings and create implementation stories"
assigned to the user with a 3-day due date.

### "Done but not documented" 
User says work is complete but hasn't written it up or committed.
Separate the two:
> "Sounds like the work is done — want to mark it 'Done' in Jira now
> and add the documentation as a sub-task? That way your velocity
> reflects reality while the write-up gets its own home."

### The stakeholder interrupt (unplanned work)
User did work that wasn't in the sprint.
> "That wasn't in the sprint — want to log it as an unplanned item?
> It matters for the team to see where capacity actually went."
Create a task with label `unplanned` and log time/effort. This feeds the 3P
Problems section if it displaced planned work.

### Story point inflation
If a user has estimated similar stories at S and they've consistently taken 2x:
> "You've estimated a few similar stories at S before — they usually run longer.
> Want to bump this to M, or timeboxed it instead?"
Surface once, don't harp on it.
