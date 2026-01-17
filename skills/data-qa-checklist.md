# Data QA Checklist

**Version:** 1.0.0
**Author:** analytics-team
**Category:** analytics

---

## Purpose

Systematic quality assurance process for validating datasets before analysis or model training.

---

## When to Use

- Before starting analysis on a new dataset
- After receiving data from a new source
- When data pipeline has changed
- Before training production models

---

## Prerequisites

- [ ] Dataset loaded into working environment
- [ ] Data dictionary or schema documentation available
- [ ] Expected row counts or metrics for validation

---

## Steps

### Step 1: Schema Validation

**Goal:** Verify data structure matches expectations.

**Actions:**
1. Check column names match expected schema
2. Verify data types for each column
3. Identify unexpected or new columns
4. Document any schema discrepancies

**Example:**
```python
import pandas as pd

def check_schema(df, expected_schema: dict) -> dict:
    """Validate DataFrame schema."""
    results = {"missing": [], "extra": [], "type_mismatches": []}

    # Check for missing columns
    results["missing"] = [c for c in expected_schema if c not in df.columns]

    # Check for extra columns
    results["extra"] = [c for c in df.columns if c not in expected_schema]

    # Check types
    for col, expected_type in expected_schema.items():
        if col in df.columns:
            actual_type = str(df[col].dtype)
            if actual_type != expected_type:
                results["type_mismatches"].append({
                    "column": col,
                    "expected": expected_type,
                    "actual": actual_type
                })

    return results

# Run schema check
expected = {"user_id": "int64", "email": "object", "created_at": "datetime64[ns]"}
schema_results = check_schema(df, expected)
print(schema_results)
```

**Checkpoint:** All expected columns present with correct types.

---

### Step 2: Completeness Check

**Goal:** Assess missing data and gaps.

**Actions:**
1. Calculate null percentage for each column
2. Identify patterns in missing data
3. Check for implicit nulls (empty strings, sentinel values)
4. Document columns with high null rates (>5%)

**Example:**
```python
def check_completeness(df) -> pd.DataFrame:
    """Analyze missing data."""
    completeness = pd.DataFrame({
        "column": df.columns,
        "null_count": df.isnull().sum().values,
        "null_pct": (df.isnull().sum() / len(df) * 100).round(2).values,
        "unique_values": df.nunique().values,
    })
    return completeness.sort_values("null_pct", ascending=False)

completeness = check_completeness(df)
print(completeness[completeness["null_pct"] > 0])
```

**Checkpoint:** Null rates documented; high-null columns flagged.

---

### Step 3: Uniqueness & Duplicates

**Goal:** Verify record uniqueness and identify duplicates.

**Actions:**
1. Check primary key uniqueness
2. Count duplicate records
3. Analyze duplicate patterns
4. Decide: keep first, keep last, or dedupe logic

**Example:**
```python
def check_duplicates(df, key_columns: list) -> dict:
    """Analyze duplicates."""
    results = {
        "total_rows": len(df),
        "unique_keys": df[key_columns].drop_duplicates().shape[0],
        "duplicate_rows": df.duplicated(subset=key_columns).sum(),
    }
    results["duplicate_pct"] = round(
        results["duplicate_rows"] / results["total_rows"] * 100, 2
    )

    # Sample duplicates for investigation
    if results["duplicate_rows"] > 0:
        dupes = df[df.duplicated(subset=key_columns, keep=False)]
        results["sample_duplicates"] = dupes.head(10)

    return results

dupe_results = check_duplicates(df, key_columns=["order_id"])
print(f"Duplicates: {dupe_results['duplicate_rows']} ({dupe_results['duplicate_pct']}%)")
```

**Checkpoint:** Duplicate rate acceptable; handling strategy decided.

---

### Step 4: Value Validity

**Goal:** Verify data values are within expected ranges.

**Actions:**
1. Check categorical columns for unexpected values
2. Verify numeric ranges (min, max, mean)
3. Validate date ranges
4. Flag outliers for review

**Example:**
```python
def check_value_ranges(df, rules: dict) -> list:
    """Check values against defined rules."""
    violations = []

    for col, rule in rules.items():
        if col not in df.columns:
            continue

        if "min" in rule and df[col].min() < rule["min"]:
            violations.append(f"{col}: min {df[col].min()} < expected {rule['min']}")

        if "max" in rule and df[col].max() > rule["max"]:
            violations.append(f"{col}: max {df[col].max()} > expected {rule['max']}")

        if "values" in rule:
            invalid = set(df[col].unique()) - set(rule["values"])
            if invalid:
                violations.append(f"{col}: unexpected values {invalid}")

    return violations

rules = {
    "age": {"min": 0, "max": 120},
    "status": {"values": ["active", "inactive", "pending"]},
    "amount": {"min": 0},
}
violations = check_value_ranges(df, rules)
for v in violations:
    print(f"⚠️ {v}")
```

**Checkpoint:** All values within expected ranges; outliers documented.

---

### Step 5: Consistency Checks

**Goal:** Verify logical consistency across columns.

**Actions:**
1. Check cross-column constraints (e.g., start_date < end_date)
2. Verify calculated fields match
3. Check referential integrity if joining tables
4. Validate business logic rules

**Example:**
```python
def check_consistency(df) -> list:
    """Check logical consistency."""
    issues = []

    # Date ordering
    if "start_date" in df.columns and "end_date" in df.columns:
        invalid_dates = (df["start_date"] > df["end_date"]).sum()
        if invalid_dates > 0:
            issues.append(f"start_date > end_date: {invalid_dates} rows")

    # Calculated totals
    if all(c in df.columns for c in ["quantity", "price", "total"]):
        expected_total = df["quantity"] * df["price"]
        mismatches = (abs(df["total"] - expected_total) > 0.01).sum()
        if mismatches > 0:
            issues.append(f"total != quantity * price: {mismatches} rows")

    return issues

consistency_issues = check_consistency(df)
for issue in consistency_issues:
    print(f"⚠️ {issue}")
```

**Checkpoint:** No logical inconsistencies; exceptions documented.

---

## Common Issues

### Issue 1: High Null Rate in Critical Column

**Symptoms:** >5% nulls in required field.

**Solution:** Investigate source; consider imputation or filtering.

### Issue 2: Unexpected Categorical Values

**Symptoms:** New values not in expected set.

**Solution:** Update schema or filter; check for data entry issues.

### Issue 3: Duplicate Primary Keys

**Symptoms:** Key column not unique.

**Solution:** Identify root cause; implement deduplication logic.

---

## Completion Checklist

- [ ] Schema validated
- [ ] Null rates documented
- [ ] Duplicates analyzed
- [ ] Value ranges verified
- [ ] Consistency checks passed
- [ ] Issues documented with resolution plan
- [ ] QA summary report created

---

## Related Resources

- [Data Validation Rule](../rules/analytics/data-validation.mdc)
- [EDA Workflow](./eda-workflow.md)
