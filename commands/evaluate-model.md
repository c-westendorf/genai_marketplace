---
description: Evaluate model performance, validation strategy, and training rigor. Invoke the model-trainer agent to assess model selection, hyperparameters, and reproducibility.
compatible_with: ["Claude", "Cursor", "generic-llm"]
---

# /evaluate-model Command

This command invokes the **model-trainer** agent to review model training code and validate evaluation strategy.

## What This Command Does

1. **Training Rigor** - Check reproducibility, hyperparameter tuning, random seeds
2. **Data Splits** - Validate train/val/test strategy and prevent leakage
3. **Metrics Review** - Ensure metrics appropriate for problem type
4. **Evaluation Strategy** - Verify validation approach is sound
5. **Error Analysis** - Check for investigation of misclassified examples
6. **Approval Decision** - Flag issues or confirm rigorous evaluation

## When to Use

Use `/evaluate-model` when:
- Completing model training and before deployment
- Reviewing model training code before merging
- Investigating surprising model performance
- Validating hyperparameter tuning strategy

## How It Works

The model-trainer agent will:

1. Ask for model training code and metrics
2. Review data preparation and splits
3. Check hyperparameter tuning approach
4. Validate metrics and evaluation logic
5. Assess reproducibility and experiment tracking
6. Provide approval or list rigor concerns

## Example Usage

```
User: /evaluate-model

Agent: I'll review your model training for rigor and evaluation quality.

**What would you like me to evaluate?**
1. Share your model training script
2. Describe the data splits (train/val/test %)
3. List the metrics you're tracking
4. Show the hyperparameter ranges tested

I'll then check:
- Data leakage (val/test in training data)
- Hyperparameter tuning on validation (not test)
- Metrics appropriate for your problem
- Reproducibility with fixed random seeds
- Error analysis and failure modes
```

## Output

After running `/evaluate-model`, you'll get:

- **Training Rigor** - Reproducibility, random seeds, experiment tracking
- **Data Quality** - Train/val/test split soundness, leakage check
- **Hyperparameter Review** - Tuning strategy, ranges, selection logic
- **Metrics Assessment** - Are metrics appropriate for your problem?
- **Evaluation Quality** - Is evaluation on held-out test set?
- **Error Analysis** - Understanding of where model fails
- **Approval Status**:
  - ✅ **Approve** - Model rigorously trained and evaluated; ready for production
  - ⚠️ **Warning** - Quality concerns; recommend additional validation
  - ❌ **Block** - Critical issues; data leakage or invalid evaluation

## Problem-Specific Guidance

### Classification
- Check for class imbalance handling
- Verify metrics beyond accuracy (F1, precision, recall, AUC)
- Threshold tuning evaluated
- Confusion matrix analyzed

### Regression
- Residual analysis performed
- Error metrics interpretable in business context
- Outlier influence assessed

### Time Series
- Temporal split used (no future leakage)
- Backtesting on multiple periods
- Forecasting horizon appropriate

## Related Skills

- [model-evaluation-protocol.md](../skills/model-evaluation-protocol.md) - Evaluation workflow
- [error-analysis.md](../skills/error-analysis.md) - Error investigation guide

## Related Agents

- [model-trainer.md](../agents/model-trainer.md) - Full training review
