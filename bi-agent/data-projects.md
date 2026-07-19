[← ClowdBI](README.md) · [← Getting Started](getting-started.md) · [Connecting a BI source →](connections/README.md)

# Data projects

**On this page:** [What a data project is](#what-a-data-project-is) · [Creating and switching](#creating-and-switching) · [Several connections in one project](#several-connections-in-one-project) · [How to draw the boundaries](#how-to-draw-the-boundaries) · [Who can query — shared or personal access](#who-can-query--shared-or-personal-access) · [Choosing the AI model](#choosing-the-ai-model) · [Budgets](#budgets)

## What a data project is

A **data project** is ClowdBI's working scope. Everything is scoped to it:

- the **connections** to your BI platforms,
- the **catalog** discovered through them,
- the **conversations** you have about that data,
- the **dashboards** built from those conversations,
- the **cross-dataset links** between its models.

Switching data projects switches all of it. The agent only ever sees the models belonging to the project you have selected.

## Creating and switching

The **data project selector** sits at the top of the left sidebar. Use the `+` button to create one, and the `…` button to open the current project's catalog.

<!-- Screenshot: ![Sidebar — data project selector, New chat, Data projects, Dashboards](images/sidebar-overview.png) -->

The **Data projects** entry lists every project with a status pill showing what it is connected to:

| Pill | Meaning |
| --- | --- |
| **Connected · Power BI** | One connection, ready to query |
| **Connected · Power BI · 3 accounts** | Several connections in this project |
| **Not connected** | No connection yet — open it to add one |

Each card offers **Open catalog** and **Open chat**.

## Several connections in one project

A project is not limited to one connection or one platform. You can add a second Power BI account, or a Tableau connection alongside a Looker one, and ask questions across all of them.

Use **Add connection** from the catalog page to add another.

When a project holds more than one model, two things change in the interface:

- The catalog gains a **model switcher** — a row of pills, one per model.
- Answers carry a **model chip** showing which model produced them.

And the agent gains two extra abilities: it can propose **[cross-dataset links](cross-dataset-links.md)** between models, and answer questions that span them.

## How to draw the boundaries

The useful rule: **put datasets in the same project when you might want to ask about them in one breath.**

| Situation | Suggestion |
| --- | --- |
| Sales in Power BI, support tickets in Tableau, same customers | **One project.** Cross-dataset links only exist within a project. |
| Finance data and marketing data, different audiences | **Separate projects.** Membership and dashboards stay cleanly divided. |
| Production and a sandbox copy of the same model | **Separate projects.** Avoids the agent picking the wrong one. |
| Ten datasets from one workspace, all related | **One project.** Connect the ones you will actually ask about. |

> [!TIP]
> Projects are cheap. If a project's catalog grows large and unfocused, answers get vaguer — the agent has more places to look and more ways to pick the wrong measure. Splitting is usually the fix.

## Who can query — shared or personal access

When you connect Looker or Tableau, you choose how teammates query through that connection. The choice is presented as **"Who can query with this connection?"**

| Option | Behaviour | Use when |
| --- | --- | --- |
| **Shared service account** | Everyone in the project queries through this one connection and sees the same data | You want consistent, predictable results for the team. Use a **read-only service account**. |
| **My personal access** | Only you query through it. Each teammate connects their own account and sees only what that account can see | Row-level security matters and each person should see their own slice |

With **personal access**, a teammate who has not connected their own account gets a clear message asking them to connect, rather than silently seeing someone else's data.

> [!NOTE]
> Power BI connections use delegated Microsoft sign-in, so each person connecting authenticates as themselves.

> [!IMPORTANT]
> Saved **dashboards** refresh using the credential of whoever saved them, regardless of this setting — so every project member sees the same slice on a shared board. See [Who can see a dashboard](dashboards.md#who-can-see-a-dashboard).

## Choosing the AI model

Each data project chooses which AI provider powers it, under **Project settings** (the gear icon on the catalog page).

<!-- Screenshot: ![Project settings — AI provider selection and BYOK key](images/project-settings-ai.png) -->

| Mode | LLM cost | Notes |
| --- | --- | --- |
| **Platform default** | Billed to your ClowdOps credit balance | Nothing to configure or rotate. Recommended. |
| **Bring your own key** | Billed by your AI provider directly | ClowdOps bills only compute and a small metered fee |

Available providers are Anthropic (Claude), OpenAI, Google (Gemini), and AWS Bedrock.

The active model appears in the chat header badge alongside session spend, for example `$0.04 / $5.00 · claude-sonnet-4`.

> [!NOTE]
> This choice does not affect the [privacy boundary](data-privacy.md) — the same rules about what is and is not sent apply to every provider. It affects who bills you for tokens and whose model authors the queries.

## Budgets

Spend caps flow down from your organisation:

```
Organisation
└── Data project
    └── Chat session
```

A child scope can be stricter than its parent but never more permissive. Set caps from the **Usage** tab at each scope — see [Account & settings → Usage](../common/settings.md#usage).

The chat header shows live session spend against the per-chat cap. A **Chat budget** dialog lets the chat's creator tighten it for that conversation.

> [!TIP]
> A modest per-chat cap is the simplest protection against an expensive exploratory session. Dashboard **refreshes are free** — they involve no AI model at all — so a heavily-used board costs nothing to keep open.

Unlike [ClowdInfra](../cloud-agent/guardrails.md), there is nothing to configure here about which actions the agent may take: it can only read from your data sources, because it has no ability to change anything.
