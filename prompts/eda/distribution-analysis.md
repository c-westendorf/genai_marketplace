# Prompt: Distribution Analysis

**Version:** 1.0.0
**Author:** analytics-team
**Category:** eda

---

## Purpose

Analyze the distributions of key variables to understand data characteristics and identify transformation needs.

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[columns]` | Columns to analyze | `age, income, transaction_amount` |
| `[target_column]` | Target variable for comparison | `is_churned` |
| `[visualization]` | Whether to include plots | `yes` or `no` |

---

## Prompt

```
Analyze the distributions of [columns] in the dataset.

Context:
- Target variable for comparison: [target_column]
- Include visualizations: [visualization]

Please provide:

1. **Univariate Analysis** (for each column)
   - Distribution type (normal, skewed, bimodal, uniform)
   - Central tendency (mean, median, mode)
   - Spread (std, IQR, range)
   - Skewness and kurtosis values
   - Outlier detection (IQR method)

2. **Visual Analysis** (if requested)
   - Histograms with kernel density estimate
   - Box plots showing quartiles and outliers
   - Q-Q plots for normality assessment

3. **Distribution by Target** (if target provided)
   - Compare distributions between target classes
   - Statistical test for difference (t-test, Mann-Whitney)
   - Effect size calculation

4. **Transformation Recommendations**
   - Suggest transformations for skewed variables
   - Recommend scaling approach
   - Note variables that may need binning

5. **Code Snippets**
   - Python code to reproduce analysis
   - Functions for applying recommended transformations

Output format:
- Table summarizing distribution statistics
- Interpretation of each distribution
- Specific transformation recommendations with rationale
```

---

## Example Usage

### Variables Filled In

| Variable | Value |
|----------|-------|
| `[columns]` | `annual_income, credit_score, account_age_months` |
| `[target_column]` | `default` |
| `[visualization]` | `yes` |

### Complete Prompt

```
Analyze the distributions of annual_income, credit_score, account_age_months in the dataset.

Context:
- Target variable for comparison: default
- Include visualizations: yes

Please provide:

1. **Univariate Analysis** (for each column)
   - Distribution type (normal, skewed, bimodal, uniform)
   - Central tendency (mean, median, mode)
   ... [rest of prompt]
```

### Expected Output

| Column | Type | Skewness | Outliers | Recommendation |
|--------|------|----------|----------|----------------|
| annual_income | Right-skewed | 2.3 | 5% | Log transform |
| credit_score | Normal | 0.1 | 2% | Standard scale |
| account_age_months | Right-skewed | 1.8 | 3% | Log transform |

Plus visualizations and code for transformations.

---

## Tips for Best Results

- Limit to 5-10 columns at a time for detailed analysis
- Always include the target for predictive modeling contexts
- Request visualizations for presentation-ready outputs

---

## Related Prompts

- [Initial Exploration](./initial-exploration.md)
- [Correlation Check](./correlation-check.md)
