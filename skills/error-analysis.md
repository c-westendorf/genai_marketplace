# Error Analysis Guide

**Version:** 1.0.0
**Author:** ml-team
**Category:** ml

---

## Purpose

Systematic process for understanding model errors to guide improvements.

---

## When to Use

- After initial model evaluation
- When model underperforms in specific segments
- Before deciding on model improvements
- During model debugging sessions

---

## Prerequisites

- [ ] Model trained and predictions generated
- [ ] Ground truth labels available
- [ ] Feature data accessible for error cases
- [ ] Evaluation metrics computed

---

## Steps

### Step 1: Quantify Errors

**Goal:** Understand the overall error landscape.

**Actions:**
1. Calculate confusion matrix
2. Compute error rates by class
3. Identify most confused class pairs
4. Quantify false positive vs false negative costs

**Example:**
```python
import pandas as pd
import numpy as np
from sklearn.metrics import confusion_matrix, classification_report
import seaborn as sns
import matplotlib.pyplot as plt

def quantify_errors(y_true, y_pred, class_names=None):
    """Quantify and visualize classification errors."""

    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)

    # Visualize
    plt.figure(figsize=(10, 8))
    sns.heatmap(
        cm, annot=True, fmt="d", cmap="Blues",
        xticklabels=class_names or np.unique(y_true),
        yticklabels=class_names or np.unique(y_true)
    )
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.title("Confusion Matrix")
    plt.show()

    # Error analysis
    total = cm.sum()
    errors = total - np.trace(cm)
    print(f"Total errors: {errors:,} ({errors/total*100:.1f}%)")

    # Most confused pairs
    cm_off_diag = cm.copy()
    np.fill_diagonal(cm_off_diag, 0)

    confused_pairs = []
    for i in range(len(cm)):
        for j in range(len(cm)):
            if i != j and cm_off_diag[i, j] > 0:
                confused_pairs.append({
                    "actual": class_names[i] if class_names else i,
                    "predicted": class_names[j] if class_names else j,
                    "count": cm_off_diag[i, j],
                    "pct_of_errors": cm_off_diag[i, j] / errors * 100
                })

    confused_df = pd.DataFrame(confused_pairs).sort_values("count", ascending=False)
    print("\nMost confused pairs:")
    print(confused_df.head(10))

    return cm, confused_df

cm, confused = quantify_errors(y_test, y_pred, class_names=["Class A", "Class B", "Class C"])
```

**Checkpoint:** Error distribution documented; top error types identified.

---

### Step 2: Sample Errors

**Goal:** Collect representative error samples for analysis.

**Actions:**
1. Extract misclassified examples
2. Stratify by error type
3. Sample across confidence levels
4. Include borderline cases

**Example:**
```python
def sample_errors(X, y_true, y_pred, y_prob=None, n_samples=50):
    """Sample errors for manual review."""

    # Create error dataframe
    error_df = X.copy()
    error_df["y_true"] = y_true
    error_df["y_pred"] = y_pred
    error_df["is_error"] = y_true != y_pred

    if y_prob is not None:
        error_df["confidence"] = y_prob.max(axis=1)
        error_df["pred_prob"] = [y_prob[i, pred] for i, pred in enumerate(y_pred)]

    # Filter to errors
    errors_only = error_df[error_df["is_error"]].copy()
    print(f"Total errors: {len(errors_only)}")

    # Sample strategy
    samples = []

    # High confidence errors (model was sure but wrong)
    if y_prob is not None:
        high_conf_errors = errors_only[errors_only["confidence"] > 0.8]
        if len(high_conf_errors) > 0:
            n = min(n_samples // 3, len(high_conf_errors))
            samples.append(high_conf_errors.sample(n))
            print(f"High confidence errors (>0.8): {len(high_conf_errors)}")

    # Random sample of remaining
    remaining = n_samples - len(pd.concat(samples)) if samples else n_samples
    samples.append(errors_only.sample(min(remaining, len(errors_only))))

    sampled = pd.concat(samples).drop_duplicates()

    return sampled

error_samples = sample_errors(X_test, y_test, y_pred, y_prob, n_samples=50)
print(f"\nSampled {len(error_samples)} errors for review")
```

**Checkpoint:** Representative error samples collected.

---

### Step 3: Categorize Errors

**Goal:** Group errors by root cause.

**Actions:**
1. Review error samples manually
2. Identify common patterns
3. Create error taxonomy
4. Label errors with categories

**Example:**
```python
def create_error_taxonomy():
    """Define common error categories."""

    return {
        "data_quality": "Missing or incorrect input data",
        "label_noise": "Ground truth label may be wrong",
        "class_overlap": "True ambiguity between classes",
        "distribution_shift": "Example differs from training distribution",
        "missing_feature": "Important signal not captured",
        "model_limitation": "Model architecture cannot learn pattern",
        "rare_case": "Edge case with insufficient training examples",
    }

taxonomy = create_error_taxonomy()

# Manual labeling template
def label_errors(error_samples, output_path="labeled_errors.csv"):
    """Create template for manual error labeling."""

    error_samples["error_category"] = ""
    error_samples["notes"] = ""

    # Display for labeling
    print("Error categories:")
    for cat, desc in taxonomy.items():
        print(f"  {cat}: {desc}")

    print(f"\nExport to {output_path} for labeling")
    error_samples.to_csv(output_path, index=False)

    return error_samples

# After manual labeling, analyze
def analyze_error_categories(labeled_errors):
    """Analyze labeled error categories."""

    category_counts = labeled_errors["error_category"].value_counts()
    print("Error breakdown by category:")
    print(category_counts)

    # Visualize
    category_counts.plot(kind="bar")
    plt.title("Errors by Category")
    plt.xlabel("Category")
    plt.ylabel("Count")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

    return category_counts
```

**Checkpoint:** Errors categorized; root causes identified.

---

### Step 4: Segment Analysis

**Goal:** Find segments with higher error rates.

**Actions:**
1. Calculate error rate by segment
2. Identify underperforming segments
3. Analyze segment characteristics
4. Check for fairness issues

**Example:**
```python
def analyze_error_segments(X, y_true, y_pred, segment_cols):
    """Analyze errors by segment."""

    analysis_df = X.copy()
    analysis_df["is_error"] = y_true != y_pred

    results = []
    overall_error_rate = analysis_df["is_error"].mean()

    for col in segment_cols:
        segment_errors = analysis_df.groupby(col).agg({
            "is_error": ["sum", "count", "mean"]
        }).round(4)
        segment_errors.columns = ["errors", "total", "error_rate"]
        segment_errors["segment"] = col
        segment_errors["vs_overall"] = segment_errors["error_rate"] - overall_error_rate

        results.append(segment_errors.reset_index())

    all_results = pd.concat(results)

    # Flag high error segments
    high_error = all_results[all_results["error_rate"] > overall_error_rate * 1.5]
    if len(high_error) > 0:
        print("⚠️ High error segments (>1.5x overall):")
        print(high_error)

    return all_results

segment_analysis = analyze_error_segments(
    X_test, y_test, y_pred,
    segment_cols=["age_group", "region", "product_category"]
)
```

**Checkpoint:** High-error segments identified.

---

### Step 5: Feature Analysis

**Goal:** Understand which features contribute to errors.

**Actions:**
1. Compare feature distributions for errors vs correct
2. Calculate feature importance for error prediction
3. Identify features that confuse the model
4. Look for feature value patterns in errors

**Example:**
```python
def analyze_error_features(X, y_true, y_pred, top_n=10):
    """Analyze features contributing to errors."""

    df = X.copy()
    df["is_error"] = (y_true != y_pred).astype(int)

    # Compare distributions
    numeric_cols = X.select_dtypes(include=np.number).columns

    comparisons = []
    for col in numeric_cols:
        correct_mean = df[df["is_error"] == 0][col].mean()
        error_mean = df[df["is_error"] == 1][col].mean()
        diff_pct = (error_mean - correct_mean) / correct_mean * 100 if correct_mean != 0 else 0

        comparisons.append({
            "feature": col,
            "correct_mean": correct_mean,
            "error_mean": error_mean,
            "diff_pct": diff_pct,
            "abs_diff_pct": abs(diff_pct)
        })

    comp_df = pd.DataFrame(comparisons).sort_values("abs_diff_pct", ascending=False)
    print("Features with largest difference in error vs correct:")
    print(comp_df.head(top_n))

    # Train a model to predict errors
    from sklearn.ensemble import RandomForestClassifier
    from sklearn.inspection import permutation_importance

    error_model = RandomForestClassifier(n_estimators=100, random_state=42)
    error_model.fit(X, df["is_error"])

    importance = pd.DataFrame({
        "feature": X.columns,
        "importance": error_model.feature_importances_
    }).sort_values("importance", ascending=False)

    print("\nFeatures predictive of errors:")
    print(importance.head(top_n))

    return comp_df, importance

feature_comparison, error_importance = analyze_error_features(X_test, y_test, y_pred)
```

**Checkpoint:** Error-causing features identified.

---

### Step 6: Improvement Recommendations

**Goal:** Translate analysis into actionable improvements.

**Actions:**
1. Prioritize error categories by impact
2. Map categories to solutions
3. Estimate effort vs impact
4. Create improvement roadmap

**Example:**
```python
def create_improvement_plan(category_counts, segment_analysis, feature_analysis):
    """Create prioritized improvement plan."""

    improvements = {
        "data_quality": [
            "Add data validation in pipeline",
            "Implement missing value imputation",
        ],
        "label_noise": [
            "Review labeling guidelines",
            "Add label quality checks",
            "Consider soft labels",
        ],
        "class_overlap": [
            "Collect additional distinguishing features",
            "Consider hierarchical classification",
        ],
        "distribution_shift": [
            "Add domain adaptation",
            "Implement online learning",
            "Add monitoring for drift",
        ],
        "missing_feature": [
            "Engineer new features",
            "Add external data sources",
        ],
        "rare_case": [
            "Oversample minority cases",
            "Collect more examples",
            "Apply data augmentation",
        ],
    }

    print("=== Improvement Plan ===\n")

    for category in category_counts.index[:3]:  # Top 3 categories
        print(f"## {category} ({category_counts[category]} errors)")
        if category in improvements:
            for imp in improvements[category]:
                print(f"  - {imp}")
        print()

    return improvements

improvement_plan = create_improvement_plan(category_counts, segment_analysis, feature_comparison)
```

**Checkpoint:** Improvement plan created and prioritized.

---

## Completion Checklist

- [ ] Confusion matrix analyzed
- [ ] Error samples collected
- [ ] Errors categorized by root cause
- [ ] High-error segments identified
- [ ] Feature analysis completed
- [ ] Improvement plan created
- [ ] Priorities assigned
- [ ] Error analysis documented

---

## Related Resources

- [Model Evaluation Protocol](./model-evaluation-protocol.md)
- [Evaluation Metrics Rule](../rules/ml/evaluation-metrics.mdc)
