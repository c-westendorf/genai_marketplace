# Contributing to Cursor Marketplace

Thank you for contributing to the shared marketplace! This guide explains how to submit rules, skills, and prompts.

---

## Before Contributing

### Check If It Belongs

Ask yourself:
- Is this knowledge stable for 6+ months?
- Does it apply broadly across teams?
- Will multiple teams benefit?

If answers are "no," consider keeping it in your project's local rules instead.

### Check If It Exists

1. Search existing rules, skills, and prompts
2. Check for similar resources
3. Consider enhancing existing vs. creating new

---

## Submission Process

### 1. Fork and Clone

```bash
git clone https://github.com/your-fork/cursor-marketplace.git
cd cursor-marketplace
git checkout -b add-my-contribution
```

### 2. Create Your Resource

Use the appropriate template:

```bash
# For rules
cp templates/rule-template.mdc rules/[domain]/my-rule.mdc

# For skills
cp templates/skill-template.md skills/my-skill.md

# For prompts
cp templates/prompt-template.md prompts/[category]/my-prompt.md
```

### 3. Write Content

Follow quality standards below.

### 4. Validate Locally

```bash
# Run validation
npm run validate

# Or manually check
npm run lint:yaml
npm run lint:markdown
npm run spellcheck
```

### 5. Submit Pull Request

```bash
git add .
git commit -m "Add [type]: [name]"
git push origin add-my-contribution
```

Create PR with:
- Clear title: `Add ML rule: model-training`
- Description of what it does
- Any testing done

---

## Quality Standards

### Rules

| Criterion | Requirement |
|-----------|-------------|
| Description | Under 100 characters, clear purpose |
| Length | Under 300 lines |
| Examples | Working code included |
| Patterns | Show good AND bad patterns |
| Content | Constraints only, no tutorials |

### Skills

| Criterion | Requirement |
|-----------|-------------|
| Structure | Clear step-by-step with headers |
| Checkpoints | Validation points included |
| Length | Under 500 lines |
| Examples | Concrete examples for each step |

### Prompts

| Criterion | Requirement |
|-----------|-------------|
| Variables | Clearly marked with `[brackets]` |
| Example | Shows actual usage with filled variables |
| Purpose | Clear explanation of when to use |

---

## File Naming

- Use lowercase with hyphens: `model-training.mdc`
- Be descriptive but concise
- Match the resource purpose

---

## Frontmatter Requirements

### Rules

```yaml
---
description: Clear, brief description (under 100 chars)
globs: "**/*.py"  # Optional, for auto-attach
alwaysApply: false
version: "1.0.0"
author: "your-name-or-team"
category: "ml"  # ml, analytics, data-eng, general
tags: ["training", "evaluation"]
---
```

### Skills & Prompts

Include metadata in markdown:
```markdown
# Skill Name

**Version:** 1.0.0
**Author:** your-name-or-team
**Category:** ml
```

---

## Review Process

1. **Automated checks** run on PR (CI/CD)
2. **Domain reviewer** checks technical accuracy
3. **Governance reviewer** checks standards compliance
4. **Merge** after 2 approvals

### Timeline

| Stage | Expected Time |
|-------|---------------|
| Automated checks | Minutes |
| First reviewer | 3-5 business days |
| Second reviewer | 2-3 business days |
| Merge | Same day as approval |

---

## Updating Existing Resources

1. Increment version number appropriately
2. Document changes in PR description
3. Follow same review process

### Version Bumps

- **Major** (1.0.0 → 2.0.0): Breaking behavior changes
- **Minor** (1.0.0 → 1.1.0): New guidance, backward compatible
- **Patch** (1.0.0 → 1.0.1): Fixes, clarifications

---

## Questions?

- Open an issue for questions
- Tag marketplace maintainers for guidance
- Check existing PRs for examples
