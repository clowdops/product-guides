[← Docs](../README.md) · [Common](README.md) · [← Approvals](approvals.md) · [Contacts →](contacts.md)

# Connections

**On this page:** [What a connection is](#what-a-connection-is) · [Opening it](#opening-it) · [Health states](#health-states) · [Where health comes from](#where-health-comes-from) · [Reading a row](#reading-a-row) · [Why two credentials can stay separate](#why-two-credentials-can-stay-separate) · [Why the list is per project](#why-the-list-is-per-project) · [Fixing a broken connection](#fixing-a-broken-connection)

A credential is a secret you gave us. A **connection** is the external system that secret reaches — a Power BI tenant, a Slack workspace, an SMTP host, a cloud account. Several credentials can point at the same one.

This page lists the connections a project touches and what the platform has actually observed about each. Open it at **Settings → Connections**.

## What a connection is

Credentials are how you configure access; connections are what that access *is*. The distinction matters when something breaks, because failures happen to the external system, not to the row in your credential list.

Two people on a team may each hold their own Power BI credential against the same tenant. That is one connection with two members. When the tenant starts rejecting refresh tokens, it is the connection that is broken — and both credentials fail together, for one reason, which is a much easier thing to be told than two unrelated errors.

## Opening it

**Settings → Connections**, with a project selected. If you have not picked one, the page says so.

<!-- Screenshot: ![Connections list — health badges, provider tags, and credential counts](images/connections-list.png) -->

## Health states

| Badge | Meaning |
| --- | --- |
| **healthy** | Recent use succeeded |
| **expiring** | Credentials behind it are approaching expiry — act before it breaks |
| **degraded** | Some calls are failing, not all |
| **broken** | The external system is rejecting us |
| **unknown** | Nothing has been observed yet |
| **disabled** | Turned off; nothing will be attempted through it |

> [!IMPORTANT]
> **`unknown` is not `healthy`,** and it deliberately does not look like it. Absence of evidence is not evidence of health. A connection shows *unknown* until something real has happened through it — a badge that implied otherwise would be a liar at exactly the moment it mattered.

## Where health comes from

Health is derived from **real deliveries and real token refreshes** — a webhook that returned 404, a refresh token the identity provider rejected, a query that succeeded. It is never a synthetic reachability poll.

This is a deliberate design choice with a visible consequence in both directions:

- A connection nothing has used recently stays *unknown* rather than being marked healthy on the strength of a ping. A ping proves the host answers, not that your credential still works.
- A connection that broke is usually marked broken **before you notice**, because the platform learns from the first failure it materialises — which is normally an agent run or a scheduled delivery, not a person.

When a state has a reason, the row carries it in plain language beneath the name.

## Reading a row

| Element | What it tells you |
| --- | --- |
| **Name** | The connection's display name |
| **Health badge** | Current state, per the table above |
| **Provider tag** | Which integration this is |
| **Kind · identity** | What the external thing is, and its non-secret identifier where one exists |
| **Reason** | Why it is in its current state, when known |
| **Credential count** | How many credentials sit behind it |

## Why two credentials can stay separate

Some rows say **identity not shared**.

To fold two credentials into one connection, the platform needs a non-secret key proving they point at the same external identity — a tenant id, a workspace id, a host. Some providers expose no such key. Rather than guess that two credentials are the same thing (and then report one's failure against the other's work), the platform keeps them separate and says why.

It is not an error. It means *"we cannot prove these are the same system, so we are not going to pretend."*

## Why the list is per project

Connections are scoped to a project, and that is a containment property rather than a display preference: a connection is visible to you where at least one of its member credentials is. An organisation-wide list would leak the existence of another project's integrations to people with no access to them.

If you expect a connection and do not see it, check which project is selected.

## Fixing a broken connection

The connection list diagnoses; the credential pages repair.

| Product | Where to fix it |
| --- | --- |
| **ClowdInfra** | [Projects, Sandboxes & Credentials](../cloud-agent/your-workspace.md#credentials) |
| **ClowdBI** | [Connecting a BI source](../bi-agent/connections/README.md#managing-an-existing-connection) |

A repaired credential does not immediately flip the badge to *healthy* — it goes to *unknown* until something succeeds through it, for the same reason as above. Run a query, or let the next scheduled use prove it.

> [!TIP]
> **expiring** is the state worth acting on. *broken* means something already failed; *expiring* means you still have time to rotate a token before anybody notices.
