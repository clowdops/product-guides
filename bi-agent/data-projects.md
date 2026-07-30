[← ClowdBI](README.md) · [← Getting Started](getting-started.md) · [Connecting a BI source →](connections/README.md)

# Data projects

**On this page:** [What a data project is](#what-a-data-project-is) · [Creating and switching](#creating-and-switching) · [The project tabs](#the-project-tabs) · [Several connections in one project](#several-connections-in-one-project) · [How to draw the boundaries](#how-to-draw-the-boundaries) · [Who can query — shared or personal access](#who-can-query--shared-or-personal-access) · [Members](#members) · [Choosing the AI model](#choosing-the-ai-model) · [Budgets](#budgets)

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

## The project tabs

Opening a data project gives you a tabbed view of everything scoped to it:

| Tab | What it holds |
| --- | --- |
| **Catalog** | What the agent knows about your models — [the catalog](catalog.md). This is the project's home. |
| **Connections** | The BI accounts this project can query: add, edit, publish, revoke, remove. See [Connecting a BI source](connections/README.md#managing-an-existing-connection). |
| **Members** | Who has access to this data project |
| **AI model** | Which AI provider powers this project — see [below](#choosing-the-ai-model) |
| **Usage** | Spend for this project and its conversations, plus the budget editor |

A **budget pill** in the header shows today's spend against the effective daily cap; click it to jump to Usage.

> [!NOTE]
> Connections used to live under a **Project settings** page reached from a gear icon. That page is now the **Connections** and **AI model** tabs, and old links redirect to Connections.

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
| **Shared service account** | Everyone in the project queries through this one connection and sees the same data — **once it has been published** | You want consistent, predictable results for the team. Use a **read-only service account**. |
| **My personal access** | Only you query through it. Each teammate connects their own account and sees only what that account can see | Row-level security matters and each person should see their own slice |

With **personal access**, a teammate who has not connected their own account gets a clear message asking them to connect, rather than silently seeing someone else's data.

> [!IMPORTANT]
> **A shared connection is not usable until somebody publishes it.** Creating it is not enough — it stays credless, and queries through it return nothing, until an owner or administrator signs it off with a data classification and a *"runs as"* label. That label is then shown to everyone who views a board it backs.
>
> This exists because a shared connection is where one person's access quietly becomes everyone's. Publishing is the moment a person takes responsibility for that, and it can be [revoked](connections/README.md#revoking-a-publication) immediately if the access turns out to be broader than intended. See [Publishing a shared connection](connections/README.md#publishing-a-shared-connection).

> [!NOTE]
> Power BI connections use delegated Microsoft sign-in, so each person connecting authenticates as themselves.

> [!IMPORTANT]
> Saved **dashboards** refresh using the credential of whoever saved them, regardless of this setting — so every project member sees the same slice on a shared board. See [Who can see a dashboard](dashboards.md#who-can-see-a-dashboard).

## Members

The **Members** tab lists who has access to this data project. Membership is granted per project, within your organisation's overall [membership](../common/settings.md#members) — being in the organisation does not by itself give access to every data project.

Project members can query the project's models, open its conversations, and view its dashboards. What they actually *see* in a result still depends on the connection: a personal-access connection shows each person their own slice, a published shared one shows everyone the same.

## Choosing the AI model

Each data project chooses which AI provider powers it, on its **AI model** tab.

<!-- Screenshot: ![AI model tab — provider selection and BYOK key](images/project-settings-ai.png) -->

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

A child scope can be stricter than its parent but never more permissive. Set caps from the **Usage** tab at each scope — the data project's own tab, or Settings → Usage for the organisation. See [Account & settings → Usage](../common/settings.md#usage).

The chat header shows live session spend against the per-chat cap. A **Chat budget** dialog lets the chat's creator tighten it for that conversation.

> [!TIP]
> A modest per-chat cap is the simplest protection against an expensive exploratory session. Dashboard **refreshes are free** — they involve no AI model at all — so a heavily-used board costs nothing to keep open.

Unlike [ClowdInfra](../cloud-agent/guardrails.md), there is nothing to configure here about which actions the agent may take: it can only read from your data sources, because it has no ability to change anything.
