# FAQ & Troubleshooting

Comprehensive Q&A and troubleshooting for cursor-marketplace setup and usage.

---

## Quick Diagnosis

**Getting started?** → See [Installation & Quick Start](#installation--quick-start)
**Something broken?** → Jump to [By Platform](#by-platform) for your specific integration
**General questions?** → See [Common Questions](#common-questions)

---

## Installation & Quick Start

### Q: Which branch should I use?

**A:** Choose based on your needs:

- **Main branch** (default): Knowledge-first, static documentation
  - Best for: Learning, reference, teams using manual workflows
  - Setup: Just clone; no additional configuration
  - Files: rules/, skills/, prompts/, templates/

- **execution-optional branch**: Agents, commands, integrations
  - Best for: LLM-native teams wanting automation
  - Setup: 30-45 minutes (configure agents, integrations)
  - Files: agents/, commands/, integrations/, hooks/

**Answer:** Start with `main` for knowledge. Switch to `execution-optional` when ready for automation.

### Q: Do I need to set up all integrations?

**A:** No. Set up only what you need:

- **Just exploring data?** → Snowflake + BigQuery only
- **Tracking work in Jira?** → Atlassian only
- **Full automation?** → All three (Snowflake + BigQuery + Atlassian)

You can add integrations incrementally.

### Q: Can I use this without VSCode?

**A:** Yes, but with limitations:

- **Cursor** (native integration): Full support, same as VSCode
- **Claude Code**: Use agents/commands by pasting content
- **Generic LLM (ChatGPT, Claude.ai)**: Copy agent files, reference in prompts
- **Enterprise LLM platforms**: Use MCP servers with your platform

**Recommended:** VSCode for best native integration + Copilot support.

---

## By Platform

### Snowflake

#### "Invalid account identifier"

**Problem:** Snowflake connection fails with "Invalid account identifier" error.

**Cause:** SNOWFLAKE_ACCOUNT format is incorrect.

**Solution:**
1. Open [Snowflake web interface](https://app.snowflake.com)
2. Click your account name (top-left)
3. Copy the account identifier (format: `xy12345.us-east-1.azure`)
4. Update `.env`: `SNOWFLAKE_ACCOUNT=xy12345.us-east-1.azure`
5. Test: `@snowflake Show me the schemas in my database`

**Example accounts:**
- Azure: `xy12345.us-east-1.azure`
- AWS: `xy12345.us-east-1`
- GCP: `xy12345.us-central1.gcp`

#### "Unauthorized: user, role not authorized"

**Problem:** Queries fail with "user 'llm_service' not authorized" or similar.

**Cause:** Service account lacks necessary permissions.

**Solution:**
1. Log into Snowflake as ACCOUNTADMIN
2. Grant warehouse access:
   ```sql
   GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE LLM_ANALYST;
   ```
3. Grant database/schema access:
   ```sql
   GRANT USAGE ON DATABASE ANALYTICS TO ROLE LLM_ANALYST;
   GRANT USAGE ON SCHEMA ANALYTICS.PUBLIC TO ROLE LLM_ANALYST;
   GRANT SELECT ON ALL TABLES IN SCHEMA ANALYTICS.PUBLIC TO ROLE LLM_ANALYST;
   ```
4. Re-test query

See [SNOWFLAKE_SETUP.md](integrations/SNOWFLAKE_SETUP.md) for full permission setup.

#### "Warehouse not found" or "warehouse suspended"

**Problem:** Queries fail with "Warehouse not found" or "warehouse COMPUTE_WH not found".

**Cause:** Warehouse doesn't exist or is suspended.

**Solution:**
1. Verify warehouse exists: Go to **Admin → Warehouses** in Snowflake UI
2. Check SNOWFLAKE_WAREHOUSE in `.env` matches exactly (case-sensitive)
3. If suspended, resume: Click warehouse → **Resume**
4. Update .env if needed: `SNOWFLAKE_WAREHOUSE=COMPUTE_WH`
5. Re-test query

**Tip:** Set auto-suspend to 10 minutes to minimize idle costs while testing.

#### "Query timeout" or "exceeds maximum query size"

**Problem:** Complex queries timeout or exceed size limits.

**Cause:** Query is too large or takes >10 minutes.

**Solution:**
1. Break into smaller queries:
   ```sql
   -- Instead of:
   SELECT * FROM huge_table WHERE [many complex conditions];
   
   -- Do:
   CREATE TEMPORARY TABLE filtered_data AS
     SELECT * FROM huge_table WHERE [first filter];
   SELECT * FROM filtered_data WHERE [second filter];
   ```

2. Add LIMIT for exploration:
   ```sql
   SELECT * FROM huge_table LIMIT 1000;
   ```

3. Increase timeout in VSCode `.vscode/settings.json`:
   ```json
   {
     "snowflake": {
       "timeout_seconds": 600
     }
   }
   ```

4. Optimize WHERE clauses (avoid full table scans)

5. Increase warehouse size: Use SMALL or MEDIUM for complex queries

#### "High credit usage" or "exceeding budget"

**Problem:** Snowflake queries are using excessive credits/money.

**Cause:** Large warehouse, full table scans, or inefficient queries.

**Solution:**
1. Check query history:
   ```sql
   SELECT TOP 10
     QUERY_TEXT,
     CREDITS_USED,
     EXECUTION_TIME
   FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
   WHERE START_TIME >= DATEADD(hour, -24, NOW())
   ORDER BY CREDITS_USED DESC;
   ```

2. Optimize expensive queries:
   - Add WHERE clauses to reduce scanned data
   - Use LIMIT for exploration
   - Use indexes on frequently filtered columns

3. Reduce warehouse size:
   - Use X-SMALL for development (cheaper)
   - Scale to SMALL/MEDIUM only for production

4. Enable result caching:
   ```sql
   -- Snowflake caches results automatically (7-day default)
   -- Repeated queries use cache (no charge)
   ```

See cost management section in [SNOWFLAKE_SETUP.md](integrations/SNOWFLAKE_SETUP.md).

---

### BigQuery

#### "Project not found" or "Invalid project ID"

**Problem:** BigQuery connection fails with "Project not found".

**Cause:** Project ID is incorrect or malformed.

**Solution:**
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Copy your **Project ID** (format: `my-gcp-project-123456`)
3. Update `.env`: `GOOGLE_PROJECT_ID=my-gcp-project-123456`
4. Test: `@bigquery List all datasets in my project`

**Note:** Project ID (not project number). Look in project selector dropdown.

#### "Permission denied" or "Access denied on resource"

**Problem:** Queries fail with "Permission denied" or "Access denied".

**Cause:** Service account lacks BigQuery permissions.

**Solution:**
1. Go to [Google Cloud Console](https://console.cloud.google.com) → **IAM & Admin**
2. Find your service account (usually named `llm-integration`)
3. Click to edit, check roles:
   - `BigQuery Data Editor` (read/write tables)
   - `BigQuery Job User` (run queries)
   - `BigQuery ML Admin` (create ML models)
4. If missing, click **Add Role** and assign
5. Re-test query (may take 1-2 minutes to propagate)

See [BIGQUERY_SETUP.md](integrations/BIGQUERY_SETUP.md) for detailed IAM setup.

#### "Invalid credentials" or "Could not load the default credentials"

**Problem:** BigQuery connection fails with credentials error.

**Cause:** Service account JSON key file is missing or malformed.

**Solution:**
1. Verify file exists: `ls -la ~/.config/gcp/bigquery-service-account.json`
2. Check file is readable: `cat ~/.config/gcp/bigquery-service-account.json` (should show JSON)
3. Verify path in `.env`: `GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcp/bigquery-service-account.json`
4. If file is missing, regenerate:
   - Go to [Google Cloud Console](https://console.cloud.google.com) → **IAM & Admin → Service Accounts**
   - Click your service account → **Keys → Add Key → Create new key**
   - Select JSON format, download
   - Save to `~/.config/gcp/bigquery-service-account.json`
   - Update `.env`

#### "Query timeout" or "Job exceeded maximum duration"

**Problem:** Queries timeout or exceed duration limits.

**Cause:** Query takes >600 seconds (10 minutes) or exceeds quota.

**Solution:**
1. Optimize query:
   ```sql
   -- Add LIMIT for exploration
   SELECT * FROM dataset.table LIMIT 1000;
   
   -- Filter early in FROM/WHERE
   SELECT * FROM dataset.table
   WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
   LIMIT 10000;
   ```

2. Increase timeout in `.vscode/settings.json`:
   ```json
   {
     "bigquery": {
       "timeout_ms": 1800000
     }
   }
   ```

3. Check concurrent job limit:
   - Go to **BigQuery → Admin → Quotas**
   - Look at "Concurrent queries per user"
   - If hitting limit, wait for other jobs to finish

#### "Quota exceeded" or "Quota enforced"

**Problem:** Queries fail with "Quota exceeded".

**Cause:** Hit API call or data scan limits.

**Solution:**
1. Check quota limits:
   - Go to [Google Cloud Console](https://console.cloud.google.com) → **BigQuery → Admin → Quotas**
   - Review "Concurrent queries" and "API requests"

2. If hitting limits:
   - Request quota increase: Click quota → **Edit Quotas → Request increase**
   - Process takes 24-48 hours
   - Temporary: Reduce concurrent queries or batch operations

3. Monitor data scanned:
   ```sql
   SELECT 
     DATE(creation_time) as query_date,
     SUM(total_bytes_processed) / POW(10, 12) as tb_scanned
   FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
   WHERE DATE(creation_time) = CURRENT_DATE()
   GROUP BY DATE(creation_time);
   ```

See cost management in [BIGQUERY_SETUP.md](integrations/BIGQUERY_SETUP.md).

---

### Atlassian (Jira + Confluence)

#### "Invalid domain" or "Could not reach Atlassian instance"

**Problem:** Atlassian connection fails with domain error.

**Cause:** Domain name is incorrect.

**Solution:**
1. Go to [Atlassian Cloud](https://www.atlassian.com/software/cloud)
2. Look at the URL: `https://YOUR-DOMAIN.atlassian.net`
3. Copy YOUR-DOMAIN
4. Update `.env`: `ATLASSIAN_DOMAIN=YOUR-DOMAIN.atlassian.net`
5. **Important:** Include `.atlassian.net`, not just the domain name
6. Test: `@atlassian List all projects I have access to`

**Example:**
- URL: `https://my-company.atlassian.net/jira/projects`
- Domain: `my-company.atlassian.net`

#### "Unauthorized" or "Invalid credentials"

**Problem:** Jira/Confluence connection fails with "Unauthorized".

**Cause:** API token is invalid or has expired.

**Solution:**
1. Verify API token is valid:
   - Go to [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
   - Check if token exists and hasn't expired
   - Tokens expire after 1 year of inactivity

2. Regenerate token:
   - Go to [API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
   - Click three dots next to old token → **Delete**
   - Click **Create API token**
   - Copy new token (shown only once)
   - Update `.env`: `ATLASSIAN_API_TOKEN=new_token`

3. Verify email is correct:
   - Update `.env`: `ATLASSIAN_EMAIL=your-email@company.com`
   - Must match the account that created the API token

#### "Project not found" or "Invalid project key"

**Problem:** Issue creation fails with "Project not found".

**Cause:** Project key is incorrect or you don't have access.

**Solution:**
1. List available projects:
   ```
   @atlassian
   Show me all projects I have access to
   ```

2. Find correct project key in Jira URL:
   - Example URL: `https://my-company.atlassian.net/browse/DATA-123`
   - Project key: `DATA`

3. Update `.env`: `ATLASSIAN_JIRA_PROJECT_KEYS=DATA,ML,ENG`

4. Verify you have access:
   - Go to Jira project in browser
   - If can't access, ask project admin for access

#### "Cannot create issue - required fields missing"

**Problem:** Issue creation fails with missing required fields.

**Cause:** Different projects have different required fields.

**Solution:**
1. Check project's required fields:
   - Go to Jira project → **Settings → Issue Types**
   - Click issue type (e.g., "Task", "Bug")
   - Note required fields (marked with asterisk)

2. Provide required fields in command:
   ```
   @atlassian
   Create a DATA project issue:
   - Type: Task
   - Summary: "Fix data quality issue"
   - Description: "Null values in customer_email column"
   - Assignee: john@company.com
   - Labels: data-quality
   ```

3. If still fails, check custom fields:
   - Some projects require custom fields (e.g., "Component", "Data Volume")
   - Ask project admin or check issue creation form

#### "Rate limit exceeded"

**Problem:** Bulk operations fail with "Rate limit exceeded".

**Cause:** Atlassian API limits are 120 requests/minute.

**Solution:**
1. Space out requests:
   - Add 1-second delay between operations
   - Or batch in groups of 10-20 with delays

2. Avoid rapid issue creation:
   ```
   # Bad: Creates 50 issues at once
   for i in range(50):
     create_issue()
   
   # Good: Space them out
   for i in range(50):
     create_issue()
     sleep(1)  # 1 second between
   ```

3. If hitting limits regularly, consider:
   - Batch operations during off-hours
   - Request higher API quota from Atlassian (rare)

#### "Cannot find Confluence page" or "Page not found"

**Problem:** Linking to Confluence page fails.

**Cause:** Page ID is incorrect or page doesn't exist.

**Solution:**
1. Find page in Confluence browser:
   - Go to **Spaces → Your Space → Find page**

2. Get page ID from URL:
   - URL: `https://my-company.atlassian.net/wiki/spaces/DATA/pages/123456789/My+Page`
   - Page ID: `123456789` (the long number)

3. Update command with correct page ID:
   ```
   @atlassian
   Link DATA-123 issue to Confluence page 123456789
   ```

---

## Common Questions

### Q: How much will this cost?

**A:** Depends on usage:

**Snowflake:**
- Development: ~$5-20/month (using X-SMALL warehouse)
- Production: $20-200+/month (depends on query volume)
- Cost driver: Warehouse size + data scanned

**BigQuery:**
- Free tier: 1TB/month queries free
- Pay-as-you-go: $6.25/TB of data scanned
- Typical: $10-50/month for moderate usage

**Atlassian:**
- Jira Cloud: Free (up to 10 users)
- Confluence Cloud: Free (up to 10 users)
- Paid plans: Starting at $7/user/month

**Recommendations:**
- Development: Use smallest resource sizes (X-SMALL Snowflake, limited BQ scans)
- Monitor costs: Check Snowflake and BigQuery dashboards weekly
- Set budgets: Use Snowflake resource monitors, GCP budget alerts

### Q: Can I use multiple LLMs (Copilot + Claude + ChatGPT)?

**A:** Yes! The marketplace is LLM-agnostic:

- **VSCode + Copilot**: Native integration (recommended)
- **Claude.ai / ChatGPT web**: Copy agent files, paste in chat
- **Claude Code / Cursor**: Full native support
- **Enterprise LLMs**: Use MCP servers with your platform

**Best practice:** Use one LLM as primary, others as fallback.

### Q: How do I handle sensitive data (PII, secrets)?

**A:** Best practices:

1. **Never paste real data** in LLM chats (even in VSCode with local chat)
2. **Anonymize examples**: Use `customer_123` instead of real names
3. **Mask sensitive columns**: Query without email/SSN/credit card columns
4. **Use service accounts**: Create dedicated, read-only accounts for LLM access
5. **Audit logs**: Monitor who/what is queried (Snowflake, BigQuery audit logs)
6. **Data residency**: Ensure data stays in your cloud (Snowflake in Azure, BigQuery in GCP)

See security sections in each setup guide.

### Q: What if I only use one data platform (Snowflake OR BigQuery)?

**A:** That's fine! Set up only what you need:

- **Snowflake only**: Skip BigQuery section in `.vscode/settings.json`
- **BigQuery only**: Skip Snowflake section
- **Add later**: Set up additional platforms whenever ready

No penalty for partial integration.

### Q: Can I modify agents or create custom agents?

**A:** Yes, absolutely!

1. **Modify existing agents**: Copy to your project, edit
2. **Create custom agents**: Follow [agents/README.md](../agents/README.md)
3. **Share improvements**: Submit pull request to cursor-marketplace

See [CONTRIBUTING.md](../CONTRIBUTING.md) for contribution guidelines.

### Q: How do I update to latest marketplace version?

**A:** If using as git submodule:

```bash
# In your project root
cd .marketplace (or your submodule path)
git pull origin execution-optional
cd ..
git add .marketplace
git commit -m "Update marketplace to latest"
```

Or for direct clone:

```bash
cd cursor-marketplace
git pull origin execution-optional
```

**Note:** Check [CHANGELOG.md](../CHANGELOG.md) for breaking changes before updating.

### Q: What's the difference between "rules" and "agents"?

**A:**

- **Rules** (static, in `rules/`): Always-on constraints applied by LLM
  - No execution, no cost
  - Better for: Learning, reference, manual workflows

- **Agents** (dynamic, in `agents/`): Specialist LLM personas that actively review
  - Require LLM (Copilot, Claude, etc.)
  - Better for: Automated feedback, code review, validation

**Choose:** Rules for lightweight; agents for automation.

---

## Still Stuck?

### Get Help

1. **Check specific setup guide:**
   - [SNOWFLAKE_SETUP.md](integrations/SNOWFLAKE_SETUP.md)
   - [BIGQUERY_SETUP.md](integrations/BIGQUERY_SETUP.md)
   - [ATLASSIAN_SETUP.md](integrations/ATLASSIAN_SETUP.md)

2. **Check logs:**
   - VSCode output: `View → Output → [integration name]`
   - LLM error messages: Usually contain specific issue

3. **Ask LLM for help:**
   ```
   I'm getting error: [paste full error message]
   Help me debug this
   ```

4. **Contact team:**
   - Slack channel: #cursor-marketplace
   - Email: [team contact]
   - GitHub issues: [link to repo]

### Report a Bug

Found a bug? Open an issue on GitHub with:
- Exact error message
- Steps to reproduce
- Your setup (VSCode version, Copilot version, etc.)
- `.env` settings (sanitized, no credentials)
