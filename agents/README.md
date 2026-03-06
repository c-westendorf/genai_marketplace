# Agents Index

Specialized task delegators for data science and ML workflows. **Optional execution layer** for teams using LLM-driven automation.

> **Phase 2 Notice:** In Phase 2, agents will move to the [`execution-optional` branch](https://github.com/your-org/cursor-marketplace/tree/execution-optional) for cleaner separation. For now, they're on main branch as reference.

## Available Agents

### data-reviewer
**Expert in data quality and validation**

Reviews data pipelines, schemas, and outputs for quality, integrity, and correctness. Use after implementing data transformations or loading new datasets.

- **Role:** Data quality specialist
- **Use When:** Validating pipelines, checking data quality, auditing transformations
- **Related Command:** [`/validate-data`](../commands/validate-data.md)
- **Related Skills:** [data-qa-checklist](../skills/data-qa-checklist.md)

### model-trainer
**Expert in ML model training and validation**

Reviews model training code, hyperparameter choices, and validation strategies. Ensures reproducibility, best practices, and risk mitigation.

- **Role:** ML engineering specialist
- **Use When:** Training models, reviewing training code, validating evaluation strategy
- **Related Command:** [`/evaluate-model`](../commands/evaluate-model.md)
- **Related Skills:** [model-evaluation-protocol](../skills/model-evaluation-protocol.md)

### pipeline-validator
**Expert in data pipeline architecture**

Reviews pipeline design, orchestration, failure handling, and monitoring. Ensures reliability, scalability, and operational health.

- **Role:** Data engineering specialist
- **Use When:** Designing pipelines, reviewing DAG/orchestration code, ensuring reliability
- **Related Command:** `/validate-pipeline` (coming)
- **Related Skills:** *coming*

---

## Using Agents

Agents are triggered through **commands** or by direct invocation in your AI tool.

### In Cursor
```
@data-reviewer
I just implemented a new customer orders transformation. Can you review it?
```

### In Claude Code
Use the agent name directly when asking for review:
```
@data-reviewer
Review this transformation for data quality issues...
```

### Generic LLM Usage
Reference the agent in your prompt:
```
Using the data-reviewer agent, review this SQL transformation for quality issues:
[paste SQL code]
```

---

## How Agents Work

Each agent has:

1. **Role Definition** - What the agent specializes in
2. **Process** - Step-by-step approach to reviewing
3. **Checklist** - Specific items to validate
4. **Approval Criteria** - Decision framework (Approve/Warning/Block)
5. **Domain-Specific Guidance** - Specialized checks by problem type

Agents provide structured, repeatable reviews using consistent frameworks.

---

## When to Use Agents vs. Manual Review

| Situation | Use Agent? | Why |
|-----------|-----------|-----|
| Quick validation before running code | ✅ Yes | Fast, systematic review |
| Complex pipeline with many edge cases | ✅ Yes | Catches issues you might miss |
| PR code review by humans | ❓ Maybe | Agents as first pass, human reviewers for context |
| Exploratory notebook work | ❌ No | Too much overhead for experimental code |
| Debugging a failing pipeline | ✅ Yes | Systematic issue identification |

---

## Philosophy: Knowledge-First + Optional Automation

This marketplace separates **knowledge** (rules, skills, prompts—lightweight, always-on) from **execution** (agents, commands, hooks—optional, for automation-ready teams).

- **Main Branch:** Rules, skills, prompts (distributed via git submodule)
- **Optional Branch:** Agents, commands, hooks (check out `execution-optional` if you want automation)

This keeps the core lightweight while enabling advanced workflows for teams that want them.

---

## Contributing

See [../CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on adding new agents.

## Related

- [Commands Index](../commands/README.md) - Slash-command shortcuts that invoke agents
- [Skills Index](../skills/README.md) - Workflow guides for manual execution
