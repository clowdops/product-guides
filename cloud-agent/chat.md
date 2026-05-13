[← ClowdOps](README.md) · [← Workspace](your-workspace.md) · [Templates →](templates.md)

# Chatting with the Agent

**On this page:** [Starting a conversation](#starting-a-conversation) · [Execution phases](#execution-phases) · [Numbered steps](#numbered-steps) · [Clarifying questions](#clarifying-questions) · [Conversation history](#conversation-history)

Chat is the primary way to interact with ClowdOps. Every conversation runs within the currently selected sandbox, using the credentials and context bound to it.

<!-- Screenshot: ![ClowdOps — main chat interface](./images/cloud-agent-chat-main-ui.png) -->

## Starting a conversation

Click **New Chat** in the left sidebar (or the `+` button) to open a fresh conversation. Type your request in the composer at the bottom and press **Enter** to send.

Examples of things you can ask:

- *"List all S3 buckets in my AWS account and flag any that have public access enabled."*
- *"Summarise the last 24 hours of CloudWatch error logs for the payments service."*
- *"Compare compute costs across my GCP projects and suggest where I can reduce spend."*

The agent figures out what steps are needed, plans them, executes them, and returns a structured answer — all within one turn.

## Execution phases

After you send a message, the agent progresses through a set of phases shown in real time:

<!-- Screenshot: ![Execution phases visible during an agent turn](./images/cloud-agent-chat-execution-phases.png) -->

| Phase | What is happening |
| --- | --- |
| **Classifying** | The agent analyses your request and determines the approach |
| **Clarifying** | The agent asks you follow-up questions (if needed — see below) |
| **Planning** | The agent generates a step-by-step execution plan |
| **Executing** | Each step runs in order; parallelisable steps run concurrently |
| **Answering** | The agent synthesises results into a final response |
| **Done** | The turn is complete |

## Numbered steps

During the **Executing** phase, each step is displayed with a number, a description, and a status indicator:

- **Running** — currently in progress
- **Completed** — finished successfully
- **Failed** — encountered an error (details shown inline)

Steps that can run in parallel do so automatically. You can watch progress in real time as results stream in.

## Clarifying questions

Some requests require the agent to ask a follow-up question before it can proceed — for example, when a target account or region is ambiguous. The question appears as an interactive card in the conversation. Select an option or type a custom answer, then submit to continue.

> [!TIP]
> If you would prefer the agent to make reasonable assumptions and proceed without asking, phrase your prompt with explicit context (for example include the account ID, region, or environment name).

## Conversation history

All conversations are saved automatically and listed in the left sidebar, grouped by time:

- Today
- Yesterday
- This week
- This month
- Older

Click any entry to resume a past conversation. The full message history and agent context are preserved. To delete a conversation, hover over it in the sidebar and click the trash icon.
