# EDA Workflow

**Version:** 1.0.0
**Author:** analytics-team
**Category:** analytics

---

## Purpose

Structured approach to exploratory data analysis that ensures thorough understanding before modeling or reporting.

---

## When to Use

- Starting analysis on a new dataset
- Before building predictive models
- When investigating data quality issues
- For stakeholder data understanding sessions

---

## Prerequisites

- [ ] Dataset loaded into environment
- [ ] Business context understood
- [ ] Analysis questions defined

---

## Steps

### Step 1: First Look

**Goal:** Get initial understanding of data structure.

**Actions:**
1. Load data and check shape
2. View first/last rows
3. Check column names and types
4. Get basic summary statistics

**Example:**
```python
import pandas as pd
import numpy as np

def first_look(df):
    """Initial data inspection."""
    print(f"Shape: {df.shape[0]:,} rows × {df.shape[1]} columns")
    print(f"\nColumn types:\n{df.dtypes.value_counts()}")
    print(f"\nMemory usage: {df.memory_usage(deep=True).sum() / 1e6:.1f} MB")

    # Display sample
    display(df.head())
    display(df.describe(include="all").T)

    return {
        "rows": df.shape[0],
        "columns": df.shape[1],
        "numeric_cols": df.select_dtypes(include=np.number).columns.tolist(),
        "categorical_cols": df.select_dtypes(include="object").columns.tolist(),
        "datetime_cols": df.select_dtypes(include="datetime").columns.tolist(),
    }

info = first_look(df)
```

**Checkpoint:** Data structure documented; column types identified.

---

### Step 2: Missing Data Analysis

**Goal:** Understand patterns of missing data.

**Actions:**
1. Calculate missing percentages per column
2. Visualize missing data patterns
3. Identify columns to drop vs impute
4. Document missing data handling plan

**Example:**
```python
import matplotlib.pyplot as plt
import seaborn as sns

def analyze_missing(df):
    """Analyze missing data patterns."""

    # Calculate missing percentages
    missing = pd.DataFrame({
        "column": df.columns,
        "missing_count": df.isnull().sum().values,
        "missing_pct": (df.isnull().sum() / len(df) * 100).round(2).values
    }).sort_values("missing_pct", ascending=False)

    print("Columns with missing values:")
    print(missing[missing["missing_pct"] > 0])

    # Visualize missing patterns
    if missing["missing_pct"].max() > 0:
        fig, ax = plt.subplots(figsize=(10, 6))
        cols_with_missing = missing[missing["missing_pct"] > 0]["column"].tolist()
        sns.heatmap(df[cols_with_missing].isnull(), cbar=True, yticklabels=False, ax=ax)
        plt.title("Missing Data Pattern")
        plt.tight_layout()
        plt.show()

    return missing

missing_analysis = analyze_missing(df)
```

**Checkpoint:** Missing data documented; handling strategy defined.

---

### Step 3: Distribution Analysis

**Goal:** Understand value distributions.

**Actions:**
1. Plot distributions for numeric columns
2. Check for skewness and outliers
3. Analyze categorical value frequencies
4. Identify transformation needs

**Example:**
```python
def analyze_distributions(df, numeric_cols, categorical_cols, max_categories=20):
    """Analyze distributions of all columns."""

    # Numeric distributions
    n_numeric = len(numeric_cols)
    if n_numeric > 0:
        fig, axes = plt.subplots(
            nrows=(n_numeric + 2) // 3,
            ncols=min(3, n_numeric),
            figsize=(15, 4 * ((n_numeric + 2) // 3))
        )
        axes = np.array(axes).flatten()

        for i, col in enumerate(numeric_cols):
            df[col].hist(bins=50, ax=axes[i], edgecolor="black")
            axes[i].set_title(f"{col}\nSkew: {df[col].skew():.2f}")
            axes[i].axvline(df[col].median(), color="red", linestyle="--", label="Median")

        plt.tight_layout()
        plt.show()

    # Categorical distributions
    for col in categorical_cols:
        n_unique = df[col].nunique()
        print(f"\n{col} ({n_unique} unique values):")

        if n_unique <= max_categories:
            print(df[col].value_counts())
        else:
            print(f"Top 10 of {n_unique}:")
            print(df[col].value_counts().head(10))

analyze_distributions(df, info["numeric_cols"], info["categorical_cols"])
```

**Checkpoint:** Distributions documented; outliers and skewness noted.

---

### Step 4: Relationship Analysis

**Goal:** Understand relationships between variables.

**Actions:**
1. Calculate correlation matrix for numeric columns
2. Visualize strong correlations
3. Explore categorical vs target relationships
4. Check for multicollinearity

**Example:**
```python
def analyze_relationships(df, numeric_cols, target_col=None):
    """Analyze relationships between variables."""

    if len(numeric_cols) > 1:
        # Correlation matrix
        corr = df[numeric_cols].corr()

        # Heatmap
        fig, ax = plt.subplots(figsize=(12, 10))
        mask = np.triu(np.ones_like(corr, dtype=bool))
        sns.heatmap(corr, mask=mask, annot=True, fmt=".2f",
                   cmap="coolwarm", center=0, ax=ax)
        plt.title("Correlation Matrix")
        plt.tight_layout()
        plt.show()

        # Strong correlations
        strong_corr = []
        for i in range(len(corr.columns)):
            for j in range(i+1, len(corr.columns)):
                if abs(corr.iloc[i, j]) > 0.7:
                    strong_corr.append({
                        "var1": corr.columns[i],
                        "var2": corr.columns[j],
                        "correlation": corr.iloc[i, j]
                    })

        if strong_corr:
            print("\nStrong correlations (|r| > 0.7):")
            print(pd.DataFrame(strong_corr))

    # Target analysis
    if target_col and target_col in df.columns:
        print(f"\nTarget variable: {target_col}")
        print(df[target_col].value_counts(normalize=True))

correlations = analyze_relationships(df, info["numeric_cols"], target_col="target")
```

**Checkpoint:** Key relationships identified; multicollinearity documented.

---

### Step 5: Time Analysis (if applicable)

**Goal:** Understand temporal patterns.

**Actions:**
1. Plot trends over time
2. Check for seasonality
3. Identify anomalous periods
4. Document temporal coverage

**Example:**
```python
def analyze_time_patterns(df, date_col, value_col, freq="D"):
    """Analyze temporal patterns."""

    df_time = df.copy()
    df_time[date_col] = pd.to_datetime(df_time[date_col])
    df_time = df_time.set_index(date_col)

    # Time range
    print(f"Date range: {df_time.index.min()} to {df_time.index.max()}")
    print(f"Duration: {(df_time.index.max() - df_time.index.min()).days} days")

    # Aggregate by period
    ts = df_time[value_col].resample(freq).agg(["count", "mean", "sum"])

    # Plot
    fig, axes = plt.subplots(2, 1, figsize=(14, 8))

    ts["count"].plot(ax=axes[0], title="Record Count Over Time")
    ts["mean"].plot(ax=axes[1], title=f"Average {value_col} Over Time")

    plt.tight_layout()
    plt.show()

    # Check for gaps
    expected_periods = pd.date_range(df_time.index.min(), df_time.index.max(), freq=freq)
    missing_periods = expected_periods.difference(ts.index)
    if len(missing_periods) > 0:
        print(f"\n⚠️ Missing {len(missing_periods)} periods")

    return ts

# Only run if datetime column exists
if info["datetime_cols"]:
    time_analysis = analyze_time_patterns(df, info["datetime_cols"][0], "value")
```

**Checkpoint:** Temporal patterns documented; gaps identified.

---

### Step 6: Document Findings

**Goal:** Create EDA summary for next steps.

**Actions:**
1. Summarize key findings
2. List data quality issues
3. Recommend preprocessing steps
4. Define next analysis steps

**Example:**
```python
def create_eda_summary(findings: dict) -> str:
    """Generate EDA summary document."""

    summary = """
# EDA Summary

## Dataset Overview
- Rows: {rows:,}
- Columns: {columns}
- Date range: {date_range}

## Data Quality Issues
{quality_issues}

## Key Findings
{key_findings}

## Recommended Preprocessing
{preprocessing}

## Next Steps
{next_steps}
"""
    return summary.format(**findings)

findings = {
    "rows": info["rows"],
    "columns": info["columns"],
    "date_range": "2023-01-01 to 2023-12-31",
    "quality_issues": "- 15% missing in 'income' column\n- Outliers in 'age' (max=150)",
    "key_findings": "- Strong correlation between X and Y\n- Seasonal pattern in sales",
    "preprocessing": "- Impute 'income' with median\n- Cap 'age' at 100",
    "next_steps": "- Build baseline model\n- Investigate outliers with business team"
}

print(create_eda_summary(findings))
```

**Checkpoint:** EDA summary complete; ready for next phase.

---

## Completion Checklist

- [ ] Data structure documented
- [ ] Missing data analyzed
- [ ] Distributions explored
- [ ] Relationships mapped
- [ ] Temporal patterns checked (if applicable)
- [ ] Data quality issues listed
- [ ] Preprocessing plan defined
- [ ] EDA summary created

---

## Related Resources

- [Data QA Checklist](./data-qa-checklist.md)
- [Initial Exploration Prompt](../prompts/eda/initial-exploration.md)
