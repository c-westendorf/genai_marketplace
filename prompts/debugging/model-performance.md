# Prompt: Debug Model Performance

**Version:** 1.0.0
**Author:** ml-team
**Category:** debugging

---

## Purpose

Systematically diagnose why a model is underperforming and identify improvement strategies.

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[model_type]` | Type of model | `XGBoost classifier` |
| `[current_metric]` | Current performance | `F1: 0.65` |
| `[target_metric]` | Target performance | `F1: 0.80` |
| `[problem_type]` | Classification or regression | `classification` |

---

## Prompt

```
Help debug why my [model_type] is underperforming.

Current state:
- Model type: [model_type]
- Problem: [problem_type]
- Current performance: [current_metric]
- Target performance: [target_metric]
- Gap to close: [target_metric] - [current_metric]

Please help diagnose and fix by checking:

1. **Data Quality Issues**
   - Check for data leakage (features too correlated with target)
   - Verify train/test split is proper
   - Look for label noise or errors
   - Check class imbalance
   - Review feature distributions train vs test

2. **Feature Issues**
   - Analyze feature importance
   - Check for redundant features
   - Look for missing signal (important features not included)
   - Verify feature engineering is correct
   - Check for data type issues

3. **Model Issues**
   - Is the model underfitting? (training score also low)
   - Is the model overfitting? (large train-test gap)
   - Are hyperparameters reasonable?
   - Is model complexity appropriate for data size?

4. **Evaluation Issues**
   - Is the metric appropriate for the problem?
   - Are cross-validation folds reasonable?
   - Is baseline comparison fair?

5. **Diagnostic Code**
   - Learning curves to diagnose bias/variance
   - Confusion matrix analysis
   - Error sample analysis
   - Feature importance plot

6. **Recommended Fixes**
   - Prioritized list of things to try
   - Expected impact of each fix
   - Implementation code snippets

Output format:
- Diagnostic checklist with findings
- Root cause hypothesis
- Prioritized action items with code
```

---

## Example Usage

### Variables Filled In

| Variable | Value |
|----------|-------|
| `[model_type]` | `Random Forest classifier` |
| `[current_metric]` | `ROC-AUC: 0.72` |
| `[target_metric]` | `ROC-AUC: 0.85` |
| `[problem_type]` | `binary classification (churn prediction)` |

### Complete Prompt

```
Help debug why my Random Forest classifier is underperforming.

Current state:
- Model type: Random Forest classifier
- Problem: binary classification (churn prediction)
- Current performance: ROC-AUC: 0.72
- Target performance: ROC-AUC: 0.85
- Gap to close: 0.13

Please help diagnose and fix by checking:

1. **Data Quality Issues**
   ... [rest of prompt]
```

### Expected Output

**Diagnostic Findings:**

| Check | Status | Finding |
|-------|--------|---------|
| Data leakage | ✅ OK | No suspicious correlations |
| Train/test split | ⚠️ Issue | Test set has different date range |
| Class imbalance | ⚠️ Issue | 95% negative class |
| Overfitting | ✅ OK | Train AUC 0.75, Test 0.72 |

**Root Cause Hypothesis:**
Class imbalance is likely the main issue. The model is biased toward majority class.

**Recommended Fixes:**
1. Apply SMOTE oversampling (expected: +5-8% AUC)
2. Adjust class weights (expected: +3-5% AUC)
3. Try threshold optimization (expected: +2-3% F1)

---

## Tips for Best Results

- Include train and test metrics to diagnose overfitting
- Provide confusion matrix if available
- Share feature importance if already computed
- Mention any constraints (latency, interpretability)

---

## Related Prompts

- [Data Quality Issues](./data-quality-issues.md)
