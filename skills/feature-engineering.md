# Feature Engineering Guide

**Version:** 1.0.0
**Author:** ml-team
**Category:** ml

---

## Purpose

Systematic approach to creating features that improve model performance while avoiding common pitfalls.

---

## When to Use

- After EDA, before model training
- When baseline model underperforms
- During model iteration cycles
- When domain expertise suggests new features

---

## Prerequisites

- [ ] EDA completed
- [ ] Target variable defined
- [ ] Train/test split already done (prevent leakage!)
- [ ] Domain context understood

---

## Steps

### Step 1: Feature Inventory

**Goal:** Catalog existing features and identify opportunities.

**Actions:**
1. List all available raw features
2. Categorize by type (numeric, categorical, temporal, text)
3. Note domain meaning of each feature
4. Identify gaps based on domain knowledge

**Example:**
```python
def create_feature_inventory(df, target_col=None):
    """Create inventory of available features."""

    inventory = []
    for col in df.columns:
        if col == target_col:
            continue

        info = {
            "feature": col,
            "dtype": str(df[col].dtype),
            "n_unique": df[col].nunique(),
            "null_pct": round(df[col].isnull().sum() / len(df) * 100, 2),
            "category": categorize_feature(df[col]),
        }
        inventory.append(info)

    return pd.DataFrame(inventory)

def categorize_feature(series):
    """Categorize feature type."""
    if pd.api.types.is_numeric_dtype(series):
        return "numeric"
    elif pd.api.types.is_datetime64_any_dtype(series):
        return "datetime"
    elif series.nunique() < 20:
        return "categorical_low_card"
    else:
        return "categorical_high_card"

inventory = create_feature_inventory(df, target_col="target")
print(inventory)
```

**Checkpoint:** All features cataloged with types.

---

### Step 2: Numeric Transformations

**Goal:** Transform numeric features for better model performance.

**Actions:**
1. Apply log transform to skewed features
2. Create polynomial features if relationships non-linear
3. Bin continuous features if appropriate
4. Handle outliers consistently

**Example:**
```python
import numpy as np
from sklearn.preprocessing import PowerTransformer

def transform_numeric_features(df, numeric_cols, skew_threshold=1.0):
    """Apply transformations to numeric features."""

    df_transformed = df.copy()
    transformations = {}

    for col in numeric_cols:
        skewness = df[col].skew()

        if abs(skewness) > skew_threshold:
            # Log transform for positive skewed data
            if (df[col] > 0).all():
                df_transformed[f"{col}_log"] = np.log1p(df[col])
                transformations[col] = "log1p"
            else:
                # Box-Cox style transform
                pt = PowerTransformer(method="yeo-johnson")
                df_transformed[f"{col}_transformed"] = pt.fit_transform(
                    df[[col]]
                ).flatten()
                transformations[col] = "yeo-johnson"

    print(f"Applied transformations: {transformations}")
    return df_transformed, transformations

df_transformed, transforms = transform_numeric_features(
    df_train, ["income", "age", "transaction_amount"]
)
```

**Checkpoint:** Skewed features transformed; transformations logged.

---

### Step 3: Categorical Encoding

**Goal:** Convert categorical features to numeric representation.

**Actions:**
1. One-hot encode low cardinality categoricals
2. Target encode or hash high cardinality categoricals
3. Handle unknown categories for production
4. Store encoders for inference

**Example:**
```python
from sklearn.preprocessing import OneHotEncoder
from category_encoders import TargetEncoder

def encode_categoricals(df_train, df_test, cat_cols, target_col, high_card_threshold=10):
    """Encode categorical features (fit on train only!)."""

    encoders = {}
    df_train_encoded = df_train.copy()
    df_test_encoded = df_test.copy()

    for col in cat_cols:
        n_unique = df_train[col].nunique()

        if n_unique <= high_card_threshold:
            # One-hot encoding
            encoder = OneHotEncoder(sparse=False, handle_unknown="ignore")
            encoder.fit(df_train[[col]])

            # Transform both sets
            train_encoded = encoder.transform(df_train[[col]])
            test_encoded = encoder.transform(df_test[[col]])

            # Create column names
            feature_names = [f"{col}_{cat}" for cat in encoder.categories_[0]]

            df_train_encoded[feature_names] = train_encoded
            df_test_encoded[feature_names] = test_encoded

            encoders[col] = {"type": "onehot", "encoder": encoder}

        else:
            # Target encoding for high cardinality
            encoder = TargetEncoder(cols=[col])
            encoder.fit(df_train[[col]], df_train[target_col])

            df_train_encoded[f"{col}_encoded"] = encoder.transform(df_train[[col]])
            df_test_encoded[f"{col}_encoded"] = encoder.transform(df_test[[col]])

            encoders[col] = {"type": "target", "encoder": encoder}

    return df_train_encoded, df_test_encoded, encoders

df_train_enc, df_test_enc, encoders = encode_categoricals(
    df_train, df_test, ["category", "region"], "target"
)
```

**Checkpoint:** All categoricals encoded; encoders saved.

---

### Step 4: Temporal Features

**Goal:** Extract meaningful features from datetime columns.

**Actions:**
1. Extract date parts (year, month, day, weekday)
2. Create cyclical encodings for periodic features
3. Calculate time-based aggregations
4. Create recency/frequency features

**Example:**
```python
def create_temporal_features(df, date_col):
    """Extract features from datetime column."""

    df = df.copy()
    df[date_col] = pd.to_datetime(df[date_col])

    # Date parts
    df[f"{date_col}_year"] = df[date_col].dt.year
    df[f"{date_col}_month"] = df[date_col].dt.month
    df[f"{date_col}_day"] = df[date_col].dt.day
    df[f"{date_col}_dayofweek"] = df[date_col].dt.dayofweek
    df[f"{date_col}_hour"] = df[date_col].dt.hour

    # Cyclical encoding for periodic features
    df[f"{date_col}_month_sin"] = np.sin(2 * np.pi * df[f"{date_col}_month"] / 12)
    df[f"{date_col}_month_cos"] = np.cos(2 * np.pi * df[f"{date_col}_month"] / 12)
    df[f"{date_col}_dow_sin"] = np.sin(2 * np.pi * df[f"{date_col}_dayofweek"] / 7)
    df[f"{date_col}_dow_cos"] = np.cos(2 * np.pi * df[f"{date_col}_dayofweek"] / 7)

    # Boolean flags
    df[f"{date_col}_is_weekend"] = df[f"{date_col}_dayofweek"].isin([5, 6]).astype(int)
    df[f"{date_col}_is_month_start"] = df[date_col].dt.is_month_start.astype(int)
    df[f"{date_col}_is_month_end"] = df[date_col].dt.is_month_end.astype(int)

    return df

df_with_time = create_temporal_features(df, "transaction_date")
```

**Checkpoint:** Temporal features extracted; cyclical encoding applied.

---

### Step 5: Aggregation Features

**Goal:** Create aggregate statistics across groups.

**Actions:**
1. Calculate group-level statistics
2. Create ratio features
3. Build lag features for time series
4. Ensure no data leakage from future

**Example:**
```python
def create_aggregation_features(df, group_col, value_col, agg_funcs=["mean", "std", "count"]):
    """Create aggregation features by group."""

    df = df.copy()
    agg = df.groupby(group_col)[value_col].agg(agg_funcs)
    agg.columns = [f"{group_col}_{value_col}_{func}" for func in agg_funcs]

    df = df.merge(agg, on=group_col, how="left")

    # Ratio to group mean
    df[f"{value_col}_vs_{group_col}_mean"] = (
        df[value_col] / df[f"{group_col}_{value_col}_mean"]
    )

    return df

df_with_aggs = create_aggregation_features(df_train, "customer_id", "purchase_amount")


# For time series: lag features (be careful about leakage!)
def create_lag_features(df, date_col, value_col, group_col, lags=[1, 7, 30]):
    """Create lag features respecting temporal order."""

    df = df.copy().sort_values([group_col, date_col])

    for lag in lags:
        df[f"{value_col}_lag_{lag}"] = df.groupby(group_col)[value_col].shift(lag)

    return df
```

**Checkpoint:** Aggregations created; leakage verified absent.

---

### Step 6: Feature Selection

**Goal:** Select most predictive features.

**Actions:**
1. Remove highly correlated features
2. Calculate feature importance
3. Apply selection method (mutual info, RFE)
4. Validate on holdout set

**Example:**
```python
from sklearn.feature_selection import mutual_info_classif, SelectKBest

def select_features(X_train, y_train, X_test, method="mutual_info", k=20):
    """Select top k features."""

    if method == "mutual_info":
        selector = SelectKBest(mutual_info_classif, k=k)
    else:
        raise ValueError(f"Unknown method: {method}")

    X_train_selected = selector.fit_transform(X_train, y_train)
    X_test_selected = selector.transform(X_test)

    # Get selected feature names
    selected_mask = selector.get_support()
    selected_features = X_train.columns[selected_mask].tolist()

    print(f"Selected {len(selected_features)} features:")
    print(selected_features)

    return X_train_selected, X_test_selected, selected_features

X_train_sel, X_test_sel, selected = select_features(X_train, y_train, X_test, k=20)
```

**Checkpoint:** Top features selected; selection rationale documented.

---

## Common Issues

### Issue 1: Data Leakage

**Symptoms:** Unrealistically high validation scores.

**Solution:** Always fit transformers on training data only; use pipelines.

### Issue 2: High Cardinality Explosion

**Symptoms:** Too many features after one-hot encoding.

**Solution:** Use target encoding or hashing for high cardinality.

---

## Completion Checklist

- [ ] Feature inventory created
- [ ] Numeric transformations applied
- [ ] Categoricals encoded (fit on train only!)
- [ ] Temporal features extracted
- [ ] Aggregations created
- [ ] Feature selection performed
- [ ] No data leakage verified
- [ ] Feature pipeline saved for inference

---

## Related Resources

- [Data Leakage Prevention Rule](../rules/ml/data-leakage-prevention.mdc)
- [Model Training Rule](../rules/ml/model-training.mdc)
