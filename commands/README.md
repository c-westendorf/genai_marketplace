# Commands Index

Slash-command shortcuts for common data workflows. **Optional execution layer** for teams using LLM-driven automation.

> **Phase 2 Notice:** In Phase 2, commands will move to the [`execution-optional` branch](https://github.com/your-org/cursor-marketplace/tree/execution-optional) for cleaner separation. For now, they're on main branch as reference.

## Available Commands

### /eda
**Exploratory Data Analysis**

Run exploratory data analysis on a new dataset. Invokes the data-reviewer agent to guide analysis through initial exploration, distribution analysis, and correlation checking.

- **Trigger:** Starting analysis on new dataset
- **Agent Used:** [`data-reviewer`](../agents/data-reviewer.md)
- **Output:** Profile, distributions, correlations, quality issues
- **Related Skill:** [eda-workflow](../skills/eda-workflow.md)

### /validate-data
**Data Pipeline Validation**

Validate data pipeline or transformation code for quality, integrity, and reliability. Invokes the data-reviewer agent to assess schema, transformations, and data quality.

- **Trigger:** Before running transformations in production
- **Agent Used:** [`data-reviewer`](../agents/data-reviewer.md)
- **Output:** Approval status, issues list, recommendations
- **Related Skill:** [data-qa-checklist](../skills/data-qa-checklist.md)

### /evaluate-model
**Model Evaluation & Validation**

Evaluate model performance, validation strategy, and training rigor. Invokes the model-trainer agent to assess model selection, hyperparameters, and reproducibility.

- **Trigger:** After model training, before deployment
- **Agent Used:** [`model-trainer`](../agents/model-trainer.md)
- **Output:** Training rigor assessment, evaluation quality, approval status
- **Related Skill:** [model-evaluation-protocol](../skills/model-evaluation-protocol.md)

### /validate-pipeline (Coming Soon)
**Pipeline Architecture & Reliability**

Validate data pipeline design, orchestration, and failure handling. Invokes the pipeline-validator agent to ensure reliability and scalability.

- **Trigger:** Designing or reviewing complex pipelines
- **Agent Used:** [`pipeline-validator`](../agents/pipeline-validator.md)
- **Output:** Architecture review, reliability assessment, SLA recommendations

---

## Using Commands

### In Cursor
Type the command at the start of your message:

```
/eda

I just loaded customer_orders.csv. Can you help me explore it?
```

### In Claude Code
Use the command syntax followed by your context:

```
/validate-data

Here's the SQL transformation I wrote:
[paste SQL]
```

### Generic LLM
Reference the command in your message:

```
Following the /eda command workflow:
[describe your dataset]
```

---

## Command Workflow

Each command:

1. **Defines Purpose** - What the command accomplishes
2. **Triggers Agent** - Invokes specialized agent with context
3. **Guides Process** - Step-by-step workflow
4. **Produces Output** - Structured results (profile, approval, recommendations)

Commands are shortcuts for common workflows; the same work can be done manually using related skills and agents.

---

## When to Use Commands

| Situation | Use Command? | Alternative |
|-----------|--------------|-------------|
| First time analyzing a dataset | ✅ Yes | Or use [eda-workflow](../skills/eda-workflow.md) skill manually |
| Validating transformation before production | ✅ Yes | Or invite data-reviewer agent directly |
| Debugging why a model performs poorly | ✅ Yes | Or follow [model-evaluation-protocol](../skills/model-evaluation-protocol.md) |
| Exploratory notebook work | ❌ No | Use skills instead; commands are for structured validation |
| Quick syntax question | ❌ No | Ask directly; commands are for full workflows |

---

## Philosophy: Knowledge-First + Optional Automation

Commands are **workflow shortcuts** that combine agents (who reviews) + skills (what to check).

- **Skills** = "Here's how to do X manually" (always available)
- **Commands** = "Let an agent guide you through X" (optional automation)

Both achieve the same goal; commands are faster for repeated workflows.

---

## Contributing

See [../CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding new commands.

## Related

- [Agents Index](../agents/README.md) - Specialist reviewers that commands invoke
- [Skills Index](../skills/README.md) - Manual workflow guides
