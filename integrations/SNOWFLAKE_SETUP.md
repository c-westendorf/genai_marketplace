# Snowflake MCP Integration Setup

## Overview

This guide helps you set up Snowflake integration with the cursor-marketplace via MCP (Model Context Protocol). Once configured, you can query your Snowflake data warehouse directly from VSCode using Copilot or other LLMs.

**Prerequisites:**
- Snowflake account (Azure region recommended)
- VSCode with Copilot extension installed
- Service account or user account with appropriate Snowflake permissions

---

## 1. Snowflake Account Setup

### 1.1 Get Your Account Identifier

1. Log into [Snowflake web interface](https://app.snowflake.com)
2. In the top-left corner, click your account name
3. Copy the **Account Identifier** (format: `xy12345.us-east-1.azure`)
4. Save this value for later

### 1.2 Create a Service Account (Recommended)

For LLM integrations, use a dedicated service account with limited permissions:

```sql
-- Execute in Snowflake as ACCOUNTADMIN
CREATE ROLE LLM_ANALYST;

CREATE USER llm_service
  PASSWORD = '<secure-password>'
  DEFAULT_ROLE = LLM_ANALYST
  DEFAULT_WAREHOUSE = COMPUTE_WH;

-- Grant warehouse access
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE LLM_ANALYST;

-- Grant database/schema access (customize to your databases)
GRANT USAGE ON DATABASE ANALYTICS TO ROLE LLM_ANALYST;
GRANT USAGE ON SCHEMA ANALYTICS.PUBLIC TO ROLE LLM_ANALYST;
GRANT SELECT ON ALL TABLES IN SCHEMA ANALYTICS.PUBLIC TO ROLE LLM_ANALYST;

-- Assign role to user
GRANT ROLE LLM_ANALYST TO USER llm_service;
```

**Security Note:** Use separate credentials for development vs. production. Consider using Okta/SSO for production.

---

## 2. VSCode Configuration

### 2.1 Add Snowflake Credentials to `.env`

Create or update `.env` file in your VSCode workspace root:

```bash
# Snowflake Connection
SNOWFLAKE_ACCOUNT=xy12345.us-east-1.azure
SNOWFLAKE_USER=llm_service
SNOWFLAKE_PASSWORD=your_secure_password
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=ANALYTICS
SNOWFLAKE_SCHEMA=PUBLIC
SNOWFLAKE_ROLE=LLM_ANALYST

# Alternative: OAuth2 token (if using OAuth)
# SNOWFLAKE_OAUTH_TOKEN=your_oauth_token
```

**Security Best Practice:** 
- Add `.env` to `.gitignore`
- Use GitHub Secrets for CI/CD environments
- Rotate credentials quarterly
- Use SSO/OAuth for production

### 2.2 Configure MCP in VSCode Settings

Open `.vscode/settings.json` and add:

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
    }
  }
}
```

---

## 3. Testing the Connection

### 3.1 Quick Connection Test

In VSCode, open Copilot chat and try:

```
@snowflake
Show me the schemas in the ANALYTICS database
```

Expected response: List of schemas from your Snowflake ANALYTICS database.

### 3.2 Common Connection Issues

| Issue | Solution |
|-------|----------|
| "Invalid account identifier" | Verify SNOWFLAKE_ACCOUNT format (e.g., `xy12345.us-east-1.azure`) |
| "Invalid username/password" | Check SNOWFLAKE_USER and SNOWFLAKE_PASSWORD in .env; note Snowflake is case-sensitive |
| "Role not authorized" | Verify LLM_ANALYST role has USAGE on target warehouse and database |
| "Network error" | Check if Snowflake IP allowlist includes your network |
| "Warehouse not found" | Verify SNOWFLAKE_WAREHOUSE exists and is active |

---

## 4. Common Workflows

### 4.1 Query Data and Analyze

**In VSCode Copilot Chat:**

```
@snowflake
Query the CUSTOMERS table and show me the distribution of customer segments.
Show row count, count by segment, and average account value per segment.
```

**Result:** Snowflake executes the query; Copilot analyzes and summarizes the findings.

### 4.2 Data Quality Checks

```
@snowflake
Check data quality in the ORDERS table:
- Null counts for each column
- Duplicate order IDs
- Date range validation (order_date between 2023-01-01 and today)
Show which columns have issues
```

### 4.3 Schema Exploration

```
@snowflake
Show me all tables in ANALYTICS.PUBLIC schema with:
- Table name
- Row count (approximate)
- Primary columns
- Last modified date
```

### 4.4 Generate Documentation

```
@snowflake
Document the PRODUCTS table structure:
- Column names and data types
- Non-null constraints
- Foreign key relationships
Then create a Confluence page with this documentation
```

---

## 5. Cost Management

### 5.1 Warehouse Sizing Strategy

| Use Case | Warehouse Size | Est. Cost/Hour | Recommendation |
|----------|---|---|---|
| Development/Testing | `X-SMALL` | ~$2 | Use during development; suspend when not in use |
| Data Exploration | `SMALL` | ~$4 | Default for analytics queries |
| Production Reports | `MEDIUM` | ~$8 | Scale up for scheduled queries |
| Real-time Dashboards | `LARGE` | ~$16 | Only if needed for concurrent users |

### 5.2 Cost Optimization Tips

1. **Suspend warehouses** when not in use (set auto-suspend to 5-10 minutes)
2. **Use X-SMALL warehouse** for development and interactive queries
3. **Enable result caching** for repeated queries (7-day default)
4. **Monitor query performance** to identify slow/expensive queries
5. **Schedule heavy queries** during off-peak hours if possible

**Monitor Costs:**
```sql
SELECT 
  DATE(START_TIME) as query_date,
  SUM(CREDITS_USED) as daily_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE START_TIME >= DATEADD(day, -30, TODAY())
GROUP BY DATE(START_TIME)
ORDER BY query_date DESC;
```

---

## 6. Security Best Practices

### 6.1 Credential Rotation

- Rotate service account password quarterly
- Use `ALTER USER` to update credentials:
  ```sql
  ALTER USER llm_service SET PASSWORD = '<new-password>';
  ```

### 6.2 Monitoring & Auditing

Enable query history and login monitoring:

```sql
-- View login history
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
WHERE USER_NAME = 'llm_service'
ORDER BY EVENT_TIMESTAMP DESC
LIMIT 50;

-- View query execution
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE USER_NAME = 'llm_service'
ORDER BY START_TIME DESC
LIMIT 100;
```

### 6.3 Role-Based Access Control (RBAC)

Create granular roles for different use cases:

```sql
-- Read-only analyst role
CREATE ROLE ANALYST_READONLY;
GRANT SELECT ON ALL TABLES IN SCHEMA ANALYTICS.PUBLIC TO ROLE ANALYST_READONLY;

-- Data science role (with write access)
CREATE ROLE DATA_SCIENTIST;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA ANALYTICS.PUBLIC TO ROLE DATA_SCIENTIST;
GRANT CREATE TABLE ON SCHEMA ANALYTICS.TEMP TO ROLE DATA_SCIENTIST;
```

---

## 7. Troubleshooting

### Issue: "Rate limit exceeded"

**Solution:** Snowflake has query concurrency limits. Reduce concurrent queries or upgrade warehouse size.

```sql
-- Check warehouse load
SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_LOAD_HISTORY
WHERE WAREHOUSE_NAME = 'COMPUTE_WH'
ORDER BY START_TIME DESC;
```

### Issue: "Query timeout"

**Solution:** Increase query timeout or optimize SQL.

- Default timeout: 5 minutes
- Increase in MCP config: `"query_timeout_seconds": 600` (10 minutes)
- Optimize: Add `LIMIT` clauses, create indexes, partition large tables

### Issue: "Insufficient credits"

**Solution:** Monitor warehouse usage and adjust warehouse size or schedule.

```sql
-- Check credit usage by warehouse
SELECT 
  WAREHOUSE_NAME,
  SUM(CREDITS_USED) as total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE DATE(START_TIME) = CURRENT_DATE()
GROUP BY WAREHOUSE_NAME;
```

---

## 8. Next Steps

1. ✅ Complete setup above
2. 🔄 Test connection with simple query
3. 🔄 Integrate with Confluence for documentation (see [Atlassian MCP Setup](ATLASSIAN_SETUP.md))
4. 🔄 Integrate with Jira for issue tracking (see [Atlassian MCP Setup](ATLASSIAN_SETUP.md))
5. 📊 Create example workflows combining Snowflake queries with analysis and documentation

---

## Resources

- [Snowflake Account Identifiers](https://docs.snowflake.com/en/user-guide/admin-account-identifier.html)
- [Snowflake Authentication](https://docs.snowflake.com/en/user-guide/security-authentication.html)
- [Snowflake Query Syntax](https://docs.snowflake.com/en/sql-reference.html)
- [MCP Documentation](https://modelcontextprotocol.io/docs)
- [VSCode MCP Integration](https://code.visualstudio.com/docs/copilot)
