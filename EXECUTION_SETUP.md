---
title: Execution Layer Setup Guide
version: 1.0.0
---

# Execution Layer Setup & Usage

This guide explains how to use the **optional execution layer** on the `execution-optional` branch: agents, commands, and integrations.

## When You Need This

Use this setup if you want **LLM-driven automation** for code and data review.

If you just want **static knowledge** (rules, skills, prompts), stay on the `main` branch—no setup needed.

## Architecture

```
Knowledge-First Core (Main Branch)
├── rules/            → Always-on constraints
├── skills/           → Manual workflows
├── prompts/          → Reusable templates
└── templates/        → Contribution starters

Optional Execution (execution-optional Branch)
├── agents/           → Specialist reviewers (data-reviewer, model-trainer, pipeline-validator)
├── commands/         → Workflow shortcuts (/eda, /validate-data, /evaluate-model)
├── hooks/            → (Coming) Automation triggers
└── integrations/     → (Coming) MCP configs
```

## Setup by IDE/Tool

### Cursor Setup

1. **Add marketplace as git submodule:**

```bash
git submodule add https://github.com/your-org/cursor-marketplace .cursor/shared
cd .cursor/shared
git checkout execution-optional
```

2. **Create `.cursor/rules/index.json` to enable agents:**

```json
{
  "rules": [
    {
      "path": ".cursor/shared/agents/data-reviewer.md",
      "enabled": true,
      "description": "Data quality specialist"
    },
    {
      "path": ".cursor/shared/agents/model-trainer.md",
      "enabled": true,
      "description": "ML training specialist"
    },
    {
      "path": ".cursor/shared/agents/pipeline-validator.md",
      "enabled": true,
      "description": "Pipeline architecture specialist"
    }
  ]
}
```

3. **Reference commands in your `.cursor/rules/`:**

Copy the commands to your rules directory or reference them:
```bash
cp .cursor/shared/commands/*.md .cursor/rules/
```

4. **Use agents and commands:**

```
@data-reviewer
Review this transformation for data quality...

@model-trainer
Check this model training code...

/eda
I have a new dataset to explore...
```

### Claude Code Setup

1. **Add marketplace:**

```bash
git submodule add https://github.com/your-org/cursor-marketplace marketplace
cd marketplace
git checkout execution-optional
```

2. **Create `CLAUDE.md` in project root with:**

```markdown
# Our Claude Code Config

## Agents

- Use @data-reviewer for data validations
- Use @model-trainer for model reviews
- Use @pipeline-validator for pipeline architecture

## Commands

- /eda - Explore new datasets
- /validate-data - Validate transformations
- /evaluate-model - Review model training

## Configuration

Agents located in: marketplace/agents/
Commands located in: marketplace/commands/
```

3. **Use agents:**

```
@data-reviewer
Review this pipeline for data quality issues...
```

### Generic LLM (Claude.ai, ChatGPT, etc.)

1. **Copy agent files to your project:**

```bash
cp -r marketplace/agents/ [your-project]/
cp -r marketplace/commands/ [your-project]/
```

2. **Reference in your prompt:**

```
Using the data-reviewer agent framework from marketplace/agents/data-reviewer.md:

[Your question about data validation]
```

## Using Agents

### Agent Types

| Agent | Specialization | Use When |
|-------|---|---|
| **data-reviewer** | Data quality, validation, schema | Validating pipelines, checking transformations |
| **model-trainer** | Model training, hyperparameters, evaluation | Training models, reviewing training code |
| **pipeline-validator** | Pipeline design, orchestration, reliability | Designing pipelines, ensuring scalability |

### Example Workflow

```
You: @data-reviewer
Please review this customer order transformation:
[paste SQL]

Agent: I'll check schema, transformations, and data quality...
[detailed review with issues and approval status]
```

## Using Commands

### Command Types

| Command | Purpose | Agent |
|---------|---------|-------|
| **/eda** | Explore new dataset | data-reviewer |
| **/validate-data** | Validate transformation | data-reviewer |
| **/evaluate-model** | Review model training | model-trainer |

### Example Workflow

```
You: /eda

I just loaded customer_orders.csv with 100k rows.
What patterns should I investigate?

Agent (via data-reviewer):
Let's profile the data...
[step-by-step EDA with insights]
```

## Coming Soon (Phase 2)

- **Hooks:** Automation triggers for pipeline quality gates
- **Integrations:** MCP configs for data platforms (Snowflake, BigQuery, dbt, W&B)
- **Execution Options:** Bash commands, SQL generation, code scaffolding

## Philosophy

**Agents** = "Tell me if this is good"
**Commands** = "Help me do this"
**Skills** = "Here's how to do this yourself"

Choose based on your workflow:
- Quick feedback? Use agents.
- Guided process? Use commands.
- Learning? Use skills on main branch.

## Troubleshooting

### "Agent not recognized"

**Solution:** Make sure you're on the `execution-optional` branch:
```bash
cd .cursor/shared  # or marketplace/
git branch -a
git checkout execution-optional
```

### "Can't find command /eda"

**Solution:** Copy commands to your IDE's rules directory:
```bash
# Cursor
cp marketplace/commands/*.md .cursor/rules/

# Or reference from shared location
```

### "Agent seems to have incomplete context"

**Solution:** Paste relevant code/config directly in your message alongside the agent invocation.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Adding new agents
- Creating new commands
- Extending for other domains

---

## Understanding the Philosophy

This marketplace has **two paths**:

### Path 1: Knowledge-First (Main Branch)
- Use rules, skills, prompts as reference
- Work manually using skills as checklists
- Distribution: lightweight git submodule
- Setup time: 5 minutes
- Best for: Teams comfortable with manual workflows

### Path 2: Execution-Driven (execution-optional Branch)
- Use agents for automated review
- Use commands for guided workflows
- Distribution: opt-in branch
- Setup time: 15-30 minutes
- Best for: Teams with LLM-native infrastructure

Both paths use the same domain organization and knowledge base. Choose based on your team's preferences and infrastructure.

---

**Stay lightweight.** This branch is optional. If agents and commands add complexity without value, stay on main.
