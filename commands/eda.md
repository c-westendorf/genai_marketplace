---
description: Run exploratory data analysis on a new dataset. Invoke the data-reviewer agent to guide analysis through initial exploration, distribution analysis, and correlation checking.
compatible_with: ["Claude", "Cursor", "generic-llm"]
---

# /eda Command

This command invokes the **data-reviewer** agent to guide you through exploratory data analysis of a new dataset.

## What This Command Does

1. **Load & Profile** - Understand shape, types, missing values
2. **Explore Distributions** - Analyze individual column distributions and outliers
3. **Check Relationships** - Find correlations and associations between variables
4. **Identify Issues** - Surface data quality concerns early
5. **Create Plan** - Recommend next steps for cleaning or feature engineering

## When to Use

Use `/eda` when:
- Starting analysis on a new dataset
- Onboarding to a data source you haven't worked with
- Investigating unexpected results in downstream analysis
- Preparing data for modeling

## How It Works

The data-reviewer agent will:

1. Ask you for dataset location and basic info (rows, columns, purpose)
2. Guide you through profiling the data
3. Suggest distribution analyses based on data types
4. Help identify relationships and patterns
5. Flag data quality issues that need addressing
6. Create an analysis plan to share with the team

## Example Usage

```
User: /eda

Agent: Let's analyze your dataset step by step.

**Step 1: Profile the Dataset**
What's the dataset location and basic info?
- File path or table name
- Approximate number of rows
- What's the business purpose?

Once I know, I'll help you:
1. Load and examine structure
2. Check for missing values and data types
3. Identify outliers and distribution shapes
4. Find correlations
5. Create a data quality report
```

## Output

After running `/eda`, you'll get:

- **Dataset Profile** - Shape, dtypes, memory usage
- **Missing Value Analysis** - Nulls by column and potential causes
- **Distribution Analysis** - Key statistics and visualization recommendations
- **Correlation Matrix** - Numeric relationships
- **Data Quality Issues** - Flags for investigation
- **Recommended Next Steps** - Cleaning, feature engineering, or modeling directions

## Related Skills

- [eda-workflow.md](../skills/eda-workflow.md) - Structured EDA process
- [data-qa-checklist.md](../skills/data-qa-checklist.md) - Quality assurance checklist
