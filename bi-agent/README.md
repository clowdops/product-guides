[← All ClowdOps docs](../README.md)

# ClowdBI — the business-intelligence agent (Preview)

**[Getting Started](getting-started.md)** · **[Data projects](data-projects.md)** · **[Connecting a BI source](connections/README.md)** · **[The catalog](catalog.md)** · **[Asking questions](chat.md)** · **[Dashboards](dashboards.md)** · **[Cross-dataset links](cross-dataset-links.md)** · **[Data privacy](data-privacy.md)** · **[Asking good questions](asking-good-questions.md)** · **[Account & settings](../common/settings.md)**

ClowdBI lets you talk to your BI. Connect the semantic models you already maintain — Power BI datasets, Looker explores, Tableau published data sources — and ask questions in plain language. The agent grounds every answer on your own measures, entities, and relationships, shows you the query it ran, and can turn any answer into a live dashboard.

It is not a new BI tool and it does not copy your data anywhere. It reads the model you already built and asks it questions on your behalf.

> [!NOTE]
> ClowdBI is for teams that already have a governed BI layer. The better your measures and relationships are defined, the better the agent answers — it is only ever as good as the semantic model beneath it.

---

## What reaches the AI model, and what never does

This is the first thing most teams want to know, so here it is plainly. ClowdBI splits the work between the AI model and a protected execution environment, and the split is enforced in code rather than by instructing the model to behave.

**The AI model's job is to write queries, not to hold your data.** It receives the *shape* of your data — entity names, column names and types, measure names and descriptions, relationships — and from that it authors a native query (DAX for Power BI, a Looker query, a VizQL request for Tableau). It never receives a credential and never talks to your BI platform.

**Execution happens somewhere the model cannot reach.** The query runs inside an isolated sandbox holding a short-lived access token, which is injected as an environment variable at the moment of the call. Your refresh tokens, client secrets, and personal access tokens are decrypted only inside the engine and are never placed in the model's context, in a command line, or in the conversation transcript.

### Three guarantees

| Guarantee | How it holds |
| --- | --- |
| **Credentials never reach the AI model** | Secrets are decrypted engine-side only, injected into the sandbox as environment variables, and stripped from any tool output before the model sees it |
| **Raw personal data never reaches the AI model** | Every result passes a personal-data gate *before* the model reads it — see below |
| **Nothing is copied out of your BI platform** | Queries are aggregates that run against your source. Dashboards store the *recipe*, never the rows |

### One clarification worth making

Aggregated **results do** go back to the AI model — they have to, because the model is what turns `47,200` into *"revenue was up 12% on last quarter, driven by the northern region."* What the model receives is the answer grid: business figures and non-personal grouping keys.

What it never receives is a **raw personal-data value**. Every result is checked against your catalog's personal-data classification before it is handed over, and a result that would expose a name, email address, phone number, or postal address is **blocked and never shown to the model** — the agent is told to re-query grouping by a non-personal identifier instead. The check fails closed: if the classification cannot be consulted, the result is rejected rather than assumed safe.

So the accurate summary is not *"no data reaches the model"* — it is:

> The AI model sees your **schema** and your **aggregated numbers**. It never sees your credentials, and it never sees a raw personal-data value.

### What this means for you: use anonymised identifiers

If you want the agent to analyse something genuinely sensitive — individual customers, patients, employees, accounts — **give it an anonymised identifier to group by, and keep the real identity out of the model entirely.**

A `CustomerRef` of `C-84021` is something the agent can count, rank, join, and chart without any personal data ever entering the AI model's context. A `CustomerEmail` is not. The system already pushes hard in this direction — grouping by a non-personal id is both the enforced policy and the only reliable path — but you get far better answers, faster, if your model *has* such a column in the first place.

Two things worth knowing:

- **Names can still appear on your screen.** A dashboard may group by a reference code and display the person's name beside it. That name is fetched at the last moment, sent to your browser, and removed before the model sees it.
- **If you type personal data into the prompt yourself, it goes to the model as written.** ClowdBI shows an amber privacy banner when it detects this, but it does not censor you. Typing *"what did john.smith@acme.com order?"* sends that address to the AI provider.

The full model, including the known limits, is in **[Data privacy & personal data](data-privacy.md)**. Read it before connecting anything containing regulated data.

---

## The agent cannot change your data

ClowdBI's agent is **read-only against your BI sources — not because we withheld permission, but because it has no way to write.** Nothing in its toolbox updates, deletes, or runs code on your platform. It can read the catalog, run a query, build a dashboard, propose a link between datasets, ask you a question, and send a notification. That is the complete list.

This is why ClowdBI has none of the "which actions is the agent allowed to take" controls that [ClowdInfra](../cloud-agent/README.md) needs: there is nothing damaging for them to prevent. Spend caps still apply — see [Account & settings](../common/settings.md#usage).

> [!TIP]
> Scope the connection anyway. The account you connect defines the outer boundary of what can ever be read, and it is the layer you control completely. A read-only service account with access to exactly the datasets you intend to expose is the right starting posture — see [Connecting a BI source](connections/README.md#choosing-the-right-account).

---

## Key concepts

| Concept | What it is |
| --- | --- |
| **Data project** | The working scope. Holds one or more connections, the catalog built from them, its conversations, and its dashboards. |
| **Connection** | A credential linking a data project to one BI platform account. A project can hold several, across different providers. |
| **Dataset → model** | A dataset you select from a connection (a Power BI dataset, a Looker explore, a Tableau published data source) becomes a *model* the agent can query. |
| **Catalog** | What the agent knows about a model: its entities, measures, relationships, and per-column personal-data classification. Built by discovery. |
| **Cross-dataset link** | A validated declaration that two models share an entity, letting the agent answer questions spanning both. |
| **Dashboard** | A living board of panels. Stores the query recipe, not the data — every open re-runs against current data. |
| **Snapshot** | A frozen copy of a dashboard's data at a moment in time. The only thing you can meaningfully share outside your organisation. |

## Guides

| Guide | What you will learn |
| --- | --- |
| [Getting Started](getting-started.md) | Sign up, create your organisation, connect your first BI source, ask your first question |
| [Data projects](data-projects.md) | Organise your work, hold multiple connections, choose the AI model |
| [Connecting a BI source](connections/README.md) | Step-by-step setup for Power BI, Looker, and Tableau — including what to configure on their side |
| [The catalog](catalog.md) | What the agent knows about your models, how discovery works, and how to refresh it |
| [Asking questions](chat.md) | Conversations, result views, showing the query, exporting, and conversation history |
| [Dashboards](dashboards.md) | Build a board in chat, save it, edit the layout, parameters, snapshots, sharing, and export |
| [Cross-dataset links](cross-dataset-links.md) | Answer questions that span two datasets, and confirm the joins that back them |
| [Data privacy & personal data](data-privacy.md) | The full data-flow model, the personal-data boundary, the audit trail, and the known limits |
| [Asking good questions](asking-good-questions.md) | How to phrase a question you can trust — and the four ways a plausible-looking answer goes wrong |
| [Account & Settings](../common/settings.md) | Members, billing, plan, usage, and activity *(shared across products)* |

## Supported BI platforms

| Platform | Status | How you connect |
| --- | --- | --- |
| **Power BI** | Supported | Microsoft sign-in (delegated OAuth) |
| **Looker** | Supported | API3 client ID and secret |
| **Tableau** | Supported | Personal Access Token |

Per-platform setup, required permissions, and capability differences are in [Connecting a BI source](connections/README.md).
