# Atlassian MCP Integration Setup

## Overview

This guide helps you set up Jira and Confluence integration with the cursor-marketplace via MCP (Model Context Protocol). Once configured, you can manage issues and create documentation directly from VSCode using Copilot or other LLMs.

**Prerequisites:**
- Atlassian Cloud account with Jira and Confluence
- Admin access to manage API tokens
- VSCode with Copilot extension installed

---

## 1. Atlassian Account Setup

### 1.1 Get Your Atlassian Domain

1. Log into [Atlassian Cloud](https://www.atlassian.com/software/cloud)
2. Your domain is in the URL: `https://YOUR-DOMAIN.atlassian.net`
3. Example: `https://my-company.atlassian.net`
4. Save this for later

### 1.2 Identify Your Projects & Spaces

**Jira Projects:**
1. Go to Jira and navigate to **Projects**
2. Note the project keys (e.g., `DATA`, `ML`, `ENG`)
3. These appear in issue keys like `DATA-123`

**Confluence Spaces:**
1. Go to Confluence and navigate to **Spaces**
2. Note the space keys (appear in URLs like `/wiki/spaces/DATA`)
3. Common keys: `DATA`, `ML`, `ENG`, `SHARED`

---

## 2. Generate API Token

### 2.1 Create API Token

1. Log into [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click **Create API token**
3. Enter label: `VSCode MCP Integration`
4. Click **Create**
5. Copy the generated token (you'll only see it once)
6. Save securely

### 2.2 Alternative: OAuth2 (Recommended for Production)

For production environments, use OAuth2 instead of API tokens:

1. Go to [Atlassian Developer Console](https://developer.atlassian.com/console/myapps)
2. Create a new OAuth2 app
3. Set redirect URI: `http://localhost:8080/callback`
4. Save Client ID and Client Secret
5. Configure in `.env` instead of API token

---

## 3. VSCode Configuration

### 3.1 Add Atlassian Credentials to `.env`

Create or update `.env` in your VSCode workspace root:

```bash
# Atlassian / Jira & Confluence
ATLASSIAN_DOMAIN=my-company.atlassian.net
ATLASSIAN_EMAIL=your-email@my-company.com
ATLASSIAN_API_TOKEN=your_api_token_here
ATLASSIAN_JIRA_PROJECT_KEYS=DATA,ML,ENG
ATLASSIAN_CONFLUENCE_SPACE_KEYS=DATA,ML,ENG,SHARED
```

**Security Best Practice:**
- Add `.env` to `.gitignore`
- Rotate API tokens quarterly
- Use OAuth2 for production
- Never commit API tokens to git

### 3.2 Configure MCP in VSCode Settings

Open `.vscode/settings.json` and add:

```json
{
  "mcp.servers": {
    "atlassian": {
      "command": "node",
      "args": ["path/to/atlassian-mcp-server.js"],
      "env": {
        "ATLASSIAN_DOMAIN": "${env:ATLASSIAN_DOMAIN}",
        "ATLASSIAN_EMAIL": "${env:ATLASSIAN_EMAIL}",
        "ATLASSIAN_API_TOKEN": "${env:ATLASSIAN_API_TOKEN}",
        "ATLASSIAN_JIRA_PROJECT_KEYS": "${env:ATLASSIAN_JIRA_PROJECT_KEYS}",
        "ATLASSIAN_CONFLUENCE_SPACE_KEYS": "${env:ATLASSIAN_CONFLUENCE_SPACE_KEYS}"
      }
    }
  }
}
```

---

## 4. Testing the Connection

### 4.1 Quick Connection Test

In VSCode, open Copilot chat and try:

```
@atlassian
Show me all open issues in the DATA project assigned to me
```

Expected response: List of open DATA-* issues assigned to you.

### 4.2 Common Connection Issues

| Issue | Solution |
|-------|----------|
| "Invalid domain" | Verify ATLASSIAN_DOMAIN (e.g., `my-company.atlassian.net`, not `https://`) |
| "Unauthorized" | Check ATLASSIAN_EMAIL and ATLASSIAN_API_TOKEN; regenerate token if needed |
| "Project not found" | Verify ATLASSIAN_JIRA_PROJECT_KEYS includes the project; check spelling |
| "Permission denied" | Ensure your account has access to the project/space |
| "Rate limit exceeded" | Wait 1 minute; API limit is 120 calls/minute per endpoint |

---

## 5. Common Workflows

### 5.1 Create Issue from Analysis

**In VSCode Copilot Chat:**

```
@atlassian
I found a data quality issue in our customer table:
- 15% of email addresses are missing
- 200+ duplicate customer IDs
Create a DATA project issue to track this fix.
Assign to @john and label as data-quality
```

**Result:** Jira issue created and assigned.

### 5.2 Document Analysis Results

```
@atlassian
I just analyzed Q4 revenue trends:
- 12% growth month-over-month
- Top 5 products account for 60% of revenue
- High seasonality in Oct-Dec

Create a Confluence page in the DATA space to document these findings.
Include a summary and recommendations.
```

**Result:** Confluence page created with findings.

### 5.3 Link Code Changes to Issues

```
@atlassian
I just committed a fix for customer segmentation (commit abc123).
Find the DATA project issue about this and:
- Link the commit
- Add a comment: "Fix implemented, pending QA testing"
- Move to "In Progress" status
```

### 5.4 Track Model Development

```
@atlassian
Create an ML project issue for a new churn prediction model:
- Type: Task
- Summary: "Build churn prediction model - 90% AUC target"
- Description: Include feature set, data sources, evaluation metrics
- Assign to @maria
- Set due date: 2 weeks
```

### 5.5 Consolidate Findings into Runbook

```
@atlassian
Document a troubleshooting runbook for data pipeline failures:
- Common causes (source DB unavailable, API rate limit, schema mismatch)
- Symptoms and detection
- Resolution steps
Create in Confluence (DATA space) and link to ENG project issues
```

---

## 6. Jira Configuration Best Practices

### 6.1 Project Structure

Set up Jira projects by domain:

- **DATA Project**: Data engineering tasks, pipeline issues, schema changes
- **ML Project**: Model development, training jobs, experiment tracking
- **ENG Project**: Infrastructure, deployment, DevOps tasks

### 6.2 Custom Fields for Data Work

Create custom fields to track data-specific metadata:

```
Custom Field: Data Source
Type: Dropdown
Options: Snowflake, BigQuery, CSV, API, Database

Custom Field: Data Volume (GB)
Type: Number
Description: Size of data involved in issue

Custom Field: SLA (hours)
Type: Number
Description: Service level agreement for resolution

Custom Field: Related Dataset
Type: Text
Description: Dataset/table names affected
```

### 6.3 Workflow Configuration

Create workflow for data issues:

```
Open → In Progress → QA Testing → Done
└─ Data Quality Check
└─ Performance Validation
└─ Documentation
```

---

## 7. Confluence Documentation Standards

### 7.1 Page Structure

Use consistent structure for data documentation:

```markdown
# [Dataset/Process Name]

## Overview
Brief description and purpose

## Schema / Structure
Table of columns, data types, descriptions

## Data Sources
Where data originates, update frequency

## Key Metrics
Important KPIs and their definitions

## Known Issues
Current data quality or access problems

## Related Systems
Links to dependent processes/dashboards

## Runbook
Troubleshooting and common issues
```

### 7.2 Create Page Templates

In Confluence, create templates for:
- **Dataset Documentation**
- **Pipeline Runbook**
- **Analysis Report**
- **Data Quality Report**

---

## 8. Integration Examples

### 8.1 Query Snowflake → Create Issue → Document in Confluence

```
Workflow:
1. @snowflake Query customer data for anomalies
2. @atlassian Create DATA project issue: "Investigate customer anomaly"
3. @atlassian Create Confluence page with findings
4. @atlassian Link issue to documentation
```

### 8.2 Model Training → Track Progress → Document Results

```
Workflow:
1. @atlassian Create ML issue: "Train churn prediction model"
2. Create Confluence page for model documentation
3. @atlassian Update issue with training progress
4. Document final results and metrics in Confluence
5. Link issue to documentation
```

### 8.3 Data Quality Monitoring → Alert → Create Issue

```
Workflow:
1. @bigquery Run daily data quality checks
2. @atlassian Create DATA issue if anomalies detected
3. Assign to data owner
4. Track resolution in Jira
5. Document lessons learned in Confluence
```

---

## 9. Security Best Practices

### 9.1 API Token Management

- **Rotate quarterly**: Generate new token, update .env, delete old token
- **Scope minimally**: Only grant necessary permissions
- **Monitor usage**: Check API token activity in account settings
- **Revoke unused**: Delete tokens for old integrations

**Rotate Token:**
1. Go to [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click three dots next to token
3. Select **Delete**
4. Generate new token
5. Update in `.env`

### 9.2 Project Permissions

Set appropriate permissions per project:

```
DATA Project:
- Data Engineers: Full access
- Analytics: Read-only
- Executives: View dashboards only

ML Project:
- Data Scientists: Full access
- MLOps: Write access (deployment)
- Management: View-only
```

### 9.3 Audit Logging

Enable activity tracking:

1. Go to **Settings → Audit Log**
2. Review API token usage
3. Monitor issue creation/updates from integrations
4. Set alerts for unusual activity

---

## 10. Troubleshooting

### Issue: "Rate limit exceeded"

**Solution:** Atlassian API limits are 120 requests/minute per endpoint. Space out bulk operations.

```bash
# Recommended: Add delays between bulk operations
for issue in list:
  create_issue(issue)
  sleep(1)  # 1 second between requests
```

### Issue: "Issue key not found"

**Solution:** Ensure project key is correct. Check in Jira URL:
- URL: `https://my-company.atlassian.net/browse/DATA-123`
- Project key: `DATA`

### Issue: "Permission denied"

**Solution:** Verify your account has access:

1. Go to Jira/Confluence
2. Check you can manually view the project/space
3. If not, request access from project admin
4. Verify API token has correct permissions

### Issue: "Cannot create issue - required fields missing"

**Solution:** Different projects have different required fields. Check project configuration:

1. Go to Jira project → **Settings**
2. Look at **Issue Types**
3. Click issue type to see required fields
4. Provide all required fields in `create_issue` command

---

## 11. Advanced: Custom Field Mapping

For complex workflows, map custom fields:

```json
{
  "custom_fields": {
    "Data Volume (GB)": 10750,
    "SLA (hours)": 24,
    "Data Source": "Snowflake",
    "Related Dataset": "customers.prod.events"
  }
}
```

Retrieve custom field IDs:

```bash
curl -u email:token https://my-company.atlassian.net/rest/api/3/projects/DATA/fields \
  -H "Accept: application/json"
```

---

## 12. Next Steps

1. ✅ Complete setup above
2. 🔄 Test connection with simple issue search
3. 🔄 Integrate with Snowflake (see [Snowflake MCP Setup](SNOWFLAKE_SETUP.md))
4. 🔄 Integrate with BigQuery (see [BigQuery MCP Setup](BIGQUERY_SETUP.md))
5. 📊 Create example workflows combining query → issue → documentation
6. 📋 Set up project templates and custom fields

---

## Resources

- [Atlassian API Documentation](https://developer.atlassian.com/cloud)
- [Jira API Reference](https://developer.atlassian.com/cloud/jira/rest/v3)
- [Confluence API Reference](https://developer.atlassian.com/cloud/confluence/rest/v2)
- [OAuth2 Setup](https://developer.atlassian.com/cloud/jira/software/oauth-2-3lo-apps)
- [MCP Documentation](https://modelcontextprotocol.io/docs)
- [VSCode + Copilot Integration](https://code.visualstudio.com/docs/copilot)
