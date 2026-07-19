[← ClowdBI](README.md) · [← Dashboards](dashboards.md) · [Data privacy →](data-privacy.md)

# Cross-dataset links

**On this page:** [The problem they solve](#the-problem-they-solve) · [What a link is](#what-a-link-is) · [How links get created](#how-links-get-created) · [Reading the evidence](#reading-the-evidence) · [Confirming a link](#confirming-a-link) · [Creating one manually](#creating-one-manually) · [Grouping by an attribute only one side has](#grouping-by-an-attribute-only-one-side-has) · [Weighted vs unweighted averages](#weighted-vs-unweighted-averages) · [Limits](#limits)

## The problem they solve

Your sales data lives in Power BI. Your maintenance records live in Tableau. They describe the same machines, but no BI tool joins across them — so questions spanning both get answered by someone exporting two spreadsheets and doing a VLOOKUP.

A **cross-dataset link** tells ClowdBI that two connected models share an entity, so it can answer those questions directly:

- *"Show me revenue per machine alongside its maintenance hours."*
- *"Do customers with more support tickets renew less often?"*
- *"Which product lines have both high returns and low margin?"*

Links only exist **within a data project** — both models must be connected to the same project. See [Several connections in one project](data-projects.md#several-connections-in-one-project).

## What a link is

A link records that two models describe the same real-world things — *"these are the same machines"* — and which columns to match them on. You can match on up to four pairs of columns.

Each pair names the column on each side and how to normalise before matching:

| Normalisation | Effect |
| --- | --- |
| `exact` | Match values as-is |
| `trim` | Ignore surrounding whitespace |
| `trim_upper` | Ignore whitespace and case |
| `digits` | Compare only the digits — useful for codes formatted differently on each side |

A link also records how the two sides pair up — one-to-one (`1:1`), one-to-many (`1:N`), or many-to-one (`N:1`).

> [!NOTE]
> **Records are never copied between systems.** Each platform summarises its own data first, and only those small summaries are matched up. Nothing bulk-copies from one platform to the other.

## How links get created

Two routes.

**The agent proposes one.** Ask a question spanning two datasets and the agent looks for a shared key. Before proposing, it validates the columns exist and contain data, checks that **neither side is personal data**, and probes real data to measure how well the keys actually overlap. If it holds up, the link appears as **proposed**.

**You create one manually** in the Links panel of the [catalog](catalog.md). Manually created links are **confirmed** immediately, and still probed.

<!-- Screenshot: ![Links panel — proposed and confirmed links with overlap evidence](images/links-panel.png) -->

> [!IMPORTANT]
> **A link can never be keyed on personal data.** A proposed join on an email address or a name is refused outright. Company registration numbers and tax ids are permitted and audited. This is the same [boundary](data-privacy.md#the-personal-data-boundary) that governs queries.

## Reading the evidence

Every link carries the evidence from its probe, and it is worth reading before confirming:

> key overlap 87% · sampled · 12,000 ↔ 11,430 keys · probed 3/14/2026

| Part | Meaning |
| --- | --- |
| **key overlap** | What fraction of keys appear on both sides. The headline number |
| **sampled** | The overlap was estimated from a sample rather than computed exactly (large key sets) |
| **12,000 ↔ 11,430 keys** | Distinct key count on each side |
| **probed** | When the evidence was gathered |

Roughly how to read overlap:

| Overlap | Interpretation |
| --- | --- |
| **90–100%** | The same entity, well maintained on both sides |
| **50–90%** | Genuine but partial — one side covers more, or codes drift. Usable, worth understanding |
| **Under 50%** | Treat with suspicion. Often a formatting mismatch (try `trim_upper` or `digits`) or the wrong column |
| **Very low** | Rejected — these are probably not the same entity |

> [!TIP]
> Low overlap is more often a formatting problem than a data problem. If one system stores `MC-00841` and the other `mc841`, the `digits` normalisation matches them.

## Confirming a link

A **proposed** link is usable immediately for chat answers and draft dashboards — exploration is not blocked.

But **saving a dashboard built on an unconfirmed link requires you to confirm it**:

> **Confirm cross-dataset link?**
> This dashboard joins datasets via 'Machine' (87% key overlap): Sales ↔ Maintenance. Confirming records your approval of the join and saves the dashboard.

Click **Confirm & save**.

This exists because a saved dashboard becomes something colleagues trust without re-deriving. The confirmation records that a person — not the AI model — vouched for the join. The agent can never confirm a link on your behalf.

Links can be **Confirmed**, **Rejected**, or deleted from the Links panel at any time.

## Creating one manually

In the Links panel, fill in:

| Field | What to enter |
| --- | --- |
| **Name** | The shared entity, for example `Machine` or `Customer` |
| **Left dataset** | The model and table on one side |
| **Right dataset** | The model and table on the other |
| **Key pairs** | Column = column, with a normalisation mode. Up to four |
| **Cardinality** | `1:1`, `1:N`, or `N:1` |

Click **Create link**. It is validated and probed against both datasets before saving, so an unworkable link fails here rather than silently producing wrong numbers later.

## Grouping by an attribute only one side has

A common need: join on machine code, then group by **certification level** — which only exists in the maintenance dataset.

ClowdBI handles this by carrying the attribute across the join. You do not configure anything; just ask:

- *"Average efficiency by mechanic certification level."*
- *"Revenue per machine, grouped by maintenance category."*

The engine verifies at run time that the carried attribute is **single-valued per join key** — that each machine has exactly one certification level. If not, the panel reports the problem instead of silently multiplying rows.

> [!NOTE]
> That check is why this is safe. Carrying a multi-valued attribute across a join is the classic way to produce inflated totals; here it fails loudly instead.

## Weighted vs unweighted averages

The one arithmetic subtlety worth understanding.

Averaging across a join can mean two different things:

- **Weighted** (ratio of sums) — total revenue ÷ total units. Large entities count proportionally.
- **Unweighted** (average of per-entity values) — each entity counts once regardless of size.

They give different answers, and both are legitimate. The agent picks one deliberately and **states which it used** in titles and explanations.

> [!TIP]
> When it matters, say so: *"weighted by revenue"* or *"treating each store equally"*. Percentages and rates are the usual place this bites — an unweighted average of percentages is rarely what people mean.

## Limits

| Limit | Value |
| --- | --- |
| Key pairs per link | 1–4 |
| Carried attributes per side | 4 |
| Models per link | 2 |

Questions spanning **three or more** datasets are not supported in one query. Chain the analysis in conversation instead.
