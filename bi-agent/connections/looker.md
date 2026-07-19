[← ClowdBI](../README.md) · [← Connecting a BI source](README.md)

# Looker

**On this page:** [What you need](#what-you-need) · [Creating API3 credentials](#creating-api3-credentials) · [Connecting](#connecting) · [Picking explores](#picking-explores) · [What the agent can do](#what-the-agent-can-do) · [Troubleshooting](#troubleshooting)

Looker connects with an **API3 client ID and secret** belonging to a Looker user. ClowdBI queries as that user, so the user's permissions and any row-level access filters apply.

## What you need

- Your Looker instance **base URL** — for example `https://yourco.cloud.looker.com`
- An **API3 client ID** and **client secret**
- The associated user must be able to see the LookML models and explores you want to query

## Creating API3 credentials

API3 credentials belong to a Looker user account. You can create them for yourself if your role permits, or ask a Looker admin.

1. In Looker, open **Admin → Users**.
2. Find the user the connection should run as, and click **Edit**.
3. In the **API3 Keys** section, click **New API3 Key**.
4. Copy the **Client ID** and **Client Secret** — the secret is shown once.

To create one for yourself, go to your avatar → **Account** → **API3 Keys**, if your role allows it.

<!-- Screenshot: ![Looker Admin — API3 Keys section with New API3 Key](../images/looker-api3-keys.png) -->

> [!TIP]
> **Create a dedicated service user for shared projects.** Give it a role with `explore` and `see_lookml` on the models in scope and nothing more. It keeps the boundary explicit and does not break when a person changes roles or leaves. See [Choosing the right account](README.md#choosing-the-right-account).

> [!IMPORTANT]
> The Looker user's permissions and access filters govern every query. If that user can see all rows, so can everyone querying through a **shared service account** connection — including on saved dashboards. Where per-person visibility matters, choose **personal access** instead.

## Connecting

1. In your data project, click **Add connection → Looker** (or **Connect Looker** on the connect panel).
2. Fill in the dialog:

| Field | Value |
| --- | --- |
| **Base URL** | Your instance URL, for example `https://yourco.cloud.looker.com` |
| **Client ID** | The API3 client ID |
| **Client secret** | The API3 client secret |

3. Choose **Who can query with this connection?** — **Shared service account** or **My personal access**. See [Who can query](../data-projects.md#who-can-query--shared-or-personal-access).
4. Click connect. You should see *"Looker connected"*.

<!-- Screenshot: ![Connect Looker dialog — base URL, client ID, secret, access choice](../images/connect-looker-form.png) -->

The secret is encrypted at rest, decrypted only inside the engine, and **never sent to the AI model** — see [Where your credentials live](../data-privacy.md#where-your-credentials-live).

## Picking explores

Looker maps onto ClowdBI's vocabulary like this:

| ClowdBI calls it | In Looker it is |
| --- | --- |
| Workspace | LookML model |
| Dataset | Explore |

Select the explores the agent should be able to query and click **Connect *N* datasets**.

> [!TIP]
> Connect the explores your team actually uses, not every explore in the model. Explores are frequently overlapping views of the same underlying tables, and offering the agent five near-identical ones makes it likelier to pick a different one than you had in mind.

## What the agent can do

| | |
| --- | --- |
| **Query language** | Looker query — visible under **Show query** on any answer |
| **Stored measures** | Yes. LookML is already a semantic layer, so the agent maps onto your measures and dimensions closely |
| **Relationships** | Read from the explore's joins |
| **Cross-dataset links** | Supported, including to Power BI and Tableau models in the same project |

Of the three platforms, Looker generally gives the most faithful results out of the box — a well-maintained LookML model is exactly the kind of curated semantic layer the agent is designed to read.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| *"Could not connect Looker"* | Wrong base URL, or the API3 key is disabled | Check the URL includes the scheme (`https://`) and has no trailing path. Verify the key in Looker Admin |
| Connects, but no explores listed | The user cannot see any LookML model | Grant the user's role access to the model |
| Some explores missing | Model-level permission gaps | Check `see_lookml` / model access for the user's role |
| Queries fail with permission errors | The role lacks `explore` on that model | Update the role in Looker Admin |
| Numbers differ from what a colleague sees in Looker | Access filters on the connected user, or a different explore | Confirm which explore was queried via the model chip and **Show query** |
