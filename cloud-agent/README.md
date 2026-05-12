---
icon: messages
---

# Cloud Agent (Preview)

Cloud Agent is a chat-oriented interface for running AI agents against your cloud infrastructure. You describe a task in plain language, and the agent plans and executes it — querying resources, calling APIs, running code, and reasoning over results — all within the credentials and scope you define.

{% hint style="info" %}
Cloud Agent is designed for technical users who already have cloud provider credentials (AWS, GCP, Azure) or AI API keys (OpenAI, Anthropic, etc.). You bring your keys; Cloud Agent does the rest.
{% endhint %}

## Key concepts

| Concept | What it is |
|---|---|
| **Project** | A top-level grouping for your team's work. Contains one or more sandboxes. |
| **Sandbox** | An isolated execution environment. Holds the credentials, templates, and history for a specific context (e.g., a production environment, a cloud account). |
| **Template** | A saved, reusable prompt you can run on demand or on a cron schedule. |
| **Run** | A single agent execution — triggered by chat, a template, or a schedule. |

## In this section

* [Getting Started](getting-started.md) — sign up, onboarding, and first login
* [Projects, Sandboxes & Credentials](your-workspace.md) — organise your work and connect your keys
* [Chatting with the Agent](chat.md) — start conversations and understand execution phases
* [Templates](templates.md) — save and reuse prompts
* [Scheduled Runs](schedules.md) — automate template execution with cron
* [Runs & History](runs.md) — audit executions, tokens, and cost
* [Cloud Resources](resources.md) — explore the discovered resource inventory
* [Team & Settings](team-and-settings.md) — members, billing, and account settings
