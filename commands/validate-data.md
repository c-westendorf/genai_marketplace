---
description: Validate data pipeline or transformation code for quality, integrity, and reliability. Invoke the data-reviewer agent to assess schema, transformations, and data quality.
compatible_with: ["Claude", "Cursor", "generic-llm"]
---

# /validate-data Command

This command invokes the **data-reviewer** agent to validate data pipeline code, transformations, and outputs.

## What This Command Does

1. **Schema Validation** - Check data types, nullability, and relationships
2. **Transformation Review** - Verify logic, identify data loss or edge cases
3. **Quality Checks** - Detect nulls, duplicates, outliers, invalid values
4. **Pipeline Assessment** - Validate error handling and recovery
5. **Approval Decision** - Flag critical issues or approve for production

## When to Use

Use `/validate-data` when:
- Before running transformations in production
- After implementing new data pipeline stages
- When data quality issues appear downstream
- During code review for data engineering changes

## How It Works

The data-reviewer agent will:

1. Ask for pipeline or transformation code
2. Review schema and data type definitions
3. Check transformation logic and data flow
4. Identify quality gates or validation logic
5. Flag missing error handling
6. Provide approval or list critical issues

## Example Usage

```
User: /validate-data

Agent: I'll review your data pipeline for quality and reliability.

**What would you like me to validate?**
1. Share the transformation SQL or code
2. Describe the input data schema
3. Explain the expected output

I'll then check:
- Schema correctness and constraints
- Data integrity and transformations
- Quality validation logic
- Error handling and recovery
- Edge cases and failure modes
```

## Output

After running `/validate-data`, you'll get:

- **Schema Review** - Type correctness, constraints, nullable fields
- **Transformation Analysis** - Logic correctness, data loss assessment
- **Quality Issues** - Nulls, duplicates, outliers that need handling
- **Error Handling** - What happens when validation fails
- **Approval Status**:
  - ✅ **Approve** - No critical issues; ready for production
  - ⚠️ **Warning** - Quality concerns; recommend investigation
  - ❌ **Block** - Critical issues; don't run in production yet

## Related Skills

- [data-qa-checklist.md](../skills/data-qa-checklist.md) - Quality assurance checklist
- [eda-workflow.md](../skills/eda-workflow.md) - EDA workflow

## Related Agents

- [pipeline-validator.md](../agents/pipeline-validator.md) - For orchestration and infrastructure
