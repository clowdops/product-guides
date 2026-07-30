[← ClowdOps](README.md) · [← Workspace](your-workspace.md) · [Schedules →](schedules.md)

# Chatting with the Agent

**On this page:** [Starting a conversation](#starting-a-conversation) · [What you see during a turn](#what-you-see-during-a-turn) · [The plan checklist](#the-plan-checklist) · [Clarifying questions](#clarifying-questions) · [Confirming a sensitive action](#confirming-a-sensitive-action) · [Live cost & model badge](#live-cost--model-badge) · [Active packs](#active-packs) · [Stopping a turn](#stopping-a-turn) · [Billing refusals](#billing-refusals) · [Notifications](#notifications) · [Drafting a document](#drafting-a-document) · [Teaching the agent a convention](#teaching-the-agent-a-convention) · [Recording who was involved](#recording-who-was-involved) · [Leaving feedback](#leaving-feedback) · [Conversation history](#conversation-history)

Chat is the primary way to interact with ClowdOps. Every conversation runs within the currently selected sandbox, using the credentials, guardrails, and budget bound to it.

<!-- Screenshot: ![ClowdOps — main chat interface](./images/cloud-agent-chat-main-ui.png) -->

## Starting a conversation

Click **New Chat** in the left sidebar (or the `+` button) to open a fresh conversation. Type your request in the composer at the bottom and press **Enter** to send.

Examples of things you can ask:

- *"List all S3 buckets in my AWS account and flag any that have public access enabled."*
- *"Summarise the last 24 hours of CloudWatch error logs for the payments service."*
- *"Compare compute costs across my GCP projects and suggest where I can reduce spend."*

The agent reasons about the request, calls tools as needed (cloud discovery, cost analysis, shell commands inside its sandbox), and streams the result back as it goes.

## What you see during a turn

The agent runs in a loop: it thinks, calls a tool, reads the result, thinks again, and eventually writes the final answer. Each step streams to the UI in real time.

- **Tool calls** appear inline as they start (`bash`, `discover_cloud_resources`, `get_cost_analysis`, …) with a live elapsed-time counter while they run.
- **Streaming text** from the model appears as it's generated.
- When the model thinks a task is multi-step, it declares a **plan** that renders as a live checklist (see below).
- The **working environment is stateful within a session** — files, installed packages, and history from one turn are visible to the next.

## The plan checklist

For multi-step work the agent declares a short plan up front. The plan renders as a Cursor-style checklist next to the conversation:

- Pending steps show as muted text.
- The current step shows a spinner.
- Completed steps show a checkmark; failed steps show a red x with the error note.

The plan is informational — there is no strict ordering enforced. The checklist reflects whatever progress the agent has reported.

> [!TIP]
> The agent is conservative about declaring a plan for short requests. If you want to nudge it, add hints like *"this is multi-step"* or *"do this across regions"*.

## Clarifying questions

Some requests require a follow-up before the agent can proceed — for example when an account or region is ambiguous. The question appears as an interactive card in the conversation. Select an option or type a custom answer, then submit to continue.

> [!TIP]
> If you would prefer the agent to make reasonable assumptions and proceed without asking, phrase your prompt with explicit context (for example include the account ID, region, or environment name).

## Confirming a sensitive action

When the agent is about to run something mutating — deleting data, destroying a resource, modifying IAM, running a shell command on a host — a **confirmation card** appears in the conversation before the action is dispatched:

<!-- Screenshot: ![Inline confirmation card for a destructive action](./images/cloud-agent-chat-confirmation-card.png) -->

The card shows:

- The **category** of action (for example *Delete data*, *Modify IAM permissions*).
- The **tool** that's about to run and a preview of its arguments.
- A short **rationale** explaining why approval is being asked.
- An optional **note** field — surfaced back to the agent if you deny.
- A checkbox: ***Allow this category for the rest of this chat session without asking again.*** Useful when you're knowingly doing a series of similar operations.

Click **Allow once** (or **Allow for session** when the checkbox is ticked) to let the action proceed. Click **Deny** to block it; the agent will see the denial and react accordingly.

Which categories require confirmation, and which categories are allowed at all, are controlled by your sandbox's guardrails — see [Guardrails & cost caps](guardrails.md).

## Live cost & model badge

A small badge in the chat header shows the spend on this session so far against your per-chat cap, along with the model the agent is currently using:

```
$0.07 / $5.00 · gpt-5.2
```

- **Spend** updates after every LLM round-trip, not just at the end of the turn — you see cost accumulating live.
- **Cap** is the per-chat-session budget that applies to this conversation (inherited from the sandbox, project, or org budget).
- **Model** is picked automatically from the AI credentials attached to the sandbox: a provider-priority list intersected with which AI providers your sandbox has keys for. Change the picked model by adding or removing AI credentials in [Workspace & credentials](your-workspace.md).

## Active packs

Beside the guardrail chips, the chat header shows one chip per organisation [pack](../common/packs.md) active in this session — the name and the version, for example `deployment-conventions v3`.

Hovering a chip says how it got there:

- **bound by your org** — an administrator attached this pack to the scope, so every session here receives it.
- **activated on demand** — the agent read the pack catalog and pulled this one in because it matched the task.

A session that received no organisation packs shows no chips at all. Chips are how you tell whether the agent is working with your house conventions or without them — which is usually the first thing to check when it does something the team would not.

## Stopping a turn

While the agent is working, the send button morphs into a **Stop** button (a red square). Click it to interrupt the turn:

- Any work the agent is currently doing is cancelled — no further actions are dispatched.
- The working environment for the session is preserved, so the next turn picks up where the previous one left off.
- The conversation marks the turn as cancelled; no synthetic assistant reply is added.

## Billing refusals

Before each turn starts, the platform checks that you have enough credits and aren't over the 24-hour spend cap. If the check fails you get a toast and the turn is refused:

| Code | Meaning | Where to go |
| --- | --- | --- |
| `out_of_credits` | Combined PAYG + subscription balance is empty | Settings → Billing |
| `daily_cap_reached` | The 24-hour rolling spend cap on your plan was hit | Settings → Billing (or wait) |
| `no_subscription` | No active plan covers this org | Settings → Plan |

Each toast deep-links to the Billing page so you can top up or upgrade.

## Notifications

The agent can push messages to a notification channel (Slack, Teams, PagerDuty, or email) at any point during a conversation — just ask it naturally:

- *"After you scan the buckets, post a Slack summary of any public ones."*
- *"Page on-call via PagerDuty if you find a critical exposure."*
- *"Email me the cost report when you're done."*

The `notify` tool is only available when at least one notification channel is attached to the sandbox. To set one up, see [Credentials → Notification channels](your-workspace.md#notification-channels). For the full feature guide including severity routing, schedule digests, and setup, see [Notifications](notifications.md).

## Drafting a document

Ask the agent to write something down and it becomes an [artifact](artifacts.md) — a versioned document in the project, rather than text that scrolls away:

- *"Draft a weekly digest of this week's findings."*
- *"Write that up as an incident brief."*

The artifact appears under the project's **Artifacts** tab, where it can be revised, compared version by version, and approved. Approving records that the content is agreed; sending it anywhere is always a separate step.

> [!TIP]
> Ask the agent to *revise* an existing artifact rather than draft a new one — *"update the weekly digest with today's findings"* — and you get a new version on the same document, with a diff you can read, instead of a second copy.

## Teaching the agent a convention

Anything you find yourself explaining twice belongs in a [pack](../common/packs.md). Say so in the conversation where you are explaining it:

> *"Remember for future sessions: production deploys only happen Tuesday and Thursday, and always need a rollback plan attached."*

The agent drafts a pack from what you said. It changes nothing yet — an administrator publishes it, and from then on sessions receive it automatically.

## Recording who was involved

When a conversation names a person — the owner of a system, the requester of a change, the contact for an escalation — the agent can record them in the shared [contact registry](../common/contacts.md), so the same person is recognised next time rather than re-identified from scratch.

> [!IMPORTANT]
> A contact record grants nobody any access. It is a directory entry, not an account. And note that what you *type* about a person in a conversation stays in the conversation — [erasing their contact record](../common/contacts.md#erasing-a-person) does not remove it.

## Leaving feedback

Each chat has a **Feedback** tab (alongside Chat and Debug). Use it to tell us whether the agent's response was helpful:

- Pick a **satisfied / not satisfied** rating with the thumbs buttons.
- Optionally add a **comment** explaining what worked or what went wrong.

You can resubmit at any time to update your earlier feedback. When an administrator is viewing another organisation's chat, the tab is read-only.

## Conversation history

All conversations are saved automatically and listed in the left sidebar, grouped by time:

- Today
- Yesterday
- This week
- This month
- Older

Click any entry to resume a past conversation. The full message history and agent context are preserved. To delete a conversation, hover over it in the sidebar and click the trash icon.

Scheduled runs also show up here — they're regular chat sessions with no human attached. When you open one you'll see a **"Scheduled run"** ribbon at the top of the history linking back to the parent schedule, and the composer is hidden (the conversation is read-only).
