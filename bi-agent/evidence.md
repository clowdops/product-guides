[← ClowdBI](README.md) · [← Asking questions](chat.md) · [Dashboards →](dashboards.md)

# Evidence & citations

**On this page:** [What gets cited](#what-gets-cited) · [Reading the markers](#reading-the-markers) · [The coverage line](#the-coverage-line) · [Sentence types](#sentence-types) · [The evidence panel](#the-evidence-panel) · [Evidence grades](#evidence-grades) · [The pins](#the-pins) · [The "checked" marker](#the-checked-marker) · [When evidence cannot be shown](#when-evidence-cannot-be-shown) · [Answers with no citations](#answers-with-no-citations) · [What this does and does not prove](#what-this-does-and-does-not-prove)

Every answer ClowdBI writes is annotated: each factual claim is linked back to the query that produced it, and the answer tells you how much of itself is actually grounded.

This page explains what the markers mean. For the conversation itself, see [Asking questions](chat.md).

## What gets cited

The agent classifies its own sentences into three kinds:

| Kind | Example | Marked? |
| --- | --- | --- |
| **Fact** | *"Revenue was €4.2M in Q3."* | Yes — always |
| **Interpretation** | *"That is the strongest quarter since the product launch."* | Not by default |
| **Recommendation** | *"Worth checking whether the northern region can sustain it."* | Not by default |

Only facts carry inline markers, because only facts can be traced to a query. An interpretation rests on the facts around it, and a recommendation rests on judgement — marking them with a citation would imply a query supports something no query can support.

## Reading the markers

A cited fact carries a small superscript number:

> Revenue was €4.2M in Q3 `[1]`, up 12% on Q2 `[2]`.

Click a marker to open the evidence behind that claim.

An **uncited fact** carries a **⚠** instead of a number. That means the agent stated something as fact but no query run in this turn supports it. It is not hidden and it is not softened — the marker is there so you can see the gap and decide what to do about it.

> [!TIP]
> An uncited fact is usually one of two things: a figure the agent carried over from earlier in the conversation, or general knowledge that did not come from your data at all. Both are worth checking. Ask *"where does that number come from?"* and the agent will either query for it or tell you it did not.

## The coverage line

Under every annotated answer sits one line summarising how grounded it is:

| What you see | What it means |
| --- | --- |
| **✓ all 6 facts cited** | Every factual claim traces to a query run this turn |
| **6 facts · 4 cited · 2 uncited ⚠** | Two claims have no supporting query |
| **… · 1 unplaced** | The agent annotated a claim whose wording did not match its own answer |

**Unplaced** is counted separately from uncited because it is a different failure. An uncited claim is visible in the text with a ⚠ you can click. An unplaced one never reached you as a marker at all — the agent recorded a claim, but its wording did not line up with the prose it actually wrote, so there is nothing to click. Folding it into the uncited count would leave a number the line could not explain.

> [!IMPORTANT]
> The coverage line is always present under an annotated answer, including when everything is cited. Silence would be ambiguous — a fully grounded answer and an answer nobody checked would look the same.

## Sentence types

When an answer contains interpretations or recommendations, the coverage line offers **show sentence types**, with a count of each.

Turning it on marks those sentences too, so you can see at a glance which parts of the answer are measurement and which are the agent's reading of it. It is off by default because most of the time you want to read the answer, not audit its rhetoric — but for anything you are about to act on, it is worth one click.

## The evidence panel

Clicking any marker opens the evidence for that claim. The panel shows the claim's own words as its subtitle, its kind as a badge, and one entry per piece of evidence.

<!-- Screenshot: ![Evidence panel — the claim, its recorded query, and the result grid](images/evidence-panel.png) -->

For a query-backed claim, the entry **is** the recorded query and its result — the same view as the **Show query** disclosure on the answer, reached from the claim instead of from the answer as a whole. There is one renderer for a recorded query, so the two can never disagree.

A claim with no evidence says so plainly: *"Uncited — this fact rests on no query run this turn."*

## Evidence grades

Each entry carries a grade, describing how directly it supports the claim:

| Grade | Meaning |
| --- | --- |
| **verbatim** | The claim quotes the evidence exactly — rendered as a quotation |
| **derived** | The claim is computed from the evidence |
| **paraphrase** | The claim restates the evidence in other words |

Only verbatim evidence is rendered as a quote. A derived or paraphrased figure is never dressed up as one, because the visual difference between *"this is what the data says"* and *"this is what I made of what the data says"* is exactly the distinction worth preserving.

## The pins

Under each entry, a line records what the evidence was pinned to:

```
model Sales · dataset Orders + Customers · recorded 2026-07-28T09:14:02Z
```

The model, the datasets involved, and when the result was captured. This is what lets you reproduce an answer, or explain why re-asking the same question a month later gives a different number.

## The "checked" marker

Some evidence entries carry a green **checked** marker. Hovering it shows the scope, and the wording is fixed:

> Result checked against its query at answer time — not a check of the sentence above.

Read that carefully, because the distinction is the whole point. The check confirms that the result the agent reported is the result its query actually returned. It does **not** confirm that the query was the right query, or that the sentence built on it is a fair reading.

It catches one specific failure — an answer that does not match its own data — and it makes no claim about any other.

## When evidence cannot be shown

An evidence entry always renders as something. Three states say why the content is not there:

| State | What happened |
| --- | --- |
| **Evidence you don't have access to** | The underlying result is outside what you may read |
| **Evidence no longer available** | It has aged out or been removed |
| **Evidence superseded** | The pin is no longer the latest version of what it names |

None of these renders as an empty panel. A missing explanation and a missing result look different, because they are different.

There is one more refusal worth knowing: a citation can only reach evidence from **its own turn**. A reference naming a different turn is refused and says so — the agent binds citations to the exchange that produced them, so anything else did not come from where it claims.

## Answers with no citations

An older answer — produced before citations, or in a conversation that predates them — shows:

> *produced before citations — not annotated*

This is deliberately different from *"0 of 6 cited"*. One answer was checked and found to have no support; the other was never checked at all. The **Show query** disclosure still works on those answers.

## What this does and does not prove

Citations answer *"where did this number come from?"* completely and reliably. That is a real and useful guarantee, and it is the fastest way to catch the most common failure — a plausible answer built on the wrong measure or the wrong filter.

They do not answer *"is this the right question?"* or *"does this measure mean what I think it means?"*. A perfectly cited answer can still be misleading if the measure is defined differently from how you read its name, or if the grain is wrong.

For those, see [Asking good questions](asking-good-questions.md), which covers the four ways a plausible-looking answer goes wrong — and note that citations catch exactly one of them.
