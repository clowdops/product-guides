[← ClowdOps](README.md) · [← Guardrails & cost caps](guardrails.md)

# Team & Settings

**On this page:** [Profile](#profile) · [Security](#security) · [Organisation](#organisation) · [Members](#members) · [Plan](#plan) · [Billing](#billing) · [Usage](#usage) · [Activity](#activity)

Access organisation-wide settings and your account via the **Settings** icon at the bottom of the left sidebar.

## Profile

Update your display name, email address, and avatar under **Profile**.

## Security

Manage multi-factor authentication under **Security**:

- Enrol a TOTP authenticator app or a passkey (WebAuthn)
- Activate magic-link login as an alternative method
- Review or revoke trusted devices

## Organisation

Update your organisation's display name and website under **Organisation**. These fields are visible to all members and appear on invoices.

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
| **Admin** | Full access: manage members, billing, all projects and sandboxes |
| **Member** | Access to projects and sandboxes they are invited to |

Update or remove a member at any time from the Members list.

## Plan

Review your current subscription plan under **Plan**. Upgrade, downgrade, or cancel from here.

## Billing

The **Billing** page shows your credit balance, lets you top up, and lists recent transactions.

<!-- Screenshot: ![Billing page — three stat cards, buy-credits tile, transactions list](./images/cloud-agent-billing-page.png) -->

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

When custom-amount purchases are enabled for your org, a **Buy credits** tile appears under the stat cards:

- One-click **preset chips** (for example $5, $10, $25, $50).
- A free-form input for any amount within the configured bounds.
- Pay through **Stripe Checkout**; the grant lands in your **PAYG bucket** (1:1 ratio: $X paid → $X credit).

### Transactions

The transactions list shows the latest credit movements with friendly labels:

| Label | What it represents |
| --- | --- |
| **Agent LLM** | LLM-token spend for a chat turn |
| **Sandbox compute** | Wall-clock seconds the agent's sandbox stayed warm |
| **Credit pack** | A PAYG top-up you purchased |
| **Subscription (initial)** | First grant when you signed up for a plan |
| **Subscription (renewal)** | Cycle renewal grant (the bucket resets to this value) |
| **Manual adjustment** | An operator-applied credit or debit |

### The 24-hour spend cap

Subscription plans include a **24-hour rolling spend cap** as a safety brake. If the total debit across the last 24 hours hits this cap, new chat turns are refused with `daily_cap_reached` until older debits age out of the window. The cap is shown on the Plan page.

## Usage

The **Usage** page is a real-time dashboard of agent spend.

<!-- Screenshot: ![Usage dashboard — KPI strip, cost-by-day chart, per-model breakdown](./images/cloud-agent-usage-dashboard.png) -->

The same dashboard appears at four scopes; the breadth of data narrows accordingly:

| Where | Scope |
| --- | --- |
| Settings → Usage | Whole organisation |
| Project → Usage | One project (all its sandboxes) |
| Sandbox → Usage | One sandbox (all its chats) |
| (per-chat view) | A single chat session |

Each scope shows:

- **KPI strip** — cost / input tokens / output tokens / daily cap headroom.
- **Cost by day** — stacked bar chart segmented by model, for the last 7 days.
- **Token throughput** — daily input/output token totals.
- **Per-model breakdown** — table sorted by cost.

### Editing budgets

If your role allows it, a pencil icon next to the cost KPI opens the budget editor. You can set:

- **Daily** USD cap
- **Monthly** USD cap
- **Per-chat-session** USD cap
- The **allowed action categories** for this scope ([Guardrails & cost caps](guardrails.md))
- **Max consecutive failures** before [scheduled runs](schedules.md) auto-disable

Children scopes inherit from parents. The editor surfaces the parent's value as a hint and clamps inputs above the parent cap. See [Guardrails & cost caps](guardrails.md) for the full inheritance model and the permissions required to edit each scope.

## Activity

The **Activity** log shows an event history for your organisation: logins, configuration changes, member invites, credential updates, and more. Use it for audit or compliance purposes.
