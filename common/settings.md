[← Docs](../README.md) · [Common](README.md) · [Referrals →](referrals.md)

# Account & Settings

**On this page:** [Profile](#profile) · [Security](#security) · [Organisation](#organisation) · [Members](#members) · [Deployments](#deployments) · [Plan](#plan) · [Billing](#billing) · [Usage](#usage) · [Approvals](#approvals) · [Connections](#connections) · [Contacts](#contacts) · [Packs](#packs) · [Knowledge review](#knowledge-review) · [Signals](#signals) · [System notifications](#system-notifications) · [Referrals](#referrals) · [Activity](#activity)

Settings are **shared across every ClowdOps product**. Your organisation, members, plan, credit balance, and spend dashboard are the same whether you are working in [ClowdInfra](../cloud-agent/README.md) or [ClowdBI](../bi-agent/README.md) — switching products does not change any of them.

Open settings via the **Settings** entry at the bottom of the left sidebar. The back button returns you to whichever product you came from.

> [!NOTE]
> **A note on vocabulary.** Both products nest their work under your organisation, but they name the middle layer differently: ClowdInfra uses **projects** containing **sandboxes**, ClowdBI uses **data projects**. Where this page says *"the scope below your organisation"*, read whichever applies to the product you are in.

## Profile

Update your display name, email address, and avatar under **Profile**.

## Security

Manage multi-factor authentication under **Security**:

- Enrol a TOTP authenticator app or a passkey (WebAuthn)
- Activate magic-link login as an alternative method
- Review or revoke trusted devices

### One sign-in for every product

Authentication is shared. There is a **single sign-in page** for all of ClowdOps, hosted on the ClowdInfra origin — it is the address registered with Google and Microsoft, so it is the one place their sign-in buttons can work.

Two consequences worth knowing:

- **Signing out anywhere signs you out everywhere.** The session is shared across products, so ending it in ClowdBI ends it in ClowdInfra too.
- **Signing out of ClowdBI returns you to the shared login page**, not to a ClowdBI-specific one. Sign back in there and you are returned to the [product hub](#product-entitlement).

## Organisation

Update your organisation's display name and website under **Organisation**. These fields are visible to all members and appear on invoices.

This section is available to organisation administrators.

## Members

Invite colleagues and manage roles under **Members**.

### Inviting a member

1. Click **Invite member**.
2. Enter their email address.
3. Select a role.
4. Click **Send invite**.

The invitee receives an email with a join link. They must create an account (or log in if they already have one) before the invitation is accepted.

### Roles

| Role | Access level |
| --- | --- |
| **Admin** | Full access: manage members, billing, and every scope in the organisation |
| **Member** | Access to the projects and scopes they are invited to |

Update or remove a member at any time from the Members list.

> [!TIP]
> Membership is organisation-wide, not per-product. Which products a member can actually open depends on what your organisation is entitled to — see [Product entitlement](#product-entitlement) below.

### Product entitlement

An organisation is entitled to one or more products. When you have more than one, logging in lands you on the **product hub** — a chooser showing each product you can enter. If you only have one, you go straight into it.

If a colleague reports *"ClowdBI isn't enabled for your organization yet"*, the product has not been enabled for your org — an administrator can turn it on.

> [!NOTE]
> The hub only offers what the server has confirmed you are entitled to. While that is still loading — or if the check cannot be completed — it shows just the product you are already in, rather than guessing. A product you expect but do not see for a moment is the hub waiting for an answer, not a change to your entitlement.

## Deployments

Organisations running ClowdOps on their own infrastructure manage their appliances under **Deployments**: register a new deployment, view its status and last-seen heartbeat, and see when an update is available.

For the full self-hosting guide — prerequisites, install, federation, and day-2 operations — see [Private Deployment](../cloud-agent/private-deployment/README.md).

## Plan

The **Plans & credits** page is a storefront: it shows the subscription tiers, your current plan, and credit packs you can buy. Upgrade, downgrade, or cancel from here.

### Subscription tiers

Every organisation always has an active plan. New orgs start on the **Free** tier automatically; from there you can move up the ladder. Each paid tier grants a pool of credit at the start of every billing cycle (more than you pay for — the surplus is the credit "premium") and carries its own 24-hour spend cap.

| Plan | Monthly | Yearly | Credit premium | Daily cap |
| --- | --- | --- | --- | --- |
| **Free** | — | — | Starter grant on signup | Conservative starter cap |
| **Basic** | $20 → $22 credit | $200 → $220 credit | +10% | $2 / day |
| **Pro** | $100 → $120 credit | $1000 → $1200 credit | +20% | $10 / day |
| **Pro+** | $200 → $260 credit | $2000 → $2600 credit | +30% | $20 / day |
| **Enterprise** | $500 → $700 credit | $5000 → $7000 credit | +40% | $50 / day |

- **Credit** lands in your **subscription bucket** at the start of each cycle and is reset (not carried over) on renewal — see [Billing](#billing).
- **Daily cap** is the rolling 24-hour spend brake for the tier; turns are refused with `daily_cap_reached` once it is hit until older spend ages out.
- Choose **monthly** or **yearly** billing per tier; the yearly price is ten months for twelve.

Picking a higher tier mid-cycle upgrades you immediately; the new cycle's grant and cap apply from the change.

> [!NOTE]
> One plan covers your whole organisation across every product. Spend in ClowdInfra and ClowdBI draws on the same credit balance and counts toward the same daily cap.

## Billing

The **Billing** page is your account view: your current subscription status (with upgrade / cancel), your credit balances, and recent transactions. The storefront for *buying* plans and credit packs lives on the [Plans & credits](#plan) page.

<!-- Screenshot: ![Billing page — three stat cards, buy-credits tile, transactions list](images/settings-billing-page.png) -->

### Two credit buckets

ClowdOps tracks credits in two separate buckets. **1 credit = $0.01 USD.** Both buckets are drained automatically as the agent works; the subscription bucket is consumed first.

| Bucket | Source | Expiry |
| --- | --- | --- |
| **PAYG balance** | Credit packs you bought, or custom-amount top-ups | Never expires |
| **Subscription** | Granted at the start of each subscription cycle | **Forfeited on renewal** — unused credits are reset, not carried over |

Three stat cards at the top of the page show:

- **Available** — the total spend headroom (PAYG + active subscription).
- **PAYG balance** — credit packs, never expires.
- **Subscription** — this cycle's grant, with an "expires in *N* days" countdown.

### Buy credits

On the **Plans & credits** page you can top up your PAYG balance two ways:

**Credit packs** — fixed-size packs, some of which include bonus credit:

| Pack | Price | You receive |
| --- | --- | --- |
| **Small** | $10 | $10 credit |
| **Medium** | $50 | $55 credit (+10% bonus) |

**Custom top-up** — when custom-amount purchases are enabled for your org, an **Other amount** option lets you buy any amount between the configured bounds (for example $5 minimum, $1000 maximum), with one-click preset chips ($5, $10, $25, $50, $100).

Either way you pay through **Stripe Checkout**; the grant lands in your **PAYG bucket** and never expires.

### Transactions

The transactions list shows the latest 25 credit movements with friendly labels:

| Label | What it represents |
| --- | --- |
| **Platform LLM** | LLM-token spend when the agent uses platform-provided AI keys (billed to your balance, with the platform surcharge applied) |
| **BYOK LLM (metered)** | The small metered usage fee on LLM calls made with your own keys (the token cost itself is on your AI provider's bill) |
| **Agent** | The agent service markup applied on top of LLM spend |
| **Sandbox compute** | Wall-clock seconds the agent's execution environment stayed warm |
| **Credit pack** | A PAYG top-up you purchased |
| **Subscription (initial)** | First grant when you signed up for a plan |
| **Subscription (renewal)** | Cycle renewal grant (the bucket resets to this value) |
| **Referral credit** | A one-time reward from the [Referrals](referrals.md) program |
| **Manual adjustment** | An operator-applied credit or debit |

> [!NOTE]
> Agent spend is split three ways — **BYOK** LLM (your-key metered fee), **platform** LLM (platform-key cost × surcharge), and the **agent** markup. Whichever apply, all of them count toward your budget caps. The [Usage](#usage) dashboard lets you break spend down by these types.

### The 24-hour spend cap

Subscription plans include a **24-hour rolling spend cap** as a safety brake. If the total debit across the last 24 hours hits this cap, new chat turns are refused with `daily_cap_reached` until older debits age out of the window. The cap is shown on the Plan page.

## Usage

The **Usage** page is a real-time dashboard of agent spend.

<img src="../cloud-agent/images/sandbox_usage_tab.png" alt="Usage dashboard — KPI strip, cost-by-type chart, and filter chips" width="100%">

The same dashboard appears at every scope; the breadth of data narrows accordingly:

| Where | Scope |
| --- | --- |
| Settings → Usage | Whole organisation (all products) |
| Project → Usage | One project and everything under it |
| Sandbox / data project → Usage | One execution scope and all its chats |
| (per-chat view) | A single chat session |

Each scope shows:

- **KPI strip** — cost / input tokens / output tokens / daily cap headroom.
- **Cost by day** — stacked bar chart segmented by model, for the last 7 days.
- **Cost by type** — a breakdown of spend across the three cost buckets (**BYOK** LLM, **platform** LLM, and the **agent** markup), with filter chips (*All* · *Billed* · *BYOK*) to focus the charts on one bucket.
- **Token throughput** — daily input/output token totals.
- **Per-model breakdown** — table sorted by cost.

### Editing budgets

If your role allows it, a pencil icon next to the cost KPI opens the budget editor. You can set:

- **Daily** USD cap
- **Monthly** USD cap
- **Per-chat-session** USD cap
- The **allowed action categories** for this scope
- **Max consecutive failures** before unattended runs auto-disable

Child scopes inherit from parents: a child can be stricter than its parent but never more permissive. The editor surfaces the parent's value as a hint and clamps inputs above the parent cap.

> [!NOTE]
> **Action categories only bite where a product can actually change something.** They are central to ClowdInfra, whose agent provisions and modifies real infrastructure — see [Guardrails & cost caps](../cloud-agent/guardrails.md). ClowdBI's agent is read-only against your data sources by construction: it has no tool that can write, so the categories have nothing to gate there. USD caps apply to both.

| Scope | Role required to edit |
| --- | --- |
| Organisation | Org **Owner** / **Administrator**, or a role with the **Workspaces** permission bit |
| Project | Project **Admin**, or any of the org roles above |
| Sandbox / data project | Same as the parent project |
| Chat session | Only the user who created the chat |

## Approvals

The queue where an **unattended run** deferred an action to a person. A scheduled run that reaches something needing a decision does not fail — it records exactly what it wanted to do, carries on with the rest of its work, and waits here.

Counters show what is waiting, what expires within 24 hours, and what was executed or failed in the last week. Reading and resolving are open to any member.

Full page: **[Approvals](approvals.md)**.

## Connections

The external systems your projects reach — a Power BI tenant, a Slack workspace, an SMTP host — with the health the platform has actually observed for each: *healthy*, *expiring*, *degraded*, *broken*, *unknown*, or *disabled*.

Health comes from real deliveries and real token refreshes, never from a reachability poll. The list is scoped to the selected project.

Full page: **[Connections](connections.md)**.

## Contacts

Three pages — **Contacts**, **Contact lists**, and **Contact settings** — holding your organisation's shared record of the people it knows about. A directory, not a login system: nothing here grants anyone access to anything.

Contact settings is administrator-only and carries the organisation-wide sharing posture, the erasure-block override, and the change record.

Full page: **[Contacts](contacts.md)**, including [data-subject erasure](contacts.md#erasing-a-person).

## Packs

Durable guidance and files your organisation publishes into its agent sessions, so house conventions do not have to be re-explained in every conversation. Any member can author a draft; publishing, binding and rollback are administrator actions.

Full page: **[Packs](packs.md)**.

## Knowledge review

Administrator-only, and the entry appears only when something is waiting. This is where the platform proposes that two contact records are the same person, and an administrator confirms, flips, or rejects the merge.

It is deliberately separate from [Approvals](#approvals): that queue decides whether the platform may *do* something, this one decides whether something it *believes* is true.

Full page: **[Contacts → Knowledge review](contacts.md#knowledge-review)**.

## Signals

The attention queue: one record per **condition** worth acting on — a budget nearing its cap, a run of guardrail denials, a failing schedule, an unstable connection — rather than one row per event.

Reading is open to every member; dismissing requires an administrator and a written reason.

Full page: **[Signals](signals.md)**, including [how it differs from the activity log](signals.md#signals-vs-the-activity-log).

## System notifications

Organisation administrators can configure where **platform-level** alerts are delivered — billing warnings, credit exhaustion, and similar account events. This is separate from the notification channels an agent uses mid-run to message your team.

Each event type can be subscribed to independently:

| Event type | What it sends |
| --- | --- |
| **Budget hits** | A budget cap (org / project / sandbox / chat) was reached |
| **Guardrail denials** | A guardrail blocked an agent action |
| **Run failures** | A chat or scheduled run ended in error |
| **Signals** | The daily digest of what is worth acting on — new conditions, how many repeat sightings folded into the quiet ones, and what was dismissed |

> [!NOTE]
> The **Signals** row is a *summary*, not an alert channel. Immediate alerts still ride the event types above, and the [Signals](signals.md) page is there whether or not anyone subscribes to the digest.

<img src="../cloud-agent/images/settings_system_notifications.png" alt="System notifications settings — channel configuration" width="100%">

## Referrals

Mint and track referral codes under **Settings → Referrals**. Both the referring and the referred organisation earn credit once the referred org qualifies. See [Referrals](referrals.md) for the full program.

## Activity

The **Activity** log shows an event history for your organisation: logins, configuration changes, member invites, credential updates, exports, and more. Use it for audit or compliance purposes.

> [!NOTE]
> Activity answers *what happened* — every occurrence, with your own read state. [Signals](signals.md) answers *what is worth acting on* — one record per condition, shared across the organisation, with a lifecycle. Signal-producing events appear in both; neither replaces the other.

> [!TIP]
> ClowdBI writes additional governance events here — snapshot creation, dashboard exports, external share links, and personal-data audit records. See [Data privacy & personal data](../bi-agent/data-privacy.md#the-audit-trail).
