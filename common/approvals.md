[← Docs](../README.md) · [Common](README.md) · [← Account & Settings](settings.md) · [Connections →](connections.md)

# Approvals

**On this page:** [What the queue is for](#what-the-queue-is-for) · [Opening it](#opening-it) · [The counters](#the-counters) · [Reading a row](#reading-a-row) · [Approving or rejecting](#approving-or-rejecting) · [After you approve](#after-you-approve) · [Expiry](#expiry) · [Who can approve](#who-can-approve) · [How this relates to in-chat confirmation](#how-this-relates-to-in-chat-confirmation)

An unattended run has no human attached. When it reaches an action that policy says a person should decide, it does not fail and it does not guess — it **queues the action and carries on**. This page is where somebody decides, later.

Open it at **Settings → Approvals**.

## What the queue is for

A [scheduled run](../cloud-agent/schedules.md) firing at 03:00 has nobody to ask. Historically that left two options, and both were bad: deny the action and let the run come back half-finished, or pre-approve the category and let it proceed unwatched.

The queue is the third option. The run proposes the action, records exactly what it wanted to do, and finishes the rest of its work. In the morning somebody reads the proposal and says yes or no.

> [!IMPORTANT]
> **Approving runs exactly the payload shown.** Nothing is re-planned, re-generated, or re-decided at execution time. What you read in the row is what runs — the conversation that proposed it may have ended days ago.

## Opening it

Everything on this page comes from a durable queue, not from a live run. You can close the browser, come back next week, and the entry is still there with its full context. Entries survive the session that created them precisely because the person who has to decide is rarely the person who was watching.

The list refreshes itself every 30 seconds, because a queue resolved by several people on several machines goes stale quickly.

<!-- Screenshot: ![Approvals queue — counters, status tabs, and a waiting action row](images/approvals-queue.png) -->

## The counters

Four figures sit above the list:

| Counter | What it counts |
| --- | --- |
| **Waiting** | Actions nobody has decided yet |
| **Expiring in 24h** | Waiting actions whose window closes within a day — the ones to look at first |
| **Executed (7d)** | Approved and carried out in the last week |
| **Failed (7d)** | Approved but unsuccessful in the last week |

Below them, tabs filter the list: **Waiting · Executed · Failed · Rejected · Expired · All**.

## Reading a row

Each row carries everything the decision turns on.

| Element | What it tells you |
| --- | --- |
| **Action class** | The kind of thing being proposed |
| **Status** | *waiting* · *running* · *executed* · *failed* · *rejected* · *expired* |
| **high priority** | Flagged by the policy as urgent |
| **Preview** | The exact payload — the message that would be sent, the change that would be made |
| **Who proposed it** | *A person* or *Scheduled task* |
| **Expiry** | Rendered as a distance: *"expires in 3h"* |
| **Policy at proposal** | For example *"was gate (org)"* |

### Why the policy is written in the past tense

*"was gate (org)"* means: at the moment this action was proposed, org-level policy classed it as something requiring a gate.

That is deliberately **not** a re-resolution against today's policy. If you are looking at an entry raised last Tuesday, what you need to know is what the platform was allowed to do when it asked — which is not necessarily what it is allowed to do now. A present-tense reading would quietly assert the opposite.

### Two states worth understanding

**Failed** rows show the error and how many attempts were made. This is a genuine failure: the action was approved, tried, and did not succeed.

**Executed, delivery unconfirmed** is a different thing, and it is called out in amber on the row. The transport accepted the call but never confirmed the message arrived. It is not a failure and it is not a success — it is a receipt that could not be verified, and saying so is the difference between reporting a fact and making a claim.

## Approving or rejecting

**Approve** and **Reject** appear only on rows still waiting. There is no undo: an approved action is dispatched, and a rejected one is closed.

If somebody else decided the same row first, your click is refused and the list refreshes. Retrying would only lose the same race again — read the row's new state instead.

## After you approve

You may see *"The action will run on the next sweep."*

This is normal and it is not a warning. Approving records the decision; a background sweeper is what actually delivers, and it is the delivery guarantee — an action that could not run this instant is not lost, it is picked up shortly. A row sitting at *approved* rather than *executed* for a moment means the sweeper has not reached it yet.

## Expiry

Every queued action carries a window. Past it, the entry moves to **Expired** and can no longer be approved — a proposal made against a world two weeks ago should not be executable against this one.

Watch the **Expiring in 24h** counter. If work is routinely expiring unapproved, either the window is too short for how your team works or the policy is gating something that should be pre-approved on the schedule itself.

## Who can approve

Reading and resolving the queue are **member-level**. In a small team the natural approver is whoever is on call, not an org administrator, and requiring administrator rights to approve a notification would make the queue an obstacle rather than a control.

Changing *policy* — which action classes gate at all — is a separate, administrator-level concern. See [Guardrails & cost caps](../cloud-agent/guardrails.md).

## How this relates to in-chat confirmation

They are two halves of the same idea, split by whether a human is present.

| | Interactive chat | Unattended run |
| --- | --- | --- |
| **Where the decision happens** | In the conversation, immediately | Here, whenever somebody looks |
| **What happens while waiting** | The turn pauses | The run continues with its other work |
| **If nobody decides** | The turn eventually ends | The entry expires |

See [Confirming a sensitive action](../cloud-agent/chat.md#confirming-a-sensitive-action) for the in-chat card, and [Scheduled runs](../cloud-agent/guardrails.md#scheduled-runs) for what a schedule can pre-approve so it never needs to queue at all.

> [!TIP]
> The queue is the right home for actions that are *occasionally* fine — a notification to a customer, a change outside a maintenance window. For actions a schedule performs every single time, pre-approving them on the schedule is better than approving the same row every morning.
