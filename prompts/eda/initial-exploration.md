# Prompt: Initial Data Exploration

**Version:** 1.0.0
**Author:** analytics-team
**Category:** eda

---

## Purpose

Get a comprehensive first look at a new dataset with key statistics and quality indicators.

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[dataset_name]` | Name or path of the dataset | `sales_data.csv` |
| `[target_column]` | Target variable for analysis (optional) | `churn` |
| `[id_column]` | Primary key column (optional) | `customer_id` |
| `[date_column]` | Main date column (optional) | `transaction_date` |

---

## Prompt

```
Perform an initial exploration of [dataset_name].

Context:
- Target variable (if applicable): [target_column]
- ID column: [id_column]
- Date column: [date_column]

Please provide:

1. **Data Overview**
   - Shape (rows × columns)
   - Column names and data types
   - Memory usage

2. **Missing Data Analysis**
   - Null counts and percentages per column
   - Pattern of missing data (random vs systematic)

3. **Numeric Summary**
   - For each numeric column: min, max, mean, median, std
   - Identify potential outliers (>3 std from mean)
   - Note any skewed distributions

4. **Categorical Summary**
   - Unique value counts per categorical column
   - Top 5 most frequent values for each
   - Identify high-cardinality columns (>50 unique values)

5. **Target Analysis** (if provided)
   - Distribution of target variable
   - Class balance for classification
   - Basic statistics for regression

6. **Time Analysis** (if date column provided)
   - Date range
   - Gaps in data
   - Records per time period

7. **Data Quality Flags**
   - Potential issues identified
   - Columns needing attention
   - Recommended next steps

Output format:
- Use clear headers for each section
- Include code snippets for key findings
- Highlight any concerning patterns with ⚠️
```

---

## Example Usage

### Variables Filled In

| Variable | Value |
|----------|-------|
| `[dataset_name]` | `customer_transactions.parquet` |
| `[target_column]` | `is_churned` |
| `[id_column]` | `customer_id` |
| `[date_column]` | `transaction_date` |

### Complete Prompt

```
Perform an initial exploration of customer_transactions.parquet.

Context:
- Target variable (if applicable): is_churned
- ID column: customer_id
- Date column: transaction_date

Please provide:

1. **Data Overview**
   - Shape (rows × columns)
   - Column names and data types
   - Memory usage

2. **Missing Data Analysis**
   - Null counts and percentages per column
   - Pattern of missing data (random vs systematic)

... [rest of prompt]
```

### Expected Output

A structured report covering all seven sections with:
- Summary statistics
- Code to reproduce findings
- Flagged issues requiring attention
- Clear next steps for deeper analysis

---

## Tips for Best Results

- Always specify the target column if analysis has a predictive goal
- Include the date column for time-series data to get temporal analysis
- Provide context about what the data represents in your initial message

---

## Related Prompts

- [Distribution Analysis](./distribution-analysis.md)
- [Correlation Check](./correlation-check.md)
