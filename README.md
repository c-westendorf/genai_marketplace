# Cursor Marketplace

A curated collection of AI coding rules, skills, and prompts for data science and analytics teams. **Tool-agnostic** — works with Cursor, Claude, VSCode, Zed, and other GenAI IDEs.

> **Note:** This marketplace adapts patterns from [everything-claude-code](https://github.com/affaan-m/everything-claude-code) and is built for ecosystem independence. While optimized for data domain, the structure is replicable for other domains.

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
| **Agents** | *coming* | Optional: delegated task specialists ([see execution-optional branch](https://github.com/your-org/cursor-marketplace/tree/execution-optional)) |
| **Commands** | *coming* | Optional: slash-command shortcuts for workflows ([see execution-optional branch](https://github.com/your-org/cursor-marketplace/tree/execution-optional)) |

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

## Roadmap

### Phase 1: Knowledge-First Core (Main Branch) — ✅ Current
- ✅ Reorganize skills by domain (ML, Analytics, Data Eng)
- ✅ Extend prompt library (6 → 12+ templates)
- ✅ Add tool compatibility matrix
- ✅ Update templates with metadata
- ✅ Create agents/ with data specialists (data-reviewer, model-trainer, pipeline-validator)
- ✅ Create commands/ with workflow shortcuts (/eda, /validate-data, /evaluate-model)

### Phase 2: Optional Execution Layer (Planning)
Create a separate `execution-optional` branch for teams wanting LLM-driven automation:
- [ ] Move agents/ and commands/ to optional branch
- [ ] Create `hooks/` for automation triggers
- [ ] Create `integrations/` for MCP configs (Snowflake, BigQuery, dbt, W&B)
- [ ] Document setup for automation workflows

### Phase 3: Domain Extensibility (Deferred)
- [ ] Add other-domains template (backend, frontend, devops, etc.)
- [ ] Document context window management per domain
- [ ] Build community contribution process

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
├── agents/                 # Optional: Specialist reviewers
│   ├── data-reviewer
│   ├── model-trainer
│   └── pipeline-validator
│
└── commands/               # Optional: Workflow shortcuts
    ├── /eda
    ├── /validate-data
    └── /evaluate-model
```

### Two Layers

**Knowledge-First (Always Available):**
- Rules, Skills, Prompts = static reference material
- Git submodule-friendly; lightweight
- Manual workflows; no automation dependencies

**Optional Automation (Future Branch):**
- Agents, Commands = LLM-driven review and delegation
- Requires setup in your IDE/tool
- Faster workflows for teams with automation infrastructure

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

### Optional: Agents & Commands

See [agents/README.md](agents/README.md) and [commands/README.md](commands/README.md) for optional execution layers:
- **Agents:** Specialist reviewers (data-reviewer, model-trainer, pipeline-validator)
- **Commands:** Workflow shortcuts (/eda, /validate-data, /evaluate-model)

These are available in the main branch; future `execution-optional` branch will separate them for cleaner consumption.

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
