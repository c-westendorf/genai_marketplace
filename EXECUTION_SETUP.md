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

### VSCode + Copilot Setup

VSCode is the recommended IDE for this marketplace with native Copilot integration.

#### 1. Install Extensions

```bash
# Copilot (GitHub's native LLM integration)
code --install-extension GitHub.copilot

# Optional: Other LLM providers
code --install-extension OpenAI.openai-copilot
code --install-extension Google.gemini
```

#### 2. Add Marketplace as Git Submodule

```bash
# In your project root
git submodule add https://github.com/your-org/cursor-marketplace .marketplace
cd .marketplace
git checkout execution-optional
```

#### 3. Configure MCP Servers

Edit `.vscode/settings.json` in your project root:

```json
{
  "mcp.servers": {
    "marketplace-agents": {
      "command": "cat",
      "args": [".marketplace/agents/data-reviewer.md"],
      "description": "Data quality reviewer agent"
    },
    "marketplace-commands": {
      "command": "cat",
      "args": [".marketplace/commands/eda.md"],
      "description": "EDA command reference"
    },
    "snowflake": {
      "command": "node",
      "args": ["path/to/snowflake-mcp-server.js"],
      "env": {
        "SNOWFLAKE_ACCOUNT": "${env:SNOWFLAKE_ACCOUNT}",
        "SNOWFLAKE_USER": "${env:SNOWFLAKE_USER}",
        "SNOWFLAKE_PASSWORD": "${env:SNOWFLAKE_PASSWORD}",
        "SNOWFLAKE_WAREHOUSE": "${env:SNOWFLAKE_WAREHOUSE}",
        "SNOWFLAKE_DATABASE": "${env:SNOWFLAKE_DATABASE}",
        "SNOWFLAKE_SCHEMA": "${env:SNOWFLAKE_SCHEMA}"
      }
    },
    "bigquery": {
      "command": "node",
      "args": ["path/to/bigquery-mcp-server.js"],
      "env": {
        "GOOGLE_PROJECT_ID": "${env:GOOGLE_PROJECT_ID}",
        "GOOGLE_APPLICATION_CREDENTIALS": "${env:GOOGLE_APPLICATION_CREDENTIALS}",
        "BIGQUERY_DATASET": "${env:BIGQUERY_DATASET}",
        "BIGQUERY_LOCATION": "${env:BIGQUERY_LOCATION}"
      }
    },
    "atlassian": {
      "command": "node",
      "args": ["path/to/atlassian-mcp-server.js"],
      "env": {
        "ATLASSIAN_DOMAIN": "${env:ATLASSIAN_DOMAIN}",
        "ATLASSIAN_EMAIL": "${env:ATLASSIAN_EMAIL}",
        "ATLASSIAN_API_TOKEN": "${env:ATLASSIAN_API_TOKEN}",
        "ATLASSIAN_JIRA_PROJECT_KEYS": "${env:ATLASSIAN_JIRA_PROJECT_KEYS}",
        "ATLASSIAN_CONFLUENCE_SPACE_KEYS": "${env:ATLASSIAN_CONFLUENCE_SPACE_KEYS}"
      }
    }
  }
}
```

#### 4. Configure LLM Providers

Add API keys to `.env` (gitignore this file):

```bash
# GitHub Copilot (authenticates via VSCode account)
# No setup needed; sign in via VSCode extensions panel

# Alternative: OpenAI API
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4

# Alternative: Google Gemini
GEMINI_API_KEY=...
GEMINI_MODEL=gemini-pro

# Alternative: Anthropic Claude
ANTHROPIC_API_KEY=sk-ant-...
ANTHROPIC_MODEL=claude-3-sonnet-20240229
```

#### 5. Use Agents in Copilot Chat

Open Copilot chat (Cmd+Shift+I on macOS, Ctrl+Shift+I on Windows/Linux) and reference agents:

```
@marketplace-agents data-reviewer

Review this SQL transformation for data quality issues:
[paste SQL code]
```

Or use Copilot to query data platforms:

```
@snowflake
Show me the top 10 customers by revenue from the ANALYTICS database

@bigquery
Create a linear regression model for churn prediction

@atlassian
Create a DATA project issue for data quality improvements
```

#### 6. Example Workflow: Query → Analyze → Document

**In VSCode Copilot Chat:**

```
Step 1: @snowflake
Query the CUSTOMERS table and identify high-value segments

Step 2: @marketplace-agents data-reviewer
Validate the data quality and business logic

Step 3: @atlassian
Create a Confluence page documenting the findings and
link it to a DATA project issue for stakeholder review
```

**Result:** Complete workflow from query to documentation within VSCode.

#### 7. Keyboard Shortcuts & Tips

| Action | Shortcut |
|--------|----------|
| Open Copilot Chat | Cmd+Shift+I (macOS), Ctrl+Shift+I (Windows/Linux) |
| Inline Copilot | Cmd+I (macOS), Ctrl+I (Windows/Linux) |
| Reference marketplace | Type `@marketplace-agents` |
| Reference data platform | Type `@snowflake`, `@bigquery`, `@atlassian` |
| Paste code context | Paste directly in chat; Copilot infers context |

#### 8. Troubleshooting VSCode Setup

| Issue | Solution |
|-------|----------|
| "Copilot not authenticated" | Sign in via Extensions panel (GitHub Copilot) |
| "MCP server not found" | Verify path in `.vscode/settings.json` is correct |
| "Missing .env variables" | Create `.env` file with required credentials; add to `.gitignore` |
| "Command not recognized" | Reference agents/commands explicitly with `@marketplace-agents` |

See [integrations/README.md](.marketplace/integrations/README.md) for detailed setup guides for Snowflake, BigQuery, and Atlassian.

---

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
