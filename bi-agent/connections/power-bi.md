[← ClowdBI](../README.md) · [← Connecting a BI source](README.md)

# Power BI

**On this page:** [What you need](#what-you-need) · [Granting Build permission](#granting-build-permission) · [Connecting](#connecting) · [Picking datasets](#picking-datasets) · [What the agent can do](#what-the-agent-can-do) · [Troubleshooting](#troubleshooting)

Power BI connects through **Microsoft sign-in** — you authorise ClowdBI as yourself, and it queries as you. There is no secret to create, paste, or rotate.

## What you need

An account that has **Build** permission on every dataset you want to ask questions about.

Build is the permission that allows querying a dataset's model, as opposed to merely viewing a report built on it. Read access alone is not enough.

> [!TIP]
> If you hold **Workspace Admin**, **Member**, or **Contributor** on the workspace, you already have Build on its datasets. Nothing further to configure.

## Granting Build permission

If you have Viewer access, or you are setting up a dedicated account, grant Build explicitly:

1. In the Power BI service, open the workspace containing the dataset.
2. Find the dataset in the list (not the report — the **semantic model** / dataset entry).
3. Open its **⋯** menu → **Manage permissions**.
4. Click **Add user**, enter the account, and tick **Build**.
5. Click **Add**.

Repeat for each dataset you intend to connect, or grant workspace-level **Contributor** to cover all of them at once.

<!-- Screenshot: ![Power BI Manage permissions dialog with Build ticked](../images/powerbi-build-permission.png) -->

> [!NOTE]
> **Which account should you connect?** For a personal exploration project, your own is fine. For a shared team project, consider a dedicated read-only account granted Build on exactly the datasets in scope — it survives people leaving and keeps the boundary explicit. See [Choosing the right account](README.md#choosing-the-right-account).

## Connecting

1. In your data project, click **Connect Power BI**.
2. You are redirected to Microsoft sign-in. Authenticate with the account you want to connect.
3. Review and accept the requested permissions.
4. You are returned to ClowdBI — *"Power BI connected. Now pick the datasets to connect."*

<!-- Screenshot: ![Power BI connect card](../images/connect-powerbi-card.png) -->

ClowdBI stores an encrypted refresh token and mints a short-lived access token for each query. The refresh token never leaves the engine and is **never sent to the AI model** — see [Where your credentials live](../data-privacy.md#where-your-credentials-live).

If the connection is refused, you get *"Connection failed"* — see [Troubleshooting](#troubleshooting).

## Picking datasets

Datasets are listed grouped by **workspace**. Select the ones the agent should be able to query and click **Connect *N* datasets**.

Only datasets the connected account has Build on are queryable. A dataset visible but not Build-granted will fail at query time rather than at selection.

## What the agent can do

| | |
| --- | --- |
| **Query language** | DAX — visible under **Show query** on any answer |
| **Stored measures** | Read from your model, with their descriptions and format strings |
| **Relationships** | Read from your model and used to join within the dataset |
| **Cross-dataset links** | Supported, including to Looker and Tableau models in the same project |
| **Row limits** | Provider caps of 100,000 rows / 15 MB per query. The agent writes aggregating queries, so this is rarely reached |

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| *"Connection failed"* after Microsoft sign-in | Consent was declined, or your tenant blocks third-party app consent | Retry and accept; if it persists, an Entra administrator may need to approve the app |
| Dataset list is empty | The account has no workspace access | Add it to the relevant workspace |
| A specific dataset errors on query | Missing **Build** on that dataset | [Grant Build](#granting-build-permission) and retry |
| *"the model has no measures"* | The account cannot enumerate measures, or the model genuinely defines none | Check Build permission first. If the model truly has no measures, the agent computes aggregates inline instead — this works, it just cannot use pre-defined business logic |
| Queries fail after working for weeks | The refresh token was revoked (password change, admin revocation, conditional-access policy) | Reconnect |

> [!TIP]
> If answers look wrong rather than failing, the cause is usually the model rather than the connection — see [Asking good questions](../asking-good-questions.md).
