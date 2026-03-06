# BigQuery MCP Integration Setup

## Overview

This guide helps you set up Google BigQuery integration with the cursor-marketplace via MCP (Model Context Protocol). Once configured, you can execute analytics queries and create ML models directly from VSCode using Copilot or other LLMs.

**Prerequisites:**
- Google Cloud Project with BigQuery enabled
- Service account with BigQuery permissions
- VSCode with Copilot extension installed
- `gcloud` CLI tool (optional but recommended)

---

## 1. GCP Project Setup

### 1.1 Create a GCP Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project (or use existing)
3. Enable BigQuery API:
   - Search for "BigQuery API"
   - Click "Enable"
4. Copy your **Project ID** (format: `my-gcp-project-123456`)

### 1.2 Create a Service Account

1. Go to **IAM & Admin → Service Accounts**
2. Click **Create Service Account**
3. Enter name: `llm-integration` and description
4. Click **Create and Continue**
5. Grant roles (select all that apply):
   - `BigQuery Data Editor` (read/write tables)
   - `BigQuery Job User` (run queries)
   - `BigQuery ML Admin` (create/manage ML models)
   - `Cloud Storage Object Creator` (export results)

### 1.3 Create Service Account Key

1. In Service Accounts, click on the new account
2. Go to **Keys** tab
3. Click **Add Key → Create new key**
4. Select **JSON** format
5. Click **Create** (JSON file auto-downloads)
6. Save as `~/.config/gcp/bigquery-service-account.json`

**Secure the key file:**
```bash
chmod 600 ~/.config/gcp/bigquery-service-account.json
```

---

## 2. VSCode Configuration

### 2.1 Add BigQuery Credentials to `.env`

Create or update `.env` in your VSCode workspace root:

```bash
# Google Cloud / BigQuery
GOOGLE_PROJECT_ID=my-gcp-project-123456
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcp/bigquery-service-account.json
BIGQUERY_DATASET=analytics
BIGQUERY_LOCATION=US
```

**Important:** Add `.env` to `.gitignore`

### 2.2 Configure MCP in VSCode Settings

Open `.vscode/settings.json` and add:

```json
{
  "mcp.servers": {
    "bigquery": {
      "command": "node",
      "args": ["path/to/bigquery-mcp-server.js"],
      "env": {
        "GOOGLE_PROJECT_ID": "${env:GOOGLE_PROJECT_ID}",
        "GOOGLE_APPLICATION_CREDENTIALS": "${env:GOOGLE_APPLICATION_CREDENTIALS}",
        "BIGQUERY_DATASET": "${env:BIGQUERY_DATASET}",
        "BIGQUERY_LOCATION": "${env:BIGQUERY_LOCATION}"
      }
    }
  }
}
```

### 2.3 (Optional) Install gcloud CLI

For advanced features like local testing:

```bash
# macOS
brew install --cask google-cloud-sdk

# Initialize
gcloud init
gcloud auth application-default login
```

---

## 3. Testing the Connection

### 3.1 Quick Connection Test

In VSCode, open Copilot chat and try:

```
@bigquery
List all datasets in the project and show how many tables are in each
```

Expected response: List of datasets with table counts.

### 3.2 Common Connection Issues

| Issue | Solution |
|-------|----------|
| "Project not found" | Verify GOOGLE_PROJECT_ID is correct; check in Cloud Console |
| "Permission denied" | Verify service account has BigQuery Data Editor role assigned |
| "JSON key invalid" | Check GOOGLE_APPLICATION_CREDENTIALS path; regenerate key if needed |
| "Dataset not found" | Verify BIGQUERY_DATASET exists in the project |
| "Quota exceeded" | Check GCP quotas; may need to request increase |

---

## 4. Common Workflows

### 4.1 Exploratory Data Analysis (EDA)

**In VSCode Copilot Chat:**

```
@bigquery
Analyze the customers dataset:
- Total number of customers
- Distribution across regions
- Average customer lifetime value
- Churn indicators
```

### 4.2 Generate Reports

```
@bigquery
Create a monthly revenue report:
- Total revenue by month for last 12 months
- Top 10 products by revenue
- Revenue growth month-over-month
Format as a summary table
```

### 4.3 Data Quality Checks

```
@bigquery
Run data quality checks on the transactions table:
- Null/missing value counts per column
- Duplicate transaction IDs
- Outliers (transactions >$10k)
- Date range validation
Show which columns need attention
```

### 4.4 Create ML Models

```
@bigquery
Create a linear regression model to predict customer_lifetime_value:
- Use features: account_age, total_purchases, avg_order_value, region
- Train on data from last 2 years
- Show model coefficients and R-squared
```

### 4.5 Time Series Analysis

```
@bigquery
Analyze sales trends:
- Daily revenue for last 90 days
- 7-day moving average
- Identify peak days and anomalies
```

---

## 5. Quota and Cost Management

### 5.1 BigQuery Pricing Model

BigQuery uses **on-demand pricing** by default:

| Component | Cost | Notes |
|-----------|------|-------|
| Query analysis | $6.25/TB | Only data scanned (not stored) |
| Storage | $0.02/GB/month | Standard storage |
| ML predictions | $0.05/1K predictions | For BQML models |
| Export to Cloud Storage | Free | Storing in GCS has separate cost |

### 5.2 Cost Optimization Tips

1. **Use `SELECT *` sparingly** - Specify only needed columns
2. **Use `LIMIT` clauses** for exploration
3. **Partition large tables** by date to scan less data
4. **Consider scheduled queries** during off-peak hours (weekends)
5. **Monitor costs** with BigQuery cost analysis tools

**Monitor Scanned Data:**
```sql
SELECT 
  DATE(creation_time) as query_date,
  SUM(total_bytes_processed) / POW(10, 12) as tb_scanned,
  SUM(total_bytes_billed) / POW(10, 12) as tb_billed,
  ROUND(SUM(total_bytes_billed) / POW(10, 12) * 6.25, 2) as estimated_cost
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE DATE(creation_time) = CURRENT_DATE()
GROUP BY DATE(creation_time);
```

### 5.3 Annual Commitment (Optional)

For predictable workloads, consider Annual Commitments:
- **500 slots/year**: ~$48,000 (saves ~30% vs on-demand)
- Recommended if stable query volume >100TB/month

---

## 6. BigQuery ML (BQML)

### 6.1 Supported Model Types

```sql
-- Linear/Logistic Regression
CREATE OR REPLACE MODEL `project.dataset.model_name`
AS SELECT * FROM `project.dataset.training_data`;

-- Time Series Forecasting (ARIMA)
CREATE OR REPLACE MODEL `project.dataset.forecast_model`
AS SELECT * FROM `project.dataset.time_series_data`;

-- Clustering (K-means)
CREATE OR REPLACE MODEL `project.dataset.segments`
AS SELECT * FROM `project.dataset.customer_data`;
```

### 6.2 Make Predictions

```sql
-- Use trained model to make predictions
SELECT * FROM ML.PREDICT(
  MODEL `project.dataset.model_name`,
  (SELECT * FROM `project.dataset.new_data`)
);
```

---

## 7. Security Best Practices

### 7.1 Service Account Rotation

Regenerate service account keys quarterly:

```bash
# Rotate in Cloud Console:
# 1. Go to IAM & Admin → Service Accounts
# 2. Click service account
# 3. Go to Keys tab
# 4. Delete old key
# 5. Create new key
# 6. Update GOOGLE_APPLICATION_CREDENTIALS in .env
```

### 7.2 Monitoring & Auditing

Enable Cloud Audit Logs:

1. Go to **Cloud Audit Logs** in Console
2. Ensure `BigQuery Admin Read`, `BigQuery Data Read/Write` are enabled
3. View logs:

```bash
gcloud logging read "protoPayload.serviceName=bigquery.googleapis.com" \
  --limit 50 \
  --format json
```

### 7.3 Dataset-Level Security

Use IAM roles for fine-grained access:

```bash
# Grant read-only access to a dataset
gcloud bigquery datasets add-iam-policy-binding \
  my_dataset \
  --member=serviceAccount:analyst@my-project.iam.gserviceaccount.com \
  --role=roles/bigquery.dataViewer
```

---

## 8. Troubleshooting

### Issue: "Query timeout"

**Solution:** BigQuery has a default 600-second timeout. Increase or optimize query:

- Increase timeout in MCP config: `"timeout_ms": 3600000` (1 hour)
- Optimize query: Add `WHERE` clauses, use `LIMIT`, partition tables

### Issue: "Quota exceeded"

**Solution:** Check and manage quotas in Cloud Console:

1. Go to **BigQuery → Admin → Quotas**
2. Review concurrent query and API limits
3. Request increase if needed (can take 24-48 hours)

### Issue: "Permission denied on resource"

**Solution:** Verify service account role assignment:

```bash
# Check service account roles
gcloud projects get-iam-policy my-gcp-project \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:llm-integration@*"
```

### Issue: "Invalid credentials"

**Solution:** 
1. Verify JSON key file exists and is readable
2. Check file permissions: `ls -la ~/.config/gcp/bigquery-service-account.json`
3. Regenerate key if needed (>90 days old)

---

## 9. Next Steps

1. ✅ Complete setup above
2. 🔄 Test connection with simple query
3. 🔄 Integrate with Atlassian (see [Atlassian MCP Setup](ATLASSIAN_SETUP.md)) to document findings
4. 🔄 Create example ML models for your use cases
5. 📊 Set up cost monitoring dashboards

---

## Resources

- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [BigQuery Standard SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql)
- [BigQuery ML Documentation](https://cloud.google.com/bigquery-ml/docs)
- [GCP IAM Roles](https://cloud.google.com/iam/docs/understanding-roles)
- [MCP Documentation](https://modelcontextprotocol.io/docs)
- [VSCode + Copilot Integration](https://code.visualstudio.com/docs/copilot)
