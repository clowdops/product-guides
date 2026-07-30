[← ClowdBI](../README.md) · [← Connecting a BI source](README.md)

# Tableau

**On this page:** [What you need](#what-you-need) · [Creating a Personal Access Token](#creating-a-personal-access-token) · [Connecting](#connecting) · [Picking data sources](#picking-data-sources) · [Tableau has no stored measures](#tableau-has-no-stored-measures) · [Token expiry](#token-expiry) · [Troubleshooting](#troubleshooting)

Tableau connects with a **Personal Access Token (PAT)** belonging to a Tableau user. ClowdBI queries as that user through the VizQL Data Service.

## What you need

- Your Tableau **server URL** — for example `https://10ay.online.tableau.com`
- The **site** name, if you are not on the default site
- A **Personal Access Token** name and secret
- The published data sources you want to query must allow **API Access**

## Creating a Personal Access Token

1. In Tableau, click your avatar → **My Account Settings**.
2. Scroll to **Personal Access Tokens**.
3. Enter a descriptive **token name** (for example `clowdbi`) and click **Create Token**.
4. Copy the **secret** — it is shown once and cannot be retrieved later.

<!-- Screenshot: ![Tableau Account Settings — Personal Access Tokens section](../images/tableau-pat-creation.png) -->

> [!NOTE]
> PATs are disabled at site level on some deployments. If you do not see the section, a Tableau site administrator must enable personal access tokens first.

### API Access on data sources

The published data sources you connect need the **API Access** capability for the token's user. Without it the connection succeeds but queries fail.

Check it on each data source: open it in Tableau → **Actions → Permissions**, and confirm the user or their group is allowed **API Access**.

## Connecting

1. In your data project, click **Add connection → Tableau** (or **Connect Tableau**).
2. Fill in the dialog:

| Field | Value |
| --- | --- |
| **Server URL** | For example `https://10ay.online.tableau.com` |
| **Site** | The site name from your Tableau URL. Leave empty for the Tableau Server default site |
| **PAT name** | The token name you chose |
| **PAT secret** | The secret you copied |

3. Choose **Who can query with this connection?** — see [Who can query](../data-projects.md#who-can-query--shared-or-personal-access).
4. Click connect. You should see *"Tableau connected"*.

<!-- Screenshot: ![Connect Tableau dialog — server, site, PAT name and secret](../images/connect-tableau-form.png) -->

> [!TIP]
> **Finding your site name.** In a Tableau Cloud URL like `https://10ay.online.tableau.com/#/site/acmeanalytics/…`, the site is `acmeanalytics`. If your URL has no `/site/` segment, you are on the default site — leave the field empty.

The secret is encrypted at rest, decrypted only inside the engine, and **never sent to the AI model** — see [Where your credentials live](../data-privacy.md#where-your-credentials-live).

## Picking data sources

Tableau maps onto ClowdBI's vocabulary like this:

| ClowdBI calls it | In Tableau it is |
| --- | --- |
| Workspace | Project |
| Dataset | Published data source |

Only **published data sources** can be connected — workbooks and embedded extracts cannot. If a dataset you expect is missing, it is probably embedded in a workbook rather than published separately.

## Tableau has no stored measures

This is the one behavioural difference worth understanding.

Power BI and Looker models carry **stored measures** — pre-defined business logic like *Net Revenue* or *Margin %*, written once by whoever owns the model. Tableau published data sources do not expose measures this way.

ClowdBI handles this by computing aggregates **inline**: asked for average order value, it writes the average into the query itself. The consequence for you:

- **It works.** Aggregates, durations, and ratios all compute correctly.
- **Under *Show query*** you see aggregate expressions rather than measure names.
- **Business logic is not inherited.** If your organisation defines *Net Revenue* as gross minus returns minus discounts, the agent does not know that unless the data source exposes it as a field or you say so in the question.

> [!TIP]
> For Tableau sources, be explicit about definitions the first time: *"revenue means the `NetAmount` field, not `GrossAmount`"*. Or better, encode the definition as a calculated field in the published data source so every answer inherits it.

## Token expiry

**Tableau PATs idle-expire — 15 days by default.** A token unused for that period stops working, and queries begin failing with authentication errors.

If a connection that used to work starts failing, give it a fresh token: open the data project's **Connections** tab and click **Edit** on the connection. The connect form re-opens pre-filled, so you replace the token and keep everything else — including your dataset selection. Regular use keeps a token alive; a project queried weekly will not hit this, one queried monthly might.

> [!TIP]
> Editing is also the fix for a **wrong Site**. If the connection saved successfully but every query fails, the Site is the first thing to check — it is the segment after `/#/site/` in your Tableau URL, not the name of the PAT. See [Managing an existing connection](README.md#managing-an-existing-connection).

> [!NOTE]
> Power BI and Looker connections refresh automatically in the background. Tableau's idle-expiry is a platform behaviour ClowdBI cannot work around.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| *"Couldn't connect Tableau"* | Wrong server URL, site, or an expired token | Check the site name (see the tip above) and create a fresh PAT |
| Connects, but no data sources listed | The user cannot see any published data source | Check project permissions in Tableau |
| Queries fail with authentication errors after weeks of working | PAT idle-expired | [Create a new PAT](#creating-a-personal-access-token), then **Edit** the connection and paste it in |
| Teammates get nothing from a shared connection | It has not been [published](README.md#publishing-a-shared-connection), or the publication was revoked | Publish it |
| *"Couldn't list datasets for this account."* | Missing **API Access** permission | Grant API Access on the data sources |
| A data source you expect is missing | It is embedded in a workbook, not published | Publish the data source separately |
| Answers use the wrong definition of a metric | No stored measures — see [above](#tableau-has-no-stored-measures) | State the definition in the question, or add a calculated field |
