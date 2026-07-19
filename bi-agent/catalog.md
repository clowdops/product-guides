[← ClowdBI](README.md) · [← Connecting a BI source](connections/README.md) · [Asking questions →](chat.md)

# The catalog

**On this page:** [What the catalog is](#what-the-catalog-is) · [Discovery](#discovery) · [Entities](#entities) · [Column badges](#column-badges) · [Measures](#measures) · [Relationships](#relationships) · [Several models in one project](#several-models-in-one-project) · [Refreshing](#refreshing) · [Making your model easier to read](#making-your-model-easier-to-read)

The **catalog** is what the agent knows about your data. Open it from the `…` button beside the data project selector, or **Open catalog** on a project card.

It is worth a look early on: everything the agent can answer is bounded by what appears here, and most disappointing answers trace back to something visible on this page.

<!-- Screenshot: ![Catalog page — entities, measures, relationships sections](images/catalog-overview.png) -->

## What the catalog is

For each connected model, the catalog records:

- **Entities** — the tables, and their columns with types
- **Measures** — the calculations defined in your model
- **Relationships** — how entities join to each other
- **Cross-dataset links** — validated joins to models from *other* connections ([more](cross-dataset-links.md))

It holds **structure only — never data**. Column names, their types, and a rough sense of how many distinct values each one holds, but no actual values. This is exactly the part the agent sends to the AI model so it can write a query; see [What the AI model receives](data-privacy.md#what-the-ai-model-receives).

The header shows the connection, whether it is active, and when the model was last seen.

## Discovery

The catalog is built by **discovery**, which reads your model's structure from the BI platform.

Discovery is **lazy**: it runs the first time you ask a question about a dataset. So a freshly connected project shows *"The catalog hasn't been populated yet"* until either you ask something or click **Refresh catalog**.

Discovery is not something the agent can trigger on a whim — it runs on connect, on your explicit refresh, and on first use. It never reads rows.

## Entities

Entities are your tables. Expand one to see its columns.

Columns are **ranked**, not listed alphabetically: the ones most likely to be useful come first, and empty columns sink to the bottom. Hidden fields are struck through and sorted last.

<!-- Screenshot: ![Entity expanded — column list with type and cardinality badges](images/catalog-entity-columns.png) -->

## Column badges

Each column carries badges that tell you how the agent will treat it:

| Badge | Meaning | Why it matters |
| --- | --- | --- |
| **Data type** | Text, number, date, … | Determines what the agent can do with it |
| **summable** | Numeric and safe to add up | Marks a genuine quantity rather than a numeric code |
| **high / low cardinality** | Roughly how many different values the column holds | A column with a handful of values (*region*, *status*) makes a good chart category; one with thousands does not |
| **empty** | No values found | **Grouping by one produces an empty answer that looks valid** |
| 🛡 **Personal data class** (red) | `name`, `email`, `phone`, `address`, `national_id`, … | The agent cannot group by or return these — see [Data privacy](data-privacy.md#the-personal-data-boundary) |

> [!IMPORTANT]
> The **empty** badge is the one to watch. A column with no data yields a query that runs cleanly and returns nothing — or zero — which reads as a real answer. If a result looks implausibly empty, check the catalog for this badge.

> [!TIP]
> Scan the red personal-data badges once, when you first connect. They tell you which columns the agent will refuse to group by, which is exactly the list of things you may want an [anonymised identifier](data-privacy.md#working-with-sensitive-entities) for.

## Measures

Measures are the calculations your model defines — *Total Revenue*, *Margin %*, *Active Customers*. Each shows:

- Its **home entity**
- Its **format string** (currency, percentage, …)
- An **Expression** disclosure with the underlying definition
- Its **valid grains** — the levels of detail at which it actually means something (per order, per customer, per month, and so on)

> [!NOTE]
> **Valid grains matter more than they look.** A measure that is correct as a yearly total can be meaningless broken down per transaction — *average contract value* means nothing at the level of a single line item. The agent respects the levels your model declares, which is why a well-defined model gives trustworthy answers and a loose one does not.

If a model shows **no measures**, either it genuinely defines none — normal for Tableau, and handled by [inline aggregates](connections/tableau.md#tableau-has-no-stored-measures) — or the connected account cannot enumerate them, which is a permissions issue worth fixing.

## Relationships

Relationships are the joins defined inside one model. The agent uses them to answer questions spanning several entities in the same dataset — *"revenue by customer region"* works when `Sales` relates to `Customer` relates to `Region`.

Joins **between separate datasets** are a different mechanism: [cross-dataset links](cross-dataset-links.md).

## Several models in one project

When a project holds more than one model, the catalog shows a **model switcher** — a row of pills. Select one to see its catalog.

Answers in chat carry a **model chip** showing which model produced them, so you can always tell where a number came from.

## Refreshing

BI models change. Click **Refresh catalog** to re-scan every connected model — you get *"Catalog refreshed"* when it completes.

Refresh after:

- Adding or removing measures, columns, or tables in your BI model
- Changing permissions on the connected account
- An answer referencing something that no longer exists
- A dashboard panel reporting *"this panel needs attention"*

**Add datasets** brings more datasets from an existing connection into the project.

> [!TIP]
> A stale catalog is a common cause of odd behaviour after someone edits the underlying model. Refresh first, then investigate.

## Making your model easier to read

The agent reads your model the way a new analyst would. The same things that would help a person help it:

| Do this | Because |
| --- | --- |
| **Name columns meaningfully** | `attr_7` tells the agent nothing — including that it holds email addresses, which means it will not be classified as personal data |
| **Write measure descriptions** | These are sent to the AI model and are the strongest signal for picking the right measure |
| **Declare valid grains** | Prevents a measure being used where it is not meaningful |
| **Expose label tables for code columns** | Otherwise charts read `1 / 5 / 2` instead of *Purchased / Paid / Cancelled* |
| **Hide columns you do not want used** | Hidden fields sink to the bottom of the ranking |
| **Expose an anonymised id for sensitive entities** | Lets the agent analyse them without personal data reaching the AI model — see [Working with sensitive entities](data-privacy.md#working-with-sensitive-entities) |

Time spent here pays back on every question anyone asks afterwards.
