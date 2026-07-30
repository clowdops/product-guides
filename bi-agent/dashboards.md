[← ClowdBI](README.md) · [← Asking questions](chat.md) · [Cross-dataset links →](cross-dataset-links.md)

# Dashboards

**On this page:** [Living boards, not screenshots](#living-boards-not-screenshots) · [Building one](#building-one) · [Refining it](#refining-it) · [Time grain](#time-grain) · [Editing the layout](#editing-the-layout) · [Parameters and filtering](#parameters-and-filtering) · [Who can see a dashboard](#who-can-see-a-dashboard) · [Snapshots](#snapshots) · [Sharing a snapshot](#sharing-a-snapshot) · [Exporting](#exporting) · [When a panel breaks](#when-a-panel-breaks) · [Version history](#version-history)

## Living boards, not screenshots

A ClowdBI dashboard stores the **recipe, not the data**: each panel holds the query that produces it. Open the board and every panel re-runs against current data.

Two consequences worth internalising:

- **Refreshes are free.** No AI model is involved in a refresh — the queries are already written. A board open on a wall display costs nothing in tokens.
- **Nothing is copied out of your BI platform.** What gets saved names the columns and measures to use; it holds no values at all. That is also why a saved board contains [no personal data](data-privacy.md) of any kind.

<!-- Screenshot: ![A ClowdBI dashboard — KPI row, bar chart, line chart, table](images/dashboard-detail.png) -->

## Building one

Dashboards are built in conversation. Ask:

- *"Build me a dashboard of sales performance this quarter."*
- *"Turn that into a board with a KPI row and a trend line."*
- *"Show me revenue, margin, and order count by region as charts."*

The board appears inline in the chat turn. Click **Save as dashboard**, then **Open dashboard**.

<!-- Screenshot: ![Inline dashboard card in a chat turn with Save as dashboard](images/chat-inline-dashboard.png) -->

Saved boards are listed under **Dashboards** in the sidebar.

> [!TIP]
> Get the analysis right in chat first, then ask for the board. Fixing a number is quicker in conversation than in a saved panel.

## Refining it

To change a board you just built, say so in the same conversation — the agent modifies the existing board rather than starting over:

- *"Add a panel showing returns by month."*
- *"Split the revenue chart by product category."*
- *"Make the second chart a line instead of bars."*
- *"Filter it to the northern region."*

## Time grain

For anything plotted over time, say the level of detail you want and the agent builds the panel at that grain:

- *"Revenue by month for the last 12 months."*
- *"Daily active sessions for the last 30 days."*
- *"Quarterly margin over three years."*

<!-- Screenshot: ![A by-month trend panel with a date axis](images/dashboard-time-grain.png) -->

The grain is part of the panel's saved recipe, so a board built *by month* stays by month on every refresh — it does not re-derive itself from whatever range you happen to be looking at.

> [!TIP]
> Name the grain explicitly rather than leaving it to be inferred. *"Sales over time"* leaves the agent to choose; *"sales by week for the last quarter"* does not. This is the same discipline that makes a question trustworthy — see [Asking good questions](asking-good-questions.md).

Some measures are only valid at certain grains. The agent respects the levels your model declares, so a request at an invalid grain is refused rather than silently answered wrongly — see [valid grains](catalog.md) in the catalog.

## Editing the layout

Click **Edit** on a saved board to rearrange it:

- **Drag** a panel by its header to move it.
- **Resize** from the bottom-right corner, on a 12-column grid.
- **Swap the chart type** per panel — bar, line, area, point, or arc.

**Save** commits; **Cancel** discards. Editing requires write access to the board.

Panels never overlap: adding one, resizing another, or letting the agent compose a board reflows the grid so every panel keeps its own space.

## Parameters and filtering

Boards can carry **parameters** shown as controls above the panels — date ranges (*Last 30 days*, *Last 3 months*, *Last 6 months*, *Last 12 months*, *Year to date*), dimension pickers, and numeric inputs. **Reset** returns them to defaults.

Clicking a chart segment **cross-filters** the rest of the board.

> [!NOTE]
> Changing a parameter as a viewer is **temporary** — it does not alter the saved board for anyone else. Only editing and saving does that.

## Who can see a dashboard

A live dashboard is visible to **members of its data project**. There is no per-dashboard access list on a live board.

> [!IMPORTANT]
> **A board refreshes using the credential of whoever saved it.** Every project member therefore sees the same numbers — including, potentially, rows their own access to the BI platform would not have returned. This is deliberate, so that a shared board means the same thing to everyone looking at it, but it is worth knowing before you save a board built on a permissive account. Where per-person visibility matters, keep the analysis in [chat](chat.md) with [personal access](data-projects.md#who-can-query--shared-or-personal-access) connections.

### The "runs as" label

A board backed by a **shared** connection shows that connection's *"runs as"* label — for example *Sales shared account*. It names the identity the queries actually run under, so anyone reading the board knows whose access produced the numbers rather than assuming it was their own.

The label is set when the connection is [published](connections/README.md#publishing-a-shared-connection), and publishing is a deliberate sign-off precisely because of this page: a shared connection turns one person's access into every viewer's. If that sign-off is [revoked](connections/README.md#revoking-a-publication), boards bound to the connection stop returning data until it is published again.

## Snapshots

A **snapshot** freezes a board's current data. Click **Snapshot** on the board.

Snapshots are for:

- **A point in time you need to keep** — month-end figures as reported.
- **Sharing outside the project**, including outside your organisation.

This is the point where numbers stop being protected by your BI platform's own permissions and start standing on their own, so taking a snapshot is a deliberate, recorded action. Snapshots are listed beneath the board by date and time.

## Sharing a snapshot

Open a snapshot and use **Share this snapshot** (available to the owner and administrators):

| Method | Behaviour |
| --- | --- |
| **Create public link** | A URL anyone can open without logging in. Expiring and revocable |
| **Grant to a user** | Named access for a specific person |

The **Shares** list shows every grant with its status, and **Revoke** removes access immediately.

> [!IMPORTANT]
> **External sharing is off by default.** An administrator must enable it for your organisation before public or cross-organisation links can be created — until then you get *"External sharing is off for this organization."* Every share is audited.

A public link opens a read-only viewer marked **Shared dashboard**, with no export offered. Expired or revoked links show *"This link is invalid or has expired."*

> [!TIP]
> Share a **snapshot**, never a screenshot. The snapshot carries its provenance — which board, which moment — and can be revoked. A screenshot in a chat thread cannot.

## Exporting

The **Export** menu offers:

| Format | Scope |
| --- | --- |
| **Excel (.xlsx)** | Whole board, a single panel, or a snapshot |
| **PowerPoint (.pptx)** | Whole board or snapshot |
| **PDF** | Via the print view |

Hover a panel for its own export button.

Exports contain real values including human-readable names, by design — the file is for you. Every export is therefore [audited](data-privacy.md#the-audit-trail): what, by whom, and which personal-data classes it contained. Never the values.

## When a panel breaks

Models change, and a panel whose query no longer binds **degrades on its own without failing the board**:

| What you see | Meaning | What to do |
| --- | --- | --- |
| **This panel needs attention** | A measure or column it used no longer exists | Click **Ask the agent to fix it** |
| **No data for this selection** | The query ran; the filters match nothing | Widen the parameters |
| **Showing cached data** | The refresh did not complete | Refresh again |
| **Refresh skipped (rate-limited)** | Too many refreshes too quickly | Click **Retry** shortly |
| **Reconnect the data source** | The stored credential is no longer valid | Click **Connect data source** |

A board-level banner appears when the connection itself is broken.

> [!TIP]
> **Ask the agent to fix it** opens a conversation with the failure already in context — usually a one-turn repair.

## Version history

Every save creates a version, listed under **History** as `v3 · date`. Click **Restore** to roll back.

Deleting a board takes two clicks (**Delete** → **Confirm?**) and requires manage access.
