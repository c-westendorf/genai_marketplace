# Prompt: Correlation Analysis

**Version:** 1.0.0
**Author:** analytics-team
**Category:** eda

---

## Purpose

Analyze relationships between variables to identify multicollinearity, predictive features, and potential data issues.

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[numeric_columns]` | Numeric columns to analyze | `all` or `col1, col2, col3` |
| `[target_column]` | Target variable | `conversion` |
| `[correlation_threshold]` | Threshold for flagging high correlation | `0.7` |

---

## Prompt

```
Analyze correlations between [numeric_columns] with focus on [target_column].

Parameters:
- High correlation threshold: [correlation_threshold]

Please provide:

1. **Correlation Matrix**
   - Full correlation matrix for numeric variables
   - Highlight correlations above threshold
   - Use appropriate method (Pearson for linear, Spearman for monotonic)

2. **Target Correlations**
   - Rank features by correlation with target
   - Statistical significance (p-values)
   - Identify top positive and negative predictors

3. **Multicollinearity Check**
   - Pairs with correlation > threshold
   - Variance Inflation Factor (VIF) for each variable
   - Recommendations for feature removal

4. **Categorical-Numeric Relationships**
   - Point-biserial correlation for binary categoricals
   - ANOVA F-statistic for multi-class categoricals
   - Identify strong categorical predictors

5. **Visualization**
   - Correlation heatmap
   - Scatter plots for top correlated pairs
   - Pair plot for most important features

6. **Recommendations**
   - Features to keep/remove for modeling
   - Potential feature combinations
   - Warning flags for suspiciously high correlations

Output format:
- Ranked list of target correlations with significance
- Table of highly correlated pairs with recommendations
- Python code for analysis reproduction
```

---

## Example Usage

### Variables Filled In

| Variable | Value |
|----------|-------|
| `[numeric_columns]` | `all` |
| `[target_column]` | `price` |
| `[correlation_threshold]` | `0.7` |

### Complete Prompt

```
Analyze correlations between all numeric columns with focus on price.

Parameters:
- High correlation threshold: 0.7

Please provide:

1. **Correlation Matrix**
   - Full correlation matrix for numeric variables
   ... [rest of prompt]
```

### Expected Output

**Top Target Correlations:**
| Feature | Correlation | p-value | Significance |
|---------|-------------|---------|--------------|
| sqft | 0.72 | <0.001 | *** |
| bedrooms | 0.58 | <0.001 | *** |
| age | -0.34 | <0.001 | *** |

**Multicollinearity Warnings:**
| Pair | Correlation | Recommendation |
|------|-------------|----------------|
| sqft, rooms | 0.89 | Remove rooms |
| bath_full, bath_total | 0.95 | Remove bath_total |

---

## Tips for Best Results

- Set appropriate threshold based on use case (stricter for fewer features)
- Use Spearman correlation for ordinal data or non-linear relationships
- Run before feature engineering to understand raw relationships

---

## Related Prompts

- [Distribution Analysis](./distribution-analysis.md)
- [Initial Exploration](./initial-exploration.md)
