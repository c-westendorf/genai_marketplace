# Prompt: [Name]

---
version: "1.0.0"
author: "[your-name-or-team]"
category: "[eda|debugging|code-review|validation|feature-engineering|error-diagnosis|general]"
domain: "[ml|analytics|data-eng]"
compatible_with: ["Claude", "Cursor", "VSCode", "Zed", "generic-llm"]
tags: ["tag1", "tag2"]
---

## Purpose

What this prompt accomplishes and when to use it.

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[variable1]` | What this variable represents | `example_value` |
| `[variable2]` | What this variable represents | `example_value` |
| `[variable3]` | What this variable represents | `example_value` |

---

## Prompt

```
[The actual prompt text goes here]

Context:
- [variable1]: Explanation of what to provide
- [variable2]: Explanation of what to provide

Request:
[What you're asking the AI to do]

Constraints:
- Constraint 1
- Constraint 2

Output format:
[Expected format of the response]
```

---

## Example Usage

### Variables Filled In

| Variable | Value |
|----------|-------|
| `[variable1]` | `user_churn_data.csv` |
| `[variable2]` | `predict customer churn` |

### Complete Prompt

```
[The prompt with variables replaced with example values]

Context:
- Dataset: user_churn_data.csv
- Goal: predict customer churn

Request:
[Specific request with filled values]

Constraints:
- Use scikit-learn
- Focus on interpretability

Output format:
- Summary of approach
- Code with comments
- Key metrics to track
```

### Expected Output

Brief description of what the AI should produce in response to this prompt.

---

## Tips for Best Results

- Tip 1 for getting good results
- Tip 2 for getting good results
- Tip 3 for getting good results

---

## Related Prompts

- [Related Prompt 1](./related-prompt.md)
- [Related Prompt 2](../other-category/prompt.md)
