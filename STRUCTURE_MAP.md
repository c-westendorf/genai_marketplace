---
title: Cursor Marketplace Structure Map
version: 1.0.0
created: 2026-01-19
---

# Cursor Marketplace Structure Map

Visual guide to the reorganized marketplace.

## Directory Structure

```
cursor-marketplace/
│
├── README.md                          ← Start here: overview, quick start, roadmap
├── IMPLEMENTATION_SUMMARY.md          ← What was built and why (Phase 1 complete)
├── EXECUTION_SETUP.md                 ← (on execution-optional branch) Setup guide for agents/commands
│
├── rules/                             ← Always-on constraints organized by domain
│   ├── analytics/                     ← 4 rules for analytics workflows
│   │   ├── dashboard-standards.mdc
│   │   ├── data-validation.mdc
│   │   ├── reporting-quality.mdc
│   │   └── sql-safety.mdc
│   ├── data-eng/                      ← 3 rules for data engineering workflows
│   │   ├── logging-requirements.mdc
│   │   ├── pipeline-standards.mdc
│   │   └── schema-validation.mdc
│   └── ml/                            ← 5 rules for ML workflows
│       ├── data-leakage-prevention.mdc
│       ├── evaluation-metrics.mdc
│       ├── hyperparameter-tuning.mdc
│       ├── model-training.mdc
│       └── reproducibility.mdc
│
├── skills/                            ← Manual workflow guides organized by domain
│   ├── README.md                      ← Index of all skills
│   ├── [general skills at root]
│   │   ├── data-qa-checklist.md       ← Data quality assurance (all domains)
│   │   ├── eda-workflow.md            ← Exploratory data analysis process
│   │   ├── error-analysis.md          ← Error investigation (all domains)
│   │   └── feature-engineering.md     ← Feature creation for ML
│   ├── analytics/                     ← (Coming) Analytics-specific skills
│   ├── data-eng/                      ← (Coming) Data engineering skills
│   └── ml/
│       └── model-evaluation-protocol.md ← Structured ML evaluation workflow
│
├── prompts/                           ← Reusable prompt templates organized by domain
│   ├── README.md                      ← Index of all prompts
│   ├── code-review/
│   │   └── ml-code-review.md
│   ├── debugging/
│   │   ├── data-quality-issues.md
│   │   └── model-performance.md
│   ├── eda/
│   │   ├── correlation-check.md
│   │   ├── distribution-analysis.md
│   │   └── initial-exploration.md
│   ├── analytics/                     ← (Coming) Analytics-specific prompts
│   ├── data-eng/                      ← (Coming) Data engineering prompts
│   └── ml/                            ← (Coming) ML-specific prompts
│
├── agents/                            ← Optional: Specialist reviewers (move to execution-optional in Phase 2)
│   ├── README.md                      ← How to use agents, when to invoke
│   ├── data-reviewer.md               ← Data quality & validation specialist
│   │                                     ├─ Role: Validate data pipelines, schemas, quality
│   │                                     └─ Use: @data-reviewer for pipeline reviews
│   ├── model-trainer.md               ← ML training & validation specialist
│   │                                     ├─ Role: Review training code, hyperparameters, evaluation
│   │                                     └─ Use: @model-trainer for training reviews
│   └── pipeline-validator.md          ← Pipeline architecture specialist
│                                         ├─ Role: Validate orchestration, reliability, scalability
│                                         └─ Use: @pipeline-validator for architecture reviews
│
├── commands/                          ← Optional: Workflow shortcuts (move to execution-optional in Phase 2)
│   ├── README.md                      ← How to use commands, when to trigger
│   ├── eda.md                         ← /eda: Exploratory data analysis (invokes data-reviewer)
│   ├── validate-data.md               ← /validate-data: Data validation (invokes data-reviewer)
│   └── evaluate-model.md              ← /evaluate-model: Model evaluation (invokes model-trainer)
│
├── templates/                         ← Starter templates for contributions
│   ├── rule-template.mdc              ← Create new rules from this template
│   ├── skill-template.md              ← Create new skills from this template
│   └── prompt-template.md             ← Create new prompts from this template
│
├── CONTRIBUTING.md                    ← Guidelines for adding new rules/skills/prompts
│
└── claude/                            ← Reference folder (everything-claude-code source)
    ├── agents/                        ← Reference: 9 general software engineering agents
    ├── commands/                      ← Reference: 10 general software engineering commands
    ├── rules/                         ← Reference: 8 general software engineering rules
    ├── skills/                        ← Reference: 7+ general software engineering skills
    └── [other config files]           ← Reference: MCP, hooks, examples
```

---

## Branch Strategy

### Main Branch: Knowledge-First Core
```
/main
├── rules/                 (12 rules)
├── skills/                (5+ skills)
├── prompts/               (6+ prompts)
├── agents/                (3 agents - reference)
├── commands/              (3 commands - reference)
├── templates/             (3 templates)
└── README.md
```

**Use Case:** Teams who want static knowledge reference material
- No agent setup required
- Perfect for git submodule consumption
- Lightweight distribution
- Manual workflows using skills

### Execution-Optional Branch: Automation Layer
```
/execution-optional
├── Same as main
├── EXECUTION_SETUP.md     (New: IDE setup guide)
├── hooks/                 (Future: automation triggers)
└── integrations/          (Future: MCP configs)
```

**Use Case:** Teams who want LLM-driven automation
- Agents for code/data review
- Commands for guided workflows
- Setup required per IDE/tool
- Requires LLM integration

---

## Domain Organization

### Data Domains (Consistent Across Rules, Skills, Prompts)

```
Machine Learning (ml/)
├── Rules: model-training, evaluation-metrics, hyperparameter-tuning, data-leakage-prevention, reproducibility
├── Skills: model-evaluation-protocol, (feature-engineering)
└── Prompts: (coming)

Analytics (analytics/)
├── Rules: sql-safety, data-validation, dashboard-standards, reporting-quality
├── Skills: (coming)
└── Prompts: (coming)

Data Engineering (data-eng/)
├── Rules: pipeline-standards, schema-validation, logging-requirements
├── Skills: feature-engineering, (pipeline-reliability)
└── Prompts: (coming)

General / Multi-Domain
├── Rules: (none - kept domain-specific)
├── Skills: data-qa-checklist, eda-workflow, error-analysis
└── Prompts: eda/, debugging/, code-review/
```

---

## File Metadata (New)

All content files now include YAML frontmatter:

### Rule Template
```yaml
---
description: [Brief description]
globs: "**/*.py"
alwaysApply: false
version: "1.0.0"
author: "[team-name]"
category: "[ml|analytics|data-eng|general]"
domain: "[ml|analytics|data-eng]"
compatible_with: ["Claude", "Cursor", "VSCode", "Zed", "generic-llm"]
tags: ["tag1", "tag2"]
---
```

### Skill Template
```yaml
---
version: "1.0.0"
author: "[team-name]"
category: "[ml|analytics|data-eng|general]"
domain: "[ml|analytics|data-eng]"
compatible_with: ["Claude", "Cursor", "VSCode", "Zed", "generic-llm"]
execution_context: "manual"
tags: ["tag1", "tag2"]
---
```

### Prompt Template
```yaml
---
version: "1.0.0"
author: "[team-name]"
category: "[eda|debugging|code-review|validation|feature-engineering|error-diagnosis|general]"
domain: "[ml|analytics|data-eng]"
compatible_with: ["Claude", "Cursor", "VSCode", "Zed", "generic-llm"]
tags: ["tag1", "tag2"]
---
```

---

## Index Files

These README files help navigate the content:

- [rules/](rules/) — Index of 12 rules by domain
- [skills/README.md](skills/README.md) — Index of 5+ skills mapped to domains
- [prompts/README.md](prompts/README.md) — Index of 6+ prompts by use case and domain
- [agents/README.md](agents/README.md) — Index of 3 agents with usage patterns
- [commands/README.md](commands/README.md) — Index of 3 commands with examples

---

## Key Statistics

| Element | Count | Organized By |
|---------|-------|---|
| Rules | 12 | Domain (ml/5, analytics/4, data-eng/3) |
| Skills | 5+ | Domain (most general; ml/1) |
| Prompts | 6+ | Use case (eda, debugging, code-review, etc.) |
| Agents | 3 | Specialty (data, ML, pipelines) |
| Commands | 3 | Workflow (/eda, /validate, /evaluate) |
| Templates | 3 | Content type (rule, skill, prompt) |
| Domains | 3 | Coverage (ML, Analytics, Data Eng) |

---

## Quick Navigation

### "I want to..."

**Learn a new workflow**
→ Browse [skills/README.md](skills/README.md)
→ Follow step-by-step process
→ Use checkpoints to verify

**Use a reusable prompt**
→ Browse [prompts/README.md](prompts/README.md)
→ Copy template
→ Fill in variables

**Review my code/data quickly**
→ Invoke agent: `@data-reviewer`, `@model-trainer`
→ Get structured feedback
→ Apply recommendations

**Get a guided workflow**
→ Use command: `/eda`, `/validate-data`, `/evaluate-model`
→ Follow agent's step-by-step guidance
→ Produce structured output

**Enforce standards**
→ Copy rules to `.cursor/rules/`
→ Enable in IDE
→ Rules automatically applied

**Add new content**
→ Copy template from `templates/`
→ Fill in metadata (domain, compatibility, tags)
→ Follow CONTRIBUTING.md guidelines

---

## Tool Compatibility at a Glance

| Tool | Format | Location | Status |
|------|--------|----------|--------|
| **Cursor** | `.mdc` | `.cursor/rules/` | ✅ Native |
| **Claude Code** | `.md` | Project root | ✅ Works |
| **VSCode** | `.md` | `.vscode/` | ✅ Works |
| **Zed** | `.md` | `.zed/` | ✅ Works |
| **Generic LLM** | `.md` | Any path | ✅ Works |

---

## Phase Progression

```
Phase 1: ✅ COMPLETE
├── Knowledge-first core (rules/skills/prompts)
├── Domain organization (ml/analytics/data-eng)
├── Tool agnosticism (works across IDEs)
├── Optional agents/commands (reference)
└── Branch strategy (main vs execution-optional)

Phase 2: 📋 PLANNED
├── Move agents/commands to execution-optional branch
├── Add hooks for automation triggers
├── Add integrations (Snowflake, BigQuery, dbt, W&B)
└── Full IDE setup documentation

Phase 3: 🔮 FUTURE
├── Domain templates (backend/, frontend/, devops/)
├── Context window management
└── Community contribution process
```

---

## Where to Start

1. **Read:** [README.md](README.md) — 5-minute overview
2. **Browse:** [rules/](rules/), [skills/README.md](skills/README.md), [prompts/README.md](prompts/README.md)
3. **Use:** Copy rules to `.cursor/rules/` or reference in conversations with `@` syntax
4. **Contribute:** See [CONTRIBUTING.md](CONTRIBUTING.md) for adding new content
5. **Automate:** (Optional) Switch to `execution-optional` branch and follow [EXECUTION_SETUP.md](EXECUTION_SETUP.md)

---

**Last Updated:** 2026-01-19
**Branch:** main (knowledge-first)
**Related:** execution-optional (automation-ready)
