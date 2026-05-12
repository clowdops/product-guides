---
icon: message-lines
---

# Chatting with the Agent

Chat is the primary way to interact with Cloud Agent. Every conversation runs within the currently selected sandbox, using the credentials and context bound to it.

<figure><img src="../.gitbook/assets/cloud-agent-chat-main-ui.png" alt=""><figcaption>Cloud Agent — main chat interface</figcaption></figure>

## Starting a conversation

Click **New Chat** in the left sidebar (or the `+` button) to open a fresh conversation. Type your request in the composer at the bottom and press **Enter** to send.

Examples of things you can ask:

* _"List all S3 buckets in my AWS account and flag any that have public access enabled."_
* _"Summarise the last 24 hours of CloudWatch error logs for the payments service."_
* _"Compare compute costs across my GCP projects and suggest where I can reduce spend."_

The agent figures out what steps are needed, plans them, executes them, and returns a structured answer — all within one turn.

## Execution phases

After you send a message, the agent progresses through a set of phases shown in real time:

<figure><img src="../.gitbook/assets/cloud-agent-chat-execution-phases.png" alt=""><figcaption>Execution phases visible during an agent turn</figcaption></figure>

| Phase | What's happening |
|---|---|
| **Classifying** | The agent analyses your request and determines the approach |
| **Clarifying** | The agent asks you follow-up questions (if needed — see below) |
| **Planning** | The agent generates a step-by-step execution plan |
| **Executing** | Each step runs in order; parallelisable steps run concurrently |
| **Answering** | The agent synthesises results into a final response |
| **Done** | The turn is complete |

## Numbered steps

During the **Executing** phase, each step is displayed with a number, a description, and a status indicator:

* **Running** — currently in progress
* **Completed** — finished successfully
* **Failed** — encountered an error (details shown inline)

Steps that can run in parallel do so automatically. You can watch progress in real time as results stream in.

## Clarifying questions

Some requests require the agent to ask a follow-up question before it can proceed — for example, when a target account or region is ambiguous. The question appears as an interactive card in the conversation. Select an option or type a custom answer, then submit to continue.

{% hint style="info" %}
If you'd prefer the agent to make reasonable assumptions and proceed without asking, phrase your prompt with explicit context (e.g., include the account ID, region, or environment name).
{% endhint %}

## Conversation history

All conversations are saved automatically and listed in the left sidebar, grouped by time:

* Today
* Yesterday
* This week
* This month
* Older

Click any entry to resume a past conversation. The full message history and agent context are preserved. To delete a conversation, hover over it in the sidebar and click the trash icon.
