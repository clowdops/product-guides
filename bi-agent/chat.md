[← ClowdBI](README.md) · [← The catalog](catalog.md) · [Dashboards →](dashboards.md)

# Asking questions

**On this page:** [Starting a conversation](#starting-a-conversation) · [What you see during a turn](#what-you-see-during-a-turn) · [Reading the answer](#reading-the-answer) · [Showing the query](#showing-the-query) · [Clarifying questions](#clarifying-questions) · [Exporting a result](#exporting-a-result) · [Turning an answer into a dashboard](#turning-an-answer-into-a-dashboard) · [When the agent cannot answer](#when-the-agent-cannot-answer) · [Cost and stopping](#cost-and-stopping) · [Conversation history](#conversation-history)

Chat is how you use ClowdBI. Every conversation runs within the selected [data project](data-projects.md), against its connected models.

<!-- Screenshot: ![ClowdBI chat — answer with result table and query disclosure](images/chat-main-ui.png) -->

## Starting a conversation

Click **New chat** in the sidebar and type into the composer. **Enter** sends, **Shift+Enter** adds a newline.

Ask in business terms, not query terms:

- *"What was revenue by region last quarter?"*
- *"Which products had the highest return rate this year?"*
- *"Compare average order value between new and returning customers."*
- *"Show me the trend in support tickets per customer over the last six months."*

The agent finds the entities and measures it needs, writes a native query, runs it, and explains the result in plain language.

> [!TIP]
> The composer is disabled until a data project is selected, and shows *"Pick a data project to start chatting"*.

## What you see during a turn

The agent works in a loop — think, query, read, think again — and streams it live:

1. **Thinking…** with an elapsed counter.
2. **Tool activity** as it happens — reading part of the model, running a query — each with its own timer.
3. **The streamed answer**, appearing as it is written.
4. **The result view** beneath the answer.

Afterwards the steps collapse into an **Activity · *N* steps** disclosure you can expand to see what it did.

## Reading the answer

Every answer comes with the data behind it, rendered as whichever view fits:

| View | Used for |
| --- | --- |
| **KPI** | A single headline number |
| **Gauge** | A value against a target or range |
| **Bar** | Comparison across categories |
| **Line** | A trend over time |
| **Scatter** | Relationship between two measures |
| **Table** | Detail, or anything that does not chart well |

When more than one view fits, chips let you switch between them. Tables are sortable, shade numeric cells in-place, and page through results with a row count in the footer.

In a project with several models, a **model chip** shows which one produced the answer.

## Showing the query

Every answer carries a **Show query** disclosure with the exact query that ran — DAX for Power BI, a Looker query, a VizQL request for Tableau.

<!-- Screenshot: ![Show query disclosure expanded, revealing DAX](images/chat-show-query.png) -->

This is the single most useful habit to build in ClowdBI. When a number looks surprising, the query tells you immediately whether the agent understood the question — which measure it used, how it filtered, what it grouped by. Far quicker than re-asking and hoping.

> [!TIP]
> Copy the query into your BI tool to verify it independently, or hand it to whoever owns the model when something looks off.

## Clarifying questions

When a request is ambiguous — two measures could plausibly mean "revenue", or the date range is unclear — the agent asks rather than guessing. The question appears as a card with options you can select, or a free-text box for your own answer.

Answer it and the turn continues.

> [!TIP]
> To skip the back-and-forth, front-load the specifics: *"revenue"* → *"net revenue, excluding tax, for FY2026"*.

## Exporting a result

The **Export** menu on any result offers:

| Format | Notes |
| --- | --- |
| **CSV** | Raw data |
| **Excel (.xlsx)** | Formatted workbook |
| **Image (.png)** | Charted results only |

Exports contain real values, including any human-readable labels — so every export is recorded in your organisation's [Activity log](../common/settings.md#activity). See [Leaving your organisation](data-privacy.md#leaving-your-organisation).

If exporting is blocked, an administrator has disabled external sharing for your organisation.

## Turning an answer into a dashboard

Ask for a visual and the agent builds one: *"turn that into a dashboard"*, *"show me this as a set of charts"*, *"build me a board for weekly sales"*.

The board appears inline in the conversation with a **Save as dashboard** button. Saved boards live under [Dashboards](dashboards.md) and re-run against current data every time they are opened.

> [!NOTE]
> The agent does not build a dashboard unless you ask. A plain question gets a plain answer; it may *offer* a dashboard after a rich multi-measure result, but never composes one uninvited.

## When the agent cannot answer

The agent is built to say so rather than invent a number. Common cases:

| What you see | What it means | What to do |
| --- | --- | --- |
| *"the query returned no rows"* | The filter or column genuinely has no data | Widen the range, or check for an **empty** column in the [catalog](catalog.md#column-badges) |
| *"column X does not exist on entity Y"* | The model changed, or the agent guessed wrong | **Refresh catalog**; the agent usually self-corrects and retries |
| A result was **rejected by the output check** | An automatic sanity check caught something impossible — a negative percentage, margin exceeding revenue | The agent repairs and retries automatically |
| A result was **rejected (personal data)** | The answer would have exposed a name, email, phone, or address | The agent re-queries grouped by an id. See [the personal-data boundary](data-privacy.md#the-personal-data-boundary) |
| *"unknown model"* | The question referenced a dataset not connected here | Check the project, or connect the dataset |

The agent gets **two repair attempts** per question. If it still cannot produce a sound query it tells you plainly rather than guessing.

> [!NOTE]
> Every query result passes an automatic sanity check before the agent is allowed to report it — empty results, impossible percentages, and internally contradictory figures are caught and retried. It is a floor, not a guarantee: see [Asking good questions](asking-good-questions.md) for the failure modes no automatic check can catch.

## Cost and stopping

A badge in the chat header shows session spend against the per-chat cap, with the active model:

```
$0.04 / $5.00 · claude-sonnet-4
```

Spend updates after every model round-trip. While the agent is working, the send button becomes a red **Stop** — click it to interrupt; the conversation is preserved.

If a turn is refused for billing reasons (`out_of_credits`, `daily_cap_reached`, `no_subscription`), the toast deep-links to [Billing](../common/settings.md#billing).

Long-running work may hit a **turn budget**, where the agent writes a checkpoint instead of continuing. Click **Continue this work** to resume.

## Conversation history

Conversations are saved automatically and listed in the sidebar under **Today**, **Yesterday**, **This week**, **This month**, and **Older**. Click any to resume with full context. Hover and click the trash icon to delete.

Each chat also has **Debug** and **Feedback** tabs where enabled:

- **Debug** — the step-by-step trace: each query, its result, the model used, and token counts. The fastest way to understand an unexpected answer.
- **Feedback** — rate a response and add a comment. Resubmit any time to update it.
