# ClowdOps (Preview)

**[Getting Started](getting-started.md)** · **[Workspace & credentials](your-workspace.md)** · **[Chat](chat.md)** · **[Schedules](schedules.md)** · **[Chats & history](chats.md)** · **[Resources](resources.md)** · **[Guardrails & cost caps](guardrails.md)** · **[Team & settings](team-and-settings.md)**

ClowdOps is a chat-oriented interface for running AI agents against your cloud infrastructure. You describe a task in plain language, and the agent plans and executes it — querying resources, calling APIs, running code, and reasoning over results — all within the credentials, guardrails, and budget you define.

> [!NOTE]
> ClowdOps is designed for technical users who already have cloud provider credentials (AWS, GCP, Azure) or AI API keys (OpenAI, Anthropic, and so on). You bring your keys; ClowdOps does the rest.

## Key concepts

| Concept | What it is |
| --- | --- |
| **Project** | A top-level grouping for your team's work. Contains one or more sandboxes. |
| **Sandbox** | An isolated execution environment. Holds the credentials, schedules, and history for a specific context (for example a production environment or a cloud account). |
| **Schedule** | A saved prompt that runs unattended on a cron cadence. Each firing is a chat session with no human attached. |
| **Chat session** | A single agent execution — triggered by you in chat or automatically by a schedule. |
| **Action category** | One of eight mutating categories (modify data, create resource, delete data, destroy resource, scale capacity, modify IAM, modify networking, run command on host). Read access is always allowed. |
| **Budget** | A USD spend cap (daily / monthly / per-chat) that applies hierarchically from org down to sandbox and chat. |

## Guides

| Guide | What you will learn |
| --- | --- |
| [Getting Started](getting-started.md) | Sign up, onboarding, and first login |
| [Projects, Sandboxes & Credentials](your-workspace.md) | Organise your work and connect your keys |
| [Chatting with the Agent](chat.md) | Start conversations, follow live plans, stop turns, approve sensitive actions |
| [Scheduled Runs](schedules.md) | Run prompts unattended on a cron schedule |
| [Chats & History](chats.md) | Audit every chat session — interactive or scheduled |
| [Cloud Resources](resources.md) | Explore the discovered resource inventory |
| [Guardrails & cost caps](guardrails.md) | Categorical permissions, USD budgets, and where to set them |
| [Team & Settings](team-and-settings.md) | Members, billing, plan, and account settings |
