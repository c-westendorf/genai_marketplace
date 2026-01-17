# Cursor Marketplace

A curated collection of Cursor rules, skills, and prompts for data science and analytics teams.

---

## Overview

This repository contains shared resources that can be consumed across projects via git submodules.

### What's Included

| Category | Count | Description |
|----------|-------|-------------|
| [Rules](rules/) | 12 | Persistent AI instructions by domain |
| [Skills](skills/) | 5 | Workflow guides with steps and checkpoints |
| [Prompts](prompts/) | 6 | Reusable prompt templates |
| [Templates](templates/) | 3 | Starter templates for contributions |

---

## Quick Start

### Add to Your Project

```bash
# Add marketplace as git submodule
git submodule add https://github.com/org/cursor-marketplace .cursor/shared

# Initialize (for cloned repos)
git submodule init
git submodule update
```

### Use Resources

**Rules:** Copy to your `.cursor/rules/` directory or reference from shared location.

```bash
# Copy a rule
cp .cursor/shared/rules/ml/model-training.mdc .cursor/rules/

# Or symlink for automatic updates
ln -s ../shared/rules/ml/model-training.mdc .cursor/rules/
```

**Skills & Prompts:** Reference in conversations using `@` syntax after adding to rules.

### Update to Latest

```bash
git submodule update --remote
```

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

### Skills

- [data-qa-checklist.md](skills/data-qa-checklist.md) - Data quality assurance
- [model-evaluation-protocol.md](skills/model-evaluation-protocol.md) - Model evaluation workflow
- [eda-workflow.md](skills/eda-workflow.md) - Exploratory data analysis
- [feature-engineering.md](skills/feature-engineering.md) - Feature creation guide
- [error-analysis.md](skills/error-analysis.md) - Model error analysis

### Prompts

**EDA** (`prompts/eda/`)
- [initial-exploration.md](prompts/eda/initial-exploration.md)
- [distribution-analysis.md](prompts/eda/distribution-analysis.md)
- [correlation-check.md](prompts/eda/correlation-check.md)

**Debugging** (`prompts/debugging/`)
- [model-performance.md](prompts/debugging/model-performance.md)
- [data-quality-issues.md](prompts/debugging/data-quality-issues.md)

**Code Review** (`prompts/code-review/`)
- [ml-code-review.md](prompts/code-review/ml-code-review.md)

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
