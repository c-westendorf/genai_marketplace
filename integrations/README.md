# Integrations

This directory contains MCP (Model Context Protocol) configurations and setup guides for connecting cursor-marketplace with external data platforms and tools.

## Quick Reference

| Integration | Purpose | Setup Time | Complexity |
|-------------|---------|------------|-----------|
| **[Snowflake](#snowflake)** | Data warehouse queries, transformations, profiling | 30 min | Intermediate |
| **[BigQuery](#bigquery)** | Analytics, ML model creation, data exploration | 30 min | Intermediate |
| **[Atlassian](#atlassian)** | Jira issue tracking, Confluence documentation | 20 min | Easy |

---

## Snowflake

Connect to your Azure Snowflake data warehouse for querying, transformation, and data profiling.

**What you can do:**
- Execute SQL queries and retrieve results
- Introspect database schemas and table structures
- Generate data profiles and quality statistics
- Create temporary tables for analysis
- Monitor query costs and warehouse usage

**Setup:** [Snowflake MCP Setup Guide](SNOWFLAKE_SETUP.md)

**Example:**
```
@snowflake
Query the CUSTOMERS table and show me customer segments with their average lifetime value.
```

**Files:**
- [mcp-configs/snowflake.json](mcp-configs/snowflake.json) - Configuration
- [SNOWFLAKE_SETUP.md](SNOWFLAKE_SETUP.md) - Setup and usage guide

---

## BigQuery

Connect to Google Cloud BigQuery for analytics, ML model creation, and exploratory data analysis.

**What you can do:**
- Execute Standard SQL queries across datasets
- List and explore datasets and tables
- Create BigQuery ML models (regression, classification, time series, clustering)
- Generate data profiles and statistics
- Export results to Cloud Storage
- Monitor query costs and quota usage

**Setup:** [BigQuery MCP Setup Guide](BIGQUERY_SETUP.md)

**Example:**
```
@bigquery
Create a linear regression model to predict customer_lifetime_value using
account_age, total_purchases, avg_order_value, and region as features.
Show model coefficients and R-squared.
```

**Files:**
- [mcp-configs/bigquery.json](mcp-configs/bigquery.json) - Configuration
- [BIGQUERY_SETUP.md](BIGQUERY_SETUP.md) - Setup and usage guide

---

## Atlassian

Connect to Jira and Confluence for issue tracking and knowledge management.

**What you can do:**
- Search, create, and update Jira issues
- Create and update Confluence documentation pages
- Link Jira issues to Confluence pages
- Add comments and labels to issues
- Transition issues through workflows
- Organize documentation in spaces

**Setup:** [Atlassian MCP Setup Guide](ATLASSIAN_SETUP.md)

**Example:**
```
@atlassian
Create a DATA project issue: "Investigate high null rate in customer emails"
Assign to @john, label as "data-quality", and create a Confluence page
documenting the findings.
```

**Files:**
- [mcp-configs/atlassian.json](mcp-configs/atlassian.json) - Configuration
- [ATLASSIAN_SETUP.md](ATLASSIAN_SETUP.md) - Setup and usage guide

---

## Installation & Configuration

### 1. Environment Setup

Copy credentials to `.env` in your VSCode workspace (gitignore this file):

```bash
# Snowflake (Azure region)
SNOWFLAKE_ACCOUNT=xy12345.us-east-1.azure
SNOWFLAKE_USER=llm_service
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=ANALYTICS
SNOWFLAKE_SCHEMA=PUBLIC

# BigQuery (GCP)
GOOGLE_PROJECT_ID=my-gcp-project
GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcp/bigquery-service-account.json
BIGQUERY_DATASET=analytics
BIGQUERY_LOCATION=US

# Atlassian (Jira + Confluence)
ATLASSIAN_DOMAIN=my-company.atlassian.net
ATLASSIAN_EMAIL=your-email@my-company.com
ATLASSIAN_API_TOKEN=your_api_token
ATLASSIAN_JIRA_PROJECT_KEYS=DATA,ML,ENG
ATLASSIAN_CONFLUENCE_SPACE_KEYS=DATA,ML,ENG
```

### 2. VSCode MCP Configuration

Edit `.vscode/settings.json` to enable integrations:

```json
{
  "mcp.servers": {
    "snowflake": {
      "command": "node",
      "args": ["path/to/snowflake-mcp-server.js"],
      "env": {
        "SNOWFLAKE_ACCOUNT": "${env:SNOWFLAKE_ACCOUNT}",
        "SNOWFLAKE_USER": "${env:SNOWFLAKE_USER}",
        "SNOWFLAKE_PASSWORD": "${env:SNOWFLAKE_PASSWORD}",
        "SNOWFLAKE_WAREHOUSE": "${env:SNOWFLAKE_WAREHOUSE}",
        "SNOWFLAKE_DATABASE": "${env:SNOWFLAKE_DATABASE}",
        "SNOWFLAKE_SCHEMA": "${env:SNOWFLAKE_SCHEMA}"
      }
    },
    "bigquery": {
      "command": "node",
      "args": ["path/to/bigquery-mcp-server.js"],
      "env": {
        "GOOGLE_PROJECT_ID": "${env:GOOGLE_PROJECT_ID}",
        "GOOGLE_APPLICATION_CREDENTIALS": "${env:GOOGLE_APPLICATION_CREDENTIALS}",
        "BIGQUERY_DATASET": "${env:BIGQUERY_DATASET}",
        "BIGQUERY_LOCATION": "${env:BIGQUERY_LOCATION}"
      }
    },
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

### 3. Run Connection Tests

In VSCode Copilot chat, test each integration:

```
# Snowflake
@snowflake
Show me the schemas in my default database

# BigQuery
@bigquery
List all datasets in my project

# Atlassian
@atlassian
Show me all open issues assigned to me
```

---

## Common Workflows

### 1. Query Data → Create Issue → Document

**Scenario:** You discover a data quality issue while exploring.

```
Step 1: @snowflake Query CUSTOMERS table and check for anomalies
Step 2: @atlassian Create DATA project issue: "Fix customer data anomalies"
Step 3: @atlassian Create Confluence page documenting the issue
Step 4: @atlassian Link issue to documentation
```

### 2. Analytics → Model → Track Progress

**Scenario:** You're building a predictive model.

```
Step 1: @bigquery Create LINEAR_REG model for churn prediction
Step 2: @atlassian Create ML project issue: "Churn prediction model v1"
Step 3: @atlassian Create Confluence page with model details
Step 4: @atlassian Update issue with training results and metrics
```

### 3. Daily Data Quality Checks

**Scenario:** Monitor data health across platforms.

```
Step 1: @snowflake Run quality checks on critical tables
Step 2: @bigquery Verify data freshness in key datasets
Step 3: @atlassian Create issue if problems found
Step 4: @atlassian Document in Confluence runbook for resolution
```

---

## Security & Best Practices

### Credential Management

- **Never commit credentials**: Always add `.env` to `.gitignore`
- **Rotate regularly**: Refresh API tokens and passwords quarterly
- **Use service accounts**: Create dedicated LLM service accounts with minimal permissions
- **Monitor access**: Review audit logs for unusual activity

### Access Control

- **Limit permissions**: Grant only necessary access (read-only when possible)
- **Project-specific roles**: Use Jira/Confluence roles to limit scope
- **Cost controls**: Set Snowflake warehouse limits; monitor BigQuery quota
- **Review regularly**: Audit who has access to what data

### Development vs. Production

| Aspect | Development | Production |
|--------|-------------|-----------|
| **Credentials** | Shared service account | Separate per environment |
| **Warehouse Size** | X-SMALL (minimal cost) | SMALL/MEDIUM (performance) |
| **Query Limits** | None | Enforce timeout/row limits |
| **Approvals** | Ad hoc | Documented/tracked |

---

## Troubleshooting

### Connection Issues

**Snowflake:**
- Check SNOWFLAKE_ACCOUNT format (e.g., `xy12345.us-east-1.azure`)
- Verify service account exists and has warehouse access
- Ensure network allows Snowflake connections

**BigQuery:**
- Verify GOOGLE_APPLICATION_CREDENTIALS file exists
- Check service account has BigQuery Data Editor role
- Confirm project ID is correct

**Atlassian:**
- Test API token in browser: `https://my-company.atlassian.net/api/3/myself`
- Verify user has access to project/space
- Check API token hasn't expired

### Performance Issues

**Snowflake:**
- Queries slow? Check warehouse size (upgrade if needed)
- Use `LIMIT` for exploration; full table scans cost credits
- Enable query result caching

**BigQuery:**
- Queries timeout? Increase timeout in MCP config
- Check if query scans large data (optimize WHERE clauses)
- Use `LIMIT` for exploration

---

## FAQ

**Q: Can I use these integrations without Copilot?**
A: Yes, MCP servers work with any LLM that supports the protocol (Claude, GPT, Gemini, etc.). See [EXECUTION_SETUP.md](../EXECUTION_SETUP.md) for other LLM configurations.

**Q: How do I know how much my queries cost?**
A: 
- **Snowflake**: Monitor with `SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY`
- **BigQuery**: Use BigQuery cost analysis in Cloud Console

**Q: Can I create custom fields in Jira?**
A: Yes. Go to Jira project settings → Issue Types → Custom Fields. Map in Atlassian MCP config.

**Q: What if I need a different data platform?**
A: Create a new MCP config following the same pattern. Contact the team for additional integrations.

**Q: How do I rotate my API tokens?**
A: See security sections in [SNOWFLAKE_SETUP.md](SNOWFLAKE_SETUP.md), [BIGQUERY_SETUP.md](BIGQUERY_SETUP.md), or [ATLASSIAN_SETUP.md](ATLASSIAN_SETUP.md).

---

## Next Steps

1. **Choose an integration** based on your immediate needs
2. **Follow the setup guide** for that platform
3. **Test the connection** with a simple query
4. **Create a workflow** combining multiple integrations
5. **Share learnings** with your team

## Resources

- [Model Context Protocol (MCP) Docs](https://modelcontextprotocol.io/docs)
- [Snowflake Documentation](https://docs.snowflake.com)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [Atlassian API Documentation](https://developer.atlassian.com/cloud)
- [VSCode Copilot Guide](https://code.visualstudio.com/docs/copilot)
