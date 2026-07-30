[← Docs](../README.md) · [Common](README.md) · [← Packs](packs.md) · [Referrals →](referrals.md)

# Signals

**On this page:** [What a signal is](#what-a-signal-is) · [Signals vs the activity log](#signals-vs-the-activity-log) · [The queue](#the-queue) · [Reading a signal](#reading-a-signal) · [Priority and the alert threshold](#priority-and-the-alert-threshold) · [Working a signal](#working-a-signal) · [Dismissing one](#dismissing-one) · [When a dismissed signal comes back](#when-a-dismissed-signal-comes-back) · [Expiry and history](#expiry-and-history) · [The digest](#the-digest) · [Who can do what](#who-can-do-what)

A **signal** is a condition the platform thinks is worth acting on — a budget approaching its cap, a run of guardrail denials, a schedule that keeps failing, a connection going unstable.

Open it at **Settings → Signals**.

## What a signal is

The unit here is the **condition**, not the event.

A schedule that has failed eleven times is one signal with eleven sightings — not eleven entries. Each new occurrence folds into the existing record, moves its *last seen* forward, and may raise its priority. What you are looking at is a list of *things that are true*, not a list of *things that happened*.

## Signals vs the activity log

This is the first question everybody asks, so it is worth answering before anything else.

| | [Activity](settings.md#activity) | Signals |
| --- | --- | --- |
| **Answers** | *What happened?* | *What is worth acting on?* |
| **Granularity** | Every occurrence | One record per condition |
| **State** | Per-user read state | Shared across the organisation |
| **Lifecycle** | None — it is history | New → picked up → acted on / dismissed |
| **Closing one** | Not a concept | Requires a reason somebody signs |

Signal-producing events keep appearing in both. The activity log is the record; this queue is the attention. Neither replaces the other.

## The queue

<!-- Screenshot: ![Signals queue — status tabs, priority filter, and the condition table](images/signals-queue.png) -->

Tabs filter by state:

| Tab | Shows |
| --- | --- |
| **Live** | Everything currently open |
| **New** | Nobody has picked these up yet |
| **Picked up** | Somebody has said they are on it |
| **Dismissed** | Deliberately set aside, with a reason |
| **History** | Expired records |

A second row filters by priority — **high**, **normal**, **low**, or any. A badge beside the page title counts what is new.

Each row shows the condition, its kind, priority, state, sighting count, when it was last seen, and its scope — the organisation, or a specific project or sandbox. A dismissed signal carries its dismissal reason on the row itself, so a set-aside condition that is still climbing never reads like a quiet one.

If some signals fall outside what you can see, a note at the bottom of the list says so. Two colleagues comparing the queue should never be left guessing why their lists differ.

## Reading a signal

Click any row.

**Sightings** — how many times, first seen, most recently seen, and when the record expires.

**Score** — the relevance, freshness and urgency figures behind the priority, the method that produced them, and where the observation came from. Provenance is not decoration: a score whose method is unknown cannot be judged, compared, or corrected.

**Evidence** — the references the condition rests on, each with a label, its kind, and how strong the link is. Evidence is pinned by reference, never copied.

**What was done** — anything already acted on this signal, including agent sessions that consumed it.

**Predecessor** — if this succeeds an earlier record of the same condition, when that one was first seen.

## Priority and the alert threshold

Priority is computed, not assigned, and it moves as the condition develops.

A signal below its alert threshold says so: *"Below its alert threshold: recorded and visible here, but not yet notified."* It is being tracked and it is on this page, but it has not earned an interruption. As sightings accumulate — or as the condition sharpens — it crosses the threshold and starts notifying.

This is why the queue is worth reading rather than waiting to be alerted by. The things that are only starting to go wrong are here before they page anybody.

## Working a signal

Two actions move a signal along, and they mean different things:

- **I'm on it** — marks the signal *picked up*, so a colleague opening the queue can see somebody has it. Available on new signals.
- **Mark acted on** — records that something was actually done about it.

Neither closes the condition. A condition that is still true stays true; these record what your organisation has done about it.

## Dismissing one

**Dismiss…** is for a condition you have judged and decided not to act on. It requires a written reason, and there is no way around that.

The reason is not paperwork. It is shown to whoever sees this signal next — including you, in three weeks, when you have forgotten why you set it aside.

> [!IMPORTANT]
> **Dismissing does not stop the platform watching.** It suppresses alerts *at or below the signal's current level*, and it keeps recording. If the condition gets worse, the signal reopens.

## When a dismissed signal comes back

A reopened signal carries its dismissal disclosure at the top of its detail view, above everything else: who dismissed it, when, and why — plus the moment it reopened, and the fact that it escalated above the level it was dismissed at.

Whoever is reading is being asked to reconsider a decision somebody already made, and they should know that before they read anything else.

## Expiry and history

Signals expire. A condition nothing has observed for a while stops being current, and its record moves to **History** rather than sitting in the live queue forever.

If the same condition recurs afterwards, a new signal is created and links back to its predecessor, so the history of a recurring problem stays connected.

## The digest

**Settings → System notifications** carries a **Signals** row: a daily digest of what is worth acting on — new conditions, how many repeat sightings folded into the quiet ones, and what was dismissed.

Immediate alerts still ride the existing event types (budget hits, guardrail denials, run failures). This is the summary, and the Signals page is there whether or not anyone subscribes.

## Who can do what

| Action | Who |
| --- | --- |
| Read the queue and open a signal | Any member |
| Pick up, mark acted on | Any member |
| Dismiss | Administrators |

Reading is member-level on purpose. A signal names a condition in your organisation's own infrastructure, and hiding it from the people expected to act on it is exactly how a queue becomes a table nobody reads. Dismissal is the decision that needs an owner, so that is where the restriction sits.
