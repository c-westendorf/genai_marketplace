# Prompt: Debug Data Quality Issues

**Version:** 1.0.0
**Author:** analytics-team
**Category:** debugging

---

## Purpose

Systematically investigate and resolve data quality issues affecting analysis or model performance.

---

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `[issue_type]` | Type of data issue observed | `unexpected nulls`, `wrong values`, `duplicates` |
| `[affected_columns]` | Columns with issues | `email, created_at` |
| `[data_source]` | Where data comes from | `Snowflake warehouse` |
| `[expected_behavior]` | What data should look like | `email should never be null` |

---

## Prompt

```
Help debug data quality issues in my dataset.

Issue description:
- Issue type: [issue_type]
- Affected columns: [affected_columns]
- Data source: [data_source]
- Expected behavior: [expected_behavior]

Please help investigate:

1. **Issue Quantification**
   - How many records are affected?
   - What percentage of data has this issue?
   - Is it concentrated in specific segments?
   - When did it start (if temporal)?

2. **Pattern Analysis**
   - Are affected records related to each other?
   - Do they share common attributes?
   - Is there a temporal pattern?
   - Correlation with other columns?

3. **Root Cause Investigation**
   - Check for upstream pipeline issues
   - Look for schema changes
   - Identify data entry errors
   - Check for ETL bugs

4. **Impact Assessment**
   - How does this affect downstream analysis?
   - Which reports/models are impacted?
   - Is the issue in historical data too?

5. **Resolution Options**
   - Can affected records be fixed?
   - Should they be filtered out?
   - Is re-extraction needed?
   - Prevention for future data

6. **Validation Queries**
   - SQL/Python to identify affected records
   - Queries to monitor for recurrence
   - Tests to add to pipeline

Output format:
- Summary of findings
- Root cause hypothesis
- Recommended fix with implementation
- Prevention measures
```

---

## Example Usage

### Variables Filled In

| Variable | Value |
|----------|-------|
| `[issue_type]` | `Unexpected null values appearing in last week's data` |
| `[affected_columns]` | `user_email, registration_date` |
| `[data_source]` | `PostgreSQL users table via Airbyte sync` |
| `[expected_behavior]` | `email is required at registration, should never be null` |

### Complete Prompt

```
Help debug data quality issues in my dataset.

Issue description:
- Issue type: Unexpected null values appearing in last week's data
- Affected columns: user_email, registration_date
- Data source: PostgreSQL users table via Airbyte sync
- Expected behavior: email is required at registration, should never be null

Please help investigate:

1. **Issue Quantification**
   ... [rest of prompt]
```

### Expected Output

**Issue Summary:**
- 1,234 records affected (2.3% of last week's data)
- All affected records from Jan 10-12
- Concentrated in mobile app registrations

**Root Cause:**
Mobile app v2.3.1 deployed Jan 10 had a bug allowing registration without email validation.

**Resolution:**
```sql
-- Identify affected users
SELECT user_id, created_at, registration_source
FROM users
WHERE user_email IS NULL
AND created_at >= '2024-01-10';

-- Fix: backfill from user_profiles table
UPDATE users u
SET user_email = p.email
FROM user_profiles p
WHERE u.user_id = p.user_id
AND u.user_email IS NULL;
```

**Prevention:**
- Add NOT NULL constraint to source table
- Add data quality check to pipeline
- Alert on null rate > 0.1%

---

## Tips for Best Results

- Include sample records with the issue
- Provide timeline of when issue was first noticed
- Share any recent changes to data pipelines
- Include schema/table definitions if relevant

---

## Related Prompts

- [Model Performance](./model-performance.md)
