[← ClowdBI](../README.md) · [← Data projects](../data-projects.md) · [The catalog →](../catalog.md)

# Connecting a BI source

**On this page:** [Supported platforms](#supported-platforms) · [Choosing the right account](#choosing-the-right-account) · [Adding a connection](#adding-a-connection) · [Picking datasets](#picking-datasets) · [Managing an existing connection](#managing-an-existing-connection) · [Publishing a shared connection](#publishing-a-shared-connection) · [Revoking a publication](#revoking-a-publication) · [What differs per platform](#what-differs-per-platform) · [Keeping a connection healthy](#keeping-a-connection-healthy)

A **connection** links a [data project](../data-projects.md) to one account on one BI platform. A project can hold several connections, across different platforms.

## Supported platforms

| Platform | Auth method | Setup guide |
| --- | --- | --- |
| **Power BI** | Microsoft sign-in (delegated OAuth) | [Power BI →](power-bi.md) |
| **Looker** | API3 client ID + secret | [Looker →](looker.md) |
| **Tableau** | Personal Access Token | [Tableau →](tableau.md) |

## Choosing the right account

The account you connect is the **hard outer boundary** of what ClowdBI can ever read. No prompt, no agent behaviour, and no misconfiguration can reach past it. This is the layer you control entirely, so it is worth a minute of thought before you connect.

Three principles:

**Read-only, always.** ClowdBI's agent has no tool that writes — but connecting a read-only account means you do not have to take that on trust.

**Scoped to what you intend to expose.** Connect an account that can see the datasets you want asked about and not your whole estate. Narrower is better for answer quality too.

**A service account for shared use.** For a team-wide project, a dedicated service account is easier to reason about and to rotate than a person's credentials, and it does not break when that person leaves.

> [!TIP]
> If row-level security means different people should see different numbers, use **personal access** instead of a shared account — see [Who can query](../data-projects.md#who-can-query--shared-or-personal-access).

> [!IMPORTANT]
> Before connecting a dataset containing personal data, read [Data privacy & personal data](../data-privacy.md). The short version: expose an anonymised identifier column for sensitive entities, and prefer not to connect raw personal data at all.

## Adding a connection

If the project has no connection yet, you land on **Connect your BI source** automatically. Otherwise use **Add connection** on the catalog page.

<!-- Screenshot: ![Connect your BI source — provider cards](../images/connect-choose-provider.png) -->

Pick your platform, complete its flow, and you are returned to the dataset picker.

## Picking datasets

After connecting, ClowdBI lists everything the account can see, grouped by workspace. Tick what you want the agent to query and click **Connect *N* datasets**.

<!-- Screenshot: ![Dataset picker — workspaces with datasets selected](../images/connect-dataset-picker.png) -->

What "workspace" and "dataset" mean depends on the platform:

| Platform | Workspace | Dataset |
| --- | --- | --- |
| **Power BI** | Workspace | Dataset |
| **Looker** | LookML model | Explore |
| **Tableau** | Project | Published data source |

Use **Expand all** / **Collapse all** for large estates; each workspace header shows how many datasets it holds and how many you have selected.

You can return and click **Add datasets** at any time.

### If the list is empty or fails

| What you see | What it usually means |
| --- | --- |
| *"No datasets visible to this account."* | The account has no access to any dataset. Check its permissions on the platform. |
| *"Couldn't list datasets for this account."* | The connection worked but the listing call failed — usually missing API access. See the per-platform guide. |

## Managing an existing connection

Open the data project's **Connections** tab. Every connection the project holds is listed with its provider, its label, and where it points — for Tableau that includes the **site**, for Looker the base URL, for Power BI the account.

<!-- Screenshot: ![Connected sources — connections with scope and publish badges](../images/connections-tab.png) -->

Each row carries a scope badge:

| Badge | Meaning |
| --- | --- |
| **Personal** | Only you query through it. Every teammate connects their own account. |
| **Shared** | The project queries through this one account — once it has been [published](#publishing-a-shared-connection). |

Three actions sit on each row:

| Action | What it does |
| --- | --- |
| **Edit** *(Looker, Tableau)* | Re-opens the connect form, pre-filled. The repair path for a wrong Site or a rotated secret. |
| **Reconnect** *(Power BI)* | Re-authorises through Microsoft sign-in. Power BI has no form to edit — the credential is the OAuth grant. |
| **Remove** | Datasets from this connection stop being queryable. It cannot be undone, but you can reconnect later. |

> [!TIP]
> **Editing is the fix for most connection failures.** A Tableau PAT that idle-expired, a Looker secret that was rotated, a Site entered wrongly at setup — all are repaired by editing the existing connection rather than removing and re-adding it, which would lose your dataset selection.

> [!IMPORTANT]
> For Tableau, the **Site** is the segment after `/#/site/` in your Tableau URL — not the name of the Personal Access Token. Getting these two confused is the single most common setup error, and it produces a connection that saves successfully and then fails on every query.

## Publishing a shared connection

A **shared** connection is not usable the moment it is created. It is *credless* until an owner or administrator explicitly publishes it.

The reason is that a shared connection is the one place where somebody's access can silently become everybody's. A dashboard bound to it is queried with **that connection's** access by **every viewer of the board** — not only the project members who happen to open it. Publishing is where a person takes responsibility for that.

Click the publish action on any unpublished shared connection. Two fields are required:

| Field | What it is for |
| --- | --- |
| **Data classification** | What this connection exposes — for example *internal*, *confidential*. Your organisation's own vocabulary. |
| **"Runs as" label** | A human-readable name for the identity queries run under — for example *Sales shared account*. It is shown to every viewer of a dashboard this connection backs. |

<!-- Screenshot: ![Publish this connection — classification and runs-as label](../images/connection-publish.png) -->

Once published, the connection shows a green **Published** badge and its runs-as label appears beside it.

> [!NOTE]
> **Personal connections are never published**, and the controls do not appear on them. A personal connection is already scoped to the person who created it, so there is nothing to sign off.

| Badge | State |
| --- | --- |
| **Not published** | Shared, but nobody can query through it yet |
| **Published** | Signed off; viewers query through it, running as the stated label |
| **Revoked** | Previously published, now withdrawn |

## Revoking a publication

Revoking withdraws the sign-off. It takes effect **immediately**: the connection goes credless and no viewer can query through it until it is published again.

You may record an optional reason, which is worth doing — the next person to look at a revoked connection will want to know whether it was withdrawn because the account was over-scoped, because the classification was wrong, or because somebody was testing.

Dashboards bound to the connection stop returning data until it is republished. That is the intended behaviour: revocation is what you reach for when the access behind a board turns out to be broader than it should have been.

## What differs per platform

Everything below is handled for you; it is here so the differences you *notice* make sense.

| | Power BI | Looker | Tableau |
| --- | --- | --- | --- |
| **Query language shown under *Show query*** | DAX | Looker query | VizQL request |
| **Stored measures** | Yes | Yes (LookML) | **No** — see below |
| **Cross-dataset links** | Supported | Supported | Supported |
| **Pre-flight column check** | Yes | Yes | Yes |

> [!NOTE]
> **Tableau published data sources have no stored measures.** The agent handles this by computing aggregates inline — asking for "average order value" produces a correct average even though no such measure exists in the source. You will see aggregate expressions rather than measure names in the query. This is normal, not a degraded mode.

If you connect a platform this build has no connector for, the connection is saved and you are told dataset selection is not available for it yet.

## Keeping a connection healthy

| Symptom | Cause | Fix |
| --- | --- | --- |
| Queries suddenly fail with authentication errors | Token or PAT expired — **Tableau PATs idle-expire after 15 days by default** | [Edit the connection](#managing-an-existing-connection) with a fresh secret |
| *"Reconnect the data source"* on a dashboard | The stored credential is no longer valid | Click **Connect data source** on the board |
| A shared connection returns nothing for teammates | It is **not published**, or its publication was revoked | [Publish it](#publishing-a-shared-connection) |
| A column the agent used no longer exists | The BI model changed | **Refresh catalog** — see [The catalog](../catalog.md#refreshing) |
| Only some datasets are queryable | The account lost permission on the others | Check permissions, then refresh |

Power BI and Looker tokens are refreshed automatically in the background; you should not need to reconnect them routinely.

> [!TIP]
> **Settings → [Connections](../../common/connections.md)** shows the health the platform has actually observed for each external system — *healthy*, *expiring*, *degraded*, *broken* — derived from real queries and real token refreshes rather than a poll. Check it before assuming a credential is at fault; *expiring* is the state that gives you time to act.
