[← All ClowdOps docs](../README.md)

# ClowdInfra — the cloud infrastructure agent (Preview)

**[Getting Started](getting-started.md)** · **[Workspace & credentials](your-workspace.md)** · **[Chat](chat.md)** · **[Schedules](schedules.md)** · **[Approvals](../common/approvals.md)** · **[Artifacts](artifacts.md)** · **[Packs](../common/packs.md)** · **[Notifications](notifications.md)** · **[Signals](../common/signals.md)** · **[Chats & history](chats.md)** · **[External agents (MCP)](mcp.md)** · **[Telegram](tg.md)** · **[Resources](resources.md)** · **[Guardrails & cost caps](guardrails.md)** · **[Account & settings](../common/settings.md)** · **[Referrals](../common/referrals.md)**

ClowdOps is a chat-oriented interface for running AI agents against your cloud infrastructure. You describe a task in plain language, and the agent plans and executes it — querying resources, calling APIs, running code, and reasoning over results — all within the credentials, guardrails, and budget you define.

> [!NOTE]
> ClowdOps is designed for technical users who already have cloud provider credentials (AWS, GCP, Azure) or AI API keys (OpenAI, Anthropic, and so on). You bring your keys; ClowdOps does the rest.

## Two lines of defence

ClowdOps applies safety in two layers, and both matter.

**First line — credential permissions.** The keys you attach to a sandbox define the hard outer boundary of what the agent can ever do. If the credential only has read access, no prompt, no guardrail misconfiguration, and no model behaviour can cause a write. This is the layer you control entirely, before ClowdOps is even in the picture. Start here: [Credential Setup Recipes](credentials/README.md) has ready-to-run recipes for read-only, cost-observer, and security-audit setups for AWS, GCP, Azure, VCS, and SSH.

**Second line — agent guardrails.** On top of whatever the credential allows, ClowdOps adds its own categorical permission system and USD budget caps. Mutating actions (deleting resources, modifying IAM, running host commands, …) require explicit grants at the org, project, or sandbox level, and prompt for in-chat confirmation unless pre-approved. See [Guardrails & cost caps](guardrails.md).

The right posture is to use both: scope credentials to the minimum your use case actually needs, then use guardrails to gate what the agent is allowed to reach for within that scope.

## Key concepts

| Concept | What it is |
| --- | --- |
| **Project** | A top-level grouping for your team's work. Contains one or more sandboxes. |
| **Sandbox** | An isolated execution environment. Holds the credentials, schedules, and history for a specific context (for example a production environment or a cloud account). |
| **Schedule** | A saved prompt that runs unattended on a cron cadence. Each firing is a chat session with no human attached. |
| **Chat session** | A single agent execution — triggered by you in chat, automatically by a schedule, by an external agent over MCP, or from a linked Telegram chat. |
| **Agent access token** | A per-sandbox bearer (`fba_…`) that lets an external MCP client (Claude Code, Cursor, …) drive the sandbox's agent. See [Connect External Agents (MCP)](mcp.md). |
| **Action category** | One of eight mutating categories (modify data, create resource, delete data, destroy resource, scale capacity, modify IAM, modify networking, run command on host). Read access is always allowed. |
| **Budget** | A USD spend cap (daily / monthly / per-chat) that applies hierarchically from org down to sandbox and chat. |
| **Pending action** | An action an unattended run deferred to a person rather than performing or abandoning. Waits in the [Approvals](../common/approvals.md) queue. |
| **Pack** | Durable guidance and files your organisation publishes into agent sessions, so conventions do not have to be re-explained. See [Packs](../common/packs.md). |
| **Artifact** | A versioned, approvable document held in a project — a digest, brief or report. See [Artifacts](artifacts.md). |
| **Connection** | The external system behind one or more credentials, with health derived from real use. See [Connections](../common/connections.md). |
| **Signal** | One record per condition worth acting on, with a lifecycle and a signed dismissal. See [Signals](../common/signals.md). |
| **Contact** | A person your organisation knows about, in the shared [contact registry](../common/contacts.md). Not an account — it grants nothing. |

## Guides

| Guide | What you will learn |
| --- | --- |
| [Getting Started](getting-started.md) | Sign up, onboarding, and first login |
| [Projects, Sandboxes & Credentials](your-workspace.md) | Organise your work and connect your keys |
| [Chatting with the Agent](chat.md) | Start conversations, follow live plans, stop turns, approve sensitive actions |
| [Scheduled Runs](schedules.md) | Run prompts unattended on a cron schedule |
| [Approvals](../common/approvals.md) | Decide the actions an unattended run deferred to a person *(shared across products)* |
| [Artifacts](artifacts.md) | Draft, revise and approve documents the agent produces |
| [Packs](../common/packs.md) | Publish durable conventions and files into agent sessions *(shared across products)* |
| [Connections](../common/connections.md) | See what your credentials actually reach, and its observed health *(shared across products)* |
| [Signals](../common/signals.md) | The attention queue: conditions worth acting on *(shared across products)* |
| [Contacts](../common/contacts.md) | The people your organisation knows, and how to erase one *(shared across products)* |
| [Chats & History](chats.md) | Audit every chat session — interactive or scheduled |
| [Connect External Agents (MCP)](mcp.md) | Drive a sandbox from Claude Code, Cursor, Codex, or VS Code |
| [Telegram](tg.md) | Get the agent's messages in Telegram and drive a sandbox by chatting with the bot |
| [Cloud Resources](resources.md) | Explore the discovered resource inventory |
| [Notifications](notifications.md) | Push alerts and digests to Slack, Teams, PagerDuty, Telegram, or email |
| [Guardrails & cost caps](guardrails.md) | Categorical permissions, USD budgets, and where to set them |
| [Account & Settings](../common/settings.md) | Members, billing, plan, and account settings *(shared across products)* |
| [Referrals](../common/referrals.md) | Invite other teams with a referral code — both sides earn credit *(shared across products)* |
| [Private Deployment](private-deployment/README.md) | Run the whole ClowdOps stack on your own VPS or air-gapped network |
| [Credential Setup Recipes](credentials/README.md) | Ready-to-run setup guides for DevOps, FinOps, SecOps, VCS, and SSH |
| [Agent Usage Guidelines](agent-usage-guidelines/README.md) | When to reach for the agent vs a pipeline, where it earns its keep, and how to design and bound a task |
