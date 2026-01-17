# Prompt: ML Code Review

**Version:** 1.0.0
**Author:** ml-team
**Category:** code-review

---

## Purpose

Review machine learning code for best practices, potential issues, and production readiness.

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[code_type]` | Type of ML code | `training script`, `inference pipeline`, `feature engineering` |
| `[framework]` | ML framework used | `scikit-learn`, `PyTorch`, `XGBoost` |
| `[deployment_target]` | Where code will run | `batch job`, `real-time API`, `notebook` |

---

## Prompt

```
Review this ML code for best practices and issues.

Context:
- Code type: [code_type]
- Framework: [framework]
- Deployment target: [deployment_target]

Please review for:

1. **Data Leakage**
   - Is data split before preprocessing?
   - Are transformers fit only on training data?
   - Any future information used for past predictions?
   - Target information leaking into features?

2. **Reproducibility**
   - Are random seeds set for all sources?
   - Are package versions pinned?
   - Is configuration logged?
   - Can experiment be reproduced from logs?

3. **Code Quality**
   - Are functions well-documented?
   - Is error handling appropriate?
   - Are magic numbers parameterized?
   - Is code modular and testable?

4. **ML Best Practices**
   - Is cross-validation used properly?
   - Are metrics appropriate for the problem?
   - Is baseline comparison included?
   - Are confidence intervals calculated?

5. **Production Readiness**
   - Is inference code separate from training?
   - Are model artifacts properly serialized?
   - Is there input validation?
   - How are missing values handled at inference?
   - Is monitoring/logging included?

6. **Performance**
   - Are there unnecessary data copies?
   - Is vectorization used where possible?
   - Are batch operations preferred over loops?
   - Memory usage appropriate for data size?

7. **Security**
   - No credentials in code?
   - Inputs sanitized?
   - Model pickle safety considered?

Output format:
- Summary: Overall assessment (Ready / Needs Work / Major Issues)
- Categorized issues with severity (Critical / High / Medium / Low)
- Specific code suggestions with before/after
- Checklist of items to address before deployment
```

---

## Example Usage

### Variables Filled In

| Variable | Value |
|----------|-------|
| `[code_type]` | `training script for churn prediction` |
| `[framework]` | `scikit-learn with XGBoost` |
| `[deployment_target]` | `weekly batch prediction job` |

### Complete Prompt

```
Review this ML code for best practices and issues.

Context:
- Code type: training script for churn prediction
- Framework: scikit-learn with XGBoost
- Deployment target: weekly batch prediction job

[PASTE CODE HERE]

Please review for:

1. **Data Leakage**
   ... [rest of prompt]
```

### Expected Output

**Summary:** Needs Work - 2 critical issues, 4 medium issues

**Critical Issues:**

1. **Data Leakage** (Line 45)
   ```python
   # Before (BAD)
   scaler = StandardScaler()
   X_scaled = scaler.fit_transform(X)  # Fit on all data
   X_train, X_test = train_test_split(X_scaled, y)

   # After (GOOD)
   X_train, X_test = train_test_split(X, y)
   scaler = StandardScaler()
   X_train_scaled = scaler.fit_transform(X_train)  # Fit only on train
   X_test_scaled = scaler.transform(X_test)
   ```

2. **No random seed** (Missing)
   ```python
   # Add at top of script
   import random
   import numpy as np
   random.seed(42)
   np.random.seed(42)
   ```

**Pre-Deployment Checklist:**
- [ ] Fix data leakage in preprocessing
- [ ] Add random seeds
- [ ] Add input validation for inference
- [ ] Add logging for monitoring
- [ ] Create requirements.txt with pinned versions

---

## Tips for Best Results

- Include the full code file or relevant sections
- Specify production requirements (latency, scale)
- Mention any known issues or concerns
- Include information about data characteristics

---

## Related Prompts

- [Model Performance Debug](../debugging/model-performance.md)
