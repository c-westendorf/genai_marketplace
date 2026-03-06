# Cursor Marketplace

A curated collection of AI coding rules, skills, and prompts for data science and analytics teams. **Tool-agnostic** — works with Cursor, Claude, VSCode, Zed, and other GenAI IDEs.

---

## Philosophy

**Knowledge-First + Optional Automation:**
- **Core (Main Branch):** Rules, skills, and prompts—static knowledge shared via git submodule
- **Execution Layer (Optional):** Agents, commands, hooks—for teams wanting LLM-driven automation (separate branch)

This separation keeps the marketplace lightweight while enabling advanced automation workflows.

---

## Overview

This repository contains shared resources that can be consumed across projects via git submodules.

### What's Included

| Category | Count | Description |
|----------|-------|-------------|
| [Rules](rules/) | 12 | Persistent AI instructions by domain (ML, Analytics, Data Eng) |
| [Skills](skills/) | 5+ | Workflow guides with steps and checkpoints |
| [Prompts](prompts/) | 6+ | Reusable prompt templates by use case |
| [Templates](templates/) | 3 | Starter templates for contributions |
| **Agents** | 3 | Optional: delegated task specialists ([on execution-optional branch](https://github.com/your-org/cursor-marketplace/tree/execution-optional)) |
| **Commands** | 3 | Optional: slash-command shortcuts for workflows ([on execution-optional branch](https://github.com/your-org/cursor-marketplace/tree/execution-optional)) |
| **Integrations** | 3 | Optional: Snowflake, BigQuery, Atlassian data platform configs ([on execution-optional branch](https://github.com/your-org/cursor-marketplace/tree/execution-optional)) ✅ Complete |

---

## Quick Start

### Tool Compatibility

| Tool | File Format | Path Convention | Status |
|------|------------|-----------------|--------|
| **Cursor** | `.mdc` (markdown) | `.cursor/rules/`, `.cursor/skills/` | ✅ Native |
| **Claude** | `.md` (markdown) | Project root or custom | ✅ Compatible |
| **VSCode** | `.md` (markdown) | `.vscode/` or custom | ✅ Compatible |
| **Zed** | `.md` (markdown) | `.zed/` or custom | ✅ Compatible |
| **Generic LLM** | `.md` (markdown) | Any path | ✅ Compatible |

**Note:** `.mdc` is Cursor's markdown variant; all content can be converted to `.md` for other tools.

### Add to Your Project

```bash
# Add marketplace as git submodule
git submodule add https://github.com/org/cursor-marketplace .cursor/shared

# Initialize (for cloned repos)
git submodule init
git submodule update
```

### Use Resources

**Rules:** Copy to your tool-specific rules directory or reference from shared location.

```bash
# For Cursor
cp .cursor/shared/rules/ml/model-training.mdc .cursor/rules/

# For Claude Code / generic usage
cp .cursor/shared/rules/ml/model-training.md [project-root]/

# Or symlink for automatic updates
ln -s ../shared/rules/ml/model-training.mdc .cursor/rules/
```

**Skills & Prompts:** Reference in conversations using `@` syntax (Cursor), or copy to your project directory.

---

## Core Concepts

### What Makes This Marketplace Different

**Domain-Organized:** Resources are grouped by domain (ML, Analytics, Data Engineering) so you find what you need quickly.

**Tool-Agnostic:** Works with Cursor, Claude, VSCode, Zed—not locked to one IDE or LLM.

**Modular:** Start with knowledge-only rules/skills/prompts. Add automation (agents/commands) when ready.

**Flexible Consumption:** Use as a git submodule for automatic updates, or fork/copy for full control.

---

## Understanding This Marketplace

### Core Structure

```
cursor-marketplace/
├── rules/                  # Always-on constraints by domain
│   ├── ml/
│   ├── analytics/
│   └── data-eng/
│
├── skills/                 # Manual workflow guides
│   ├── ml/
│   ├── analytics/
│   └── data-eng/
│
├── prompts/                # Reusable prompt templates
│   ├── ml/
│   ├── analytics/
│   └── data-eng/
│
└── templates/              # Contribution templates
    ├── rule-template.mdc
    ├── skill-template.md
    └── prompt-template.md

Note: Agents, commands, and integrations are on execution-optional branch
```

### Two Paths to Use This Marketplace

**Path 1: Knowledge-First (Main Branch)**
- **What you get:** Rules, skills, prompts as static reference material
- **Setup:** Just clone or add as git submodule; no configuration needed
- **Use case:** Learning, reference, teams using manual workflows
- **Start:** `git clone https://github.com/your-org/cursor-marketplace` or add as submodule

**Path 2: Automation-Enabled (execution-optional Branch)**
- **What you get:** Everything from Path 1 + agents, commands, and data platform integrations
- **Agents:** Specialist LLM personas for code review (data-reviewer, model-trainer, pipeline-validator)
- **Commands:** Workflow shortcuts (/eda, /validate-data, /evaluate-model)
- **Integrations:** Snowflake, BigQuery, Atlassian (Jira + Confluence) MCP configs with full setup guides
- **Setup:** Follow [EXECUTION_SETUP.md](EXECUTION_SETUP.md) for your IDE (VSCode, Cursor, Claude Code)
- **Use case:** Teams with LLM-native workflows wanting automation and data platform access

**Choose your path:** Start with main for knowledge; switch to execution-optional when ready for automation.

---

## Browse Catalog

### Rules by Domain

**Machine Learning** (`rules/ml/`)
- [model-training.mdc](rules/ml/model-training.mdc) - Training standards
- [evaluation-metrics.mdc](rules/ml/evaluation-metrics.mdc) - Evaluation requirements
- [hyperparameter-tuning.mdc](rules/ml/hyperparameter-tuning.mdc) - Tuning practices
- [data-leakage-prevention.mdc](rules/ml/data-leakage-prevention.mdc) - Leakage prevention
- [reproducibility.mdc](rules/ml/reproducibility.mdc) - Reproducibility standards

**Analytics** (`rules/analytics/`)
- [sql-safety.mdc](rules/analytics/sql-safety.mdc) - SQL best practices
- [data-validation.mdc](rules/analytics/data-validation.mdc) - Validation requirements
- [dashboard-standards.mdc](rules/analytics/dashboard-standards.mdc) - Dashboard guidelines
- [reporting-quality.mdc](rules/analytics/reporting-quality.mdc) - Report standards

**Data Engineering** (`rules/data-eng/`)
- [pipeline-standards.mdc](rules/data-eng/pipeline-standards.mdc) - Pipeline conventions
- [schema-validation.mdc](rules/data-eng/schema-validation.mdc) - Schema requirements
- [logging-requirements.mdc](rules/data-eng/logging-requirements.mdc) - Logging standards

### Skills by Domain

See [skills/README.md](skills/README.md) for full index organized by:
- Machine Learning
- Analytics
- Data Engineering
- General / Multi-Domain

### Prompts by Domain

See [prompts/README.md](prompts/README.md) for full index organized by:
- Use Cases (EDA, Debugging, Code Review, Validation, Feature Engineering)
- Domains (ML, Analytics, Data Eng)

### Optional: Agents, Commands & Integrations

Available on the **execution-optional** branch:

**Agents:** Specialist LLM personas for focused review
- [data-reviewer](agents/data-reviewer.md) - Data quality and transformation review
- [model-trainer](agents/model-trainer.md) - ML training and evaluation guidance
- [pipeline-validator](agents/pipeline-validator.md) - Pipeline architecture and reliability

**Commands:** Workflow shortcuts
- [/eda](commands/eda.md) - Exploratory data analysis
- [/validate-data](commands/validate-data.md) - Data transformation validation
- [/evaluate-model](commands/evaluate-model.md) - Model training review

**Integrations:** Data platform and tool connections (MCP Protocol)
- [Snowflake](integrations/SNOWFLAKE_SETUP.md) - Query, profile, and analyze data
- [BigQuery](integrations/BIGQUERY_SETUP.md) - Analytics and ML model creation
- [Atlassian](integrations/ATLASSIAN_SETUP.md) - Jira issue tracking and Confluence documentation

See [EXECUTION_SETUP.md](EXECUTION_SETUP.md) for complete setup guide for your IDE.

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Contribution Steps

1. Fork this repository
2. Create your resource using templates in `templates/`
3. Submit a pull request
4. Two reviewers approve
5. Merged in next release

---

## Versioning

This repository uses [semantic versioning](https://semver.org/):

- **MAJOR**: Breaking changes (rule removals, renames)
- **MINOR**: New resources, backward-compatible enhancements
- **PATCH**: Fixes, documentation improvements

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## Governance

- All contributions require 2-person review
- CI validates YAML schema, markdown linting, spell check
- Resources must meet quality standards (see CONTRIBUTING.md)

---

## License

[Your organization's license]
