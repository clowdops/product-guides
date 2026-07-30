[← ClowdBI](README.md) · [← Data privacy](data-privacy.md)

# Asking good questions

**On this page:** [Why this page exists](#why-this-page-exists) · [The one habit that matters](#the-one-habit-that-matters) · [Four ways a good-looking answer is wrong](#four-ways-a-good-looking-answer-is-wrong) · [Phrasing that works](#phrasing-that-works) · [What to ask and what not to](#what-to-ask-and-what-not-to) · [Building trust in a new project](#building-trust-in-a-new-project) · [A quick self-test](#a-quick-self-test)

## Why this page exists

Driving ClowdBI is easy — you type a question and get an answer. The harder skill is knowing **when to trust it**, and how to phrase a question so the answer is worth trusting.

ClowdBI has real safeguards. Queries are checked against your catalog before they run, results pass an automatic sanity check before the agent may report them, and it is built to say *"I cannot answer that reliably"* rather than invent a number. Those catch the crude failures.

They do not catch a query that is **valid, sensible, and answers a subtly different question than the one you asked**. That is the failure mode worth your attention, and it is a failure of the semantic model and the question more often than of the agent.

> The agent is only ever as good as the model beneath it. It cannot know a definition your model does not encode.

## The one habit that matters

**Expand [Show query](chat.md#showing-the-query) whenever a number surprises you.**

That is the whole discipline. The query shows which measure was used, how it filtered, and what it grouped by — which tells you in seconds whether the agent understood the question. It is faster than re-asking, and far more reliable than a second opinion from the same agent.

If the number matches what you expected, you rarely need it. If it does not, the query almost always explains why.

> [!TIP]
> The [citation marker](evidence.md) beside a specific number is the same habit at finer grain: it takes you to the query behind *that claim* rather than behind the answer as a whole. Use the marker when one figure looks wrong, **Show query** when the whole answer does.

### What citations do and do not settle

The [coverage line](evidence.md#the-coverage-line) under every answer tells you how much of it is grounded — and it is worth being precise about what that buys you.

A citation proves a number came from a query you can read. It does **not** prove the query was the right one. Of the four failure modes below, citations reliably expose the first; the other three produce a perfectly cited answer that is still wrong, because the query ran correctly against the wrong thing.

So: treat *"all facts cited"* as *"nothing was invented"*, not as *"this is the answer you wanted."*

## Four ways a good-looking answer is wrong

### 1. The empty column

A column with no data produces a query that runs cleanly and returns nothing — or zero. That reads as a real finding: *"no returns in the northern region"* is a plausible sentence.

**Tell:** an implausibly clean zero or empty result.
**Check:** the **empty** badge in the [catalog](catalog.md#column-badges).

### 2. The wrong level of detail

A measure that is correct at one level of detail can be meaningless at another — BI models call this the *grain*. *Total contract value* added up per transaction rather than per contract can multiply a figure many times over.

The automatic check catches the crude cases — margin exceeding revenue, percentages over 100 — but not everything.

**Tell:** a total noticeably larger than you expect.
**Check:** the measure's valid grains in the catalog, or simply ask *"at what level of detail is that measure valid?"*.

### 3. Code columns instead of labels

Grouping by an integer status code gives a chart reading `1 / 5 / 2` instead of *Purchased / Paid / Cancelled*. The numbers are right; the chart is unreadable and easy to misread.

**Tell:** bare integers on a category axis.
**Fix:** ask it to group by the label column, or expose a label table in your BI model.

### 4. The wrong definition of a common word

*Revenue* means gross to one team and net of returns and discounts to another. If your model defines both — or defines neither, as with [Tableau data sources](connections/tableau.md#tableau-has-no-stored-measures) — the agent picks one.

**Tell:** a number close to but not matching the accepted figure.
**Fix:** name the measure explicitly, or ask which one it used.

## Phrasing that works

| Instead of | Ask |
| --- | --- |
| *"How are sales doing?"* | *"What was net revenue by month for the last 12 months, compared with the same period last year?"* |
| *"Show me the top customers."* | *"Top 10 customers by net revenue in FY2026, with their order counts."* |
| *"Why did margin drop?"* | *"Show margin % by product category by month for the last 6 months, highlighting categories where it fell more than 2 points."* |
| *"Is churn bad?"* | *"What share of customers active in Q1 placed no order in Q2, by segment?"* |

The pattern: **name the measure, name the grain, name the period, name the comparison.** Each removes one thing the agent would otherwise have to guess — and each guess is a place a plausible answer can diverge from the one you wanted.

> [!TIP]
> Ambiguity is not fatal — the agent [asks a clarifying question](chat.md#clarifying-questions) when a request is genuinely unclear. Being specific just skips the round trip.

## What to ask and what not to

ClowdBI is strongest on **exploration**: the questions that would otherwise mean pulling an analyst off something else, or that nobody asks because the cost of asking is too high.

| Well suited | Why |
| --- | --- |
| Ad-hoc questions between scheduled reports | The gap where questions normally go unanswered |
| *"…and now break that down by X"* follow-ups | Each refinement is a sentence, not a new report |
| Cross-checking a figure someone quoted | Fast, and shows its working |
| First-pass exploration of an unfamiliar model | The catalog and measure descriptions do the orienting |
| Spanning two systems that do not join | See [cross-dataset links](cross-dataset-links.md) |

| Poorly suited | Why |
| --- | --- |
| The regulatory report you file every quarter | A fixed report deserves a fixed, reviewed definition — build it once in your BI tool |
| Anything where a wrong number has consequences and nobody checks | Verify, or do not automate the trust |
| Questions your model cannot express | The agent cannot invent business logic that is not encoded |
| Row-level detail about individuals | Deliberately blocked — see [Data privacy](data-privacy.md) |

The distinction: use it for the questions you would *ask a colleague*, not the ones you would *file*.

## Building trust in a new project

A short exercise, worth the fifteen minutes on a newly connected project:

1. **Ask three questions you already know the answer to.** Match them against a report you trust.
2. **Expand the query on each.** Confirm it used the measures you would have used.
3. **Skim the [catalog](catalog.md).** Note empty columns, unlabelled code columns, and measures with no description — these are where future answers will go wrong.
4. **Ask one deliberately ambiguous question** to see how it handles it.
5. **Fix the worst gap in your model.** A missing measure description or an unlabelled code column improves every answer afterwards.

You will learn more about your own semantic model than about ClowdBI. That is normal, and it is the point.

## A quick self-test

Before acting on an answer, ask: **could I explain to a colleague where this number came from?**

- **Yes** — you know the measure, the grain, and the filter. Act on it.
- **No** — expand **Show query**. Thirty seconds, and you either can explain it or you have found the problem.

That question, asked consistently, is worth more than any amount of guidance on this page.
