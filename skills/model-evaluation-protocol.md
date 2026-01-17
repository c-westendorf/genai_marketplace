# Model Evaluation Protocol

**Version:** 1.0.0
**Author:** ml-team
**Category:** ml

---

## Purpose

Comprehensive protocol for evaluating machine learning models to ensure reliable performance assessment.

---

## When to Use

- Before deploying a model to production
- When comparing multiple model candidates
- During model refresh/retraining cycles
- For stakeholder model review presentations

---

## Prerequisites

- [ ] Model trained and ready for evaluation
- [ ] Held-out test set (never seen during training)
- [ ] Baseline model or benchmark metrics defined
- [ ] Business success criteria documented

---

## Steps

### Step 1: Prepare Evaluation Data

**Goal:** Ensure clean, representative test data.

**Actions:**
1. Confirm test set was held out during training
2. Verify test set distribution matches production
3. Check for data leakage from training
4. Document test set characteristics

**Example:**
```python
def prepare_evaluation_data(df_train, df_test, target_col):
    """Verify evaluation data integrity."""

    # Check for leakage - no overlap in IDs
    if "id" in df_train.columns and "id" in df_test.columns:
        overlap = set(df_train["id"]) & set(df_test["id"])
        assert len(overlap) == 0, f"Data leakage! {len(overlap)} IDs in both sets"

    # Compare distributions
    train_dist = df_train[target_col].value_counts(normalize=True)
    test_dist = df_test[target_col].value_counts(normalize=True)

    print("Target distribution comparison:")
    print(f"Train: {train_dist.to_dict()}")
    print(f"Test:  {test_dist.to_dict()}")

    return df_test

test_data = prepare_evaluation_data(df_train, df_test, "target")
```

**Checkpoint:** Test set verified clean and representative.

---

### Step 2: Generate Predictions

**Goal:** Get model predictions for evaluation.

**Actions:**
1. Generate class predictions
2. Generate probability scores (if applicable)
3. Save predictions for reproducibility
4. Verify prediction format matches expectations

**Example:**
```python
def generate_predictions(model, X_test, save_path=None):
    """Generate and optionally save predictions."""

    # Class predictions
    y_pred = model.predict(X_test)

    # Probability predictions (if available)
    y_prob = None
    if hasattr(model, "predict_proba"):
        y_prob = model.predict_proba(X_test)

    predictions = {
        "y_pred": y_pred,
        "y_prob": y_prob,
    }

    if save_path:
        import joblib
        joblib.dump(predictions, save_path)
        print(f"Predictions saved to {save_path}")

    return predictions

preds = generate_predictions(model, X_test, "predictions.joblib")
```

**Checkpoint:** Predictions generated and saved.

---

### Step 3: Calculate Performance Metrics

**Goal:** Compute comprehensive metrics.

**Actions:**
1. Calculate primary metric (aligned with business goal)
2. Calculate secondary metrics for full picture
3. Compute confidence intervals
4. Compare to baseline performance

**Example:**
```python
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, confusion_matrix, classification_report
)
import numpy as np

def evaluate_classification(y_true, y_pred, y_prob=None, baseline_pred=None):
    """Comprehensive classification evaluation."""

    metrics = {
        "accuracy": accuracy_score(y_true, y_pred),
        "precision": precision_score(y_true, y_pred, average="weighted"),
        "recall": recall_score(y_true, y_pred, average="weighted"),
        "f1": f1_score(y_true, y_pred, average="weighted"),
    }

    # AUC if probabilities available
    if y_prob is not None:
        if y_prob.ndim > 1:
            y_prob_pos = y_prob[:, 1] if y_prob.shape[1] == 2 else y_prob
        else:
            y_prob_pos = y_prob
        metrics["roc_auc"] = roc_auc_score(y_true, y_prob_pos)

    # Baseline comparison
    if baseline_pred is not None:
        baseline_f1 = f1_score(y_true, baseline_pred, average="weighted")
        metrics["baseline_f1"] = baseline_f1
        metrics["f1_lift"] = metrics["f1"] - baseline_f1
        metrics["f1_lift_pct"] = (metrics["f1_lift"] / baseline_f1) * 100

    # Bootstrap confidence interval for F1
    metrics["f1_ci_95"] = bootstrap_ci(y_true, y_pred, f1_score, n=1000)

    return metrics

def bootstrap_ci(y_true, y_pred, metric_fn, n=1000, ci=0.95):
    """Bootstrap confidence interval."""
    scores = []
    for _ in range(n):
        idx = np.random.choice(len(y_true), len(y_true), replace=True)
        scores.append(metric_fn(y_true[idx], y_pred[idx], average="weighted"))
    lower = np.percentile(scores, (1-ci)/2 * 100)
    upper = np.percentile(scores, (1+ci)/2 * 100)
    return (round(lower, 4), round(upper, 4))

metrics = evaluate_classification(y_test, preds["y_pred"], preds["y_prob"], baseline_pred)
print(metrics)
```

**Checkpoint:** All metrics calculated with confidence intervals.

---

### Step 4: Analyze Errors

**Goal:** Understand model failure modes.

**Actions:**
1. Generate confusion matrix
2. Identify systematic error patterns
3. Analyze worst-performing segments
4. Sample misclassified examples for review

**Example:**
```python
def analyze_errors(y_true, y_pred, X_test, n_samples=10):
    """Analyze model errors."""

    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    print("Confusion Matrix:")
    print(cm)

    # Misclassified samples
    misclassified_idx = np.where(y_true != y_pred)[0]
    print(f"\nMisclassified: {len(misclassified_idx)} ({len(misclassified_idx)/len(y_true)*100:.1f}%)")

    # Sample errors for review
    if len(misclassified_idx) > 0:
        sample_idx = np.random.choice(misclassified_idx, min(n_samples, len(misclassified_idx)), replace=False)
        error_samples = X_test.iloc[sample_idx].copy()
        error_samples["true_label"] = y_true[sample_idx]
        error_samples["predicted"] = y_pred[sample_idx]
        return error_samples

    return None

error_samples = analyze_errors(y_test, preds["y_pred"], X_test)
```

**Checkpoint:** Error patterns documented; failure modes understood.

---

### Step 5: Segment Performance

**Goal:** Evaluate performance across key segments.

**Actions:**
1. Identify important segments (e.g., user types, regions)
2. Calculate metrics per segment
3. Flag segments with poor performance
4. Check for fairness issues

**Example:**
```python
def segment_performance(y_true, y_pred, segments, segment_name="segment"):
    """Evaluate performance by segment."""

    results = []
    for segment_val in segments.unique():
        mask = segments == segment_val
        if mask.sum() < 10:  # Skip small segments
            continue

        segment_metrics = {
            segment_name: segment_val,
            "n": mask.sum(),
            "accuracy": accuracy_score(y_true[mask], y_pred[mask]),
            "f1": f1_score(y_true[mask], y_pred[mask], average="weighted"),
        }
        results.append(segment_metrics)

    results_df = pd.DataFrame(results)
    results_df = results_df.sort_values("f1")

    print(f"Performance by {segment_name}:")
    print(results_df)

    # Flag underperforming segments
    overall_f1 = f1_score(y_true, y_pred, average="weighted")
    poor_segments = results_df[results_df["f1"] < overall_f1 * 0.9]
    if len(poor_segments) > 0:
        print(f"\n⚠️ Underperforming segments (>10% below overall):")
        print(poor_segments)

    return results_df

segment_results = segment_performance(y_test, preds["y_pred"], df_test["user_type"])
```

**Checkpoint:** Performance validated across all key segments.

---

### Step 6: Document Results

**Goal:** Create evaluation report for stakeholders.

**Actions:**
1. Summarize key findings
2. Compare to baseline and business targets
3. Document limitations and caveats
4. Provide deployment recommendation

**Example:**
```python
def create_evaluation_report(metrics, segment_results, error_analysis):
    """Generate evaluation summary report."""

    report = f"""
# Model Evaluation Report

## Summary Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| F1 Score | {metrics['f1']:.4f} | 0.80 | {'✅' if metrics['f1'] >= 0.80 else '❌'} |
| ROC AUC | {metrics.get('roc_auc', 'N/A'):.4f} | 0.85 | {'✅' if metrics.get('roc_auc', 0) >= 0.85 else '❌'} |
| F1 vs Baseline | +{metrics.get('f1_lift_pct', 0):.1f}% | +5% | {'✅' if metrics.get('f1_lift_pct', 0) >= 5 else '❌'} |

## Confidence Interval

F1 Score 95% CI: {metrics.get('f1_ci_95', 'N/A')}

## Segment Performance

{segment_results.to_markdown()}

## Recommendation

[Based on results, provide deployment recommendation]

## Limitations

- [Document any caveats or limitations]
"""
    return report

report = create_evaluation_report(metrics, segment_results, error_samples)
print(report)
```

**Checkpoint:** Evaluation report complete and reviewed.

---

## Completion Checklist

- [ ] Test data verified (no leakage)
- [ ] Predictions generated and saved
- [ ] Primary and secondary metrics calculated
- [ ] Confidence intervals computed
- [ ] Baseline comparison complete
- [ ] Error analysis documented
- [ ] Segment performance evaluated
- [ ] Evaluation report created
- [ ] Deployment decision documented

---

## Related Resources

- [Evaluation Metrics Rule](../rules/ml/evaluation-metrics.mdc)
- [Error Analysis Skill](./error-analysis.md)
