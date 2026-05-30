[← Where the agent earns its keep](the-value-tiers.md) · [Running safely →](running-safely.md)

# Designing a good task

**On this page:** [Describe the symptom, not the solution](#describe-the-symptom-not-the-solution) · [Always include a success criterion](#always-include-a-success-criterion) · [Scope it explicitly](#scope-it-explicitly) · [Stage risky work](#stage-risky-work) · [One-shot vs iterative](#one-shot-vs-iterative) · [A checklist](#a-checklist)

The same task can produce a brilliant result or a useless one depending entirely on how you phrase it. The agent is good at *figuring things out* — so a well-designed task gives it a clear goal and a clear definition of done, and gets out of the way. These are the habits that consistently produce trustworthy results.

## Describe the symptom, not the solution

The instinct of an experienced engineer is to hand over a solution: *"restart the worker process on host-3."* Resist it. If you already know the fix, you're using the agent as a remote shell, and you're betting your diagnosis was right.

Instead, describe what you observe and let the agent investigate:

| Instead of… | Try… |
| --- | --- |
| "Restart the stuck worker on host-3." | "Jobs stopped draining from the queue an hour ago — find out why and get them moving again." |
| "Open port 5432 on the database security group." | "The app can't reach its database in staging — diagnose the connection and restore it." |
| "Delete the old EBS snapshots." | "Find what we're paying for that isn't doing any work, show me the monthly cost, and clean up what's safe." |

The left column assumes the cause. The right column lets the agent *find* the cause — and frequently it's not the one you'd have guessed, which is the whole point of asking it.

> [!NOTE]
> Describing the symptom also gives you a better audit trail. The transcript shows what the agent checked and why, so even a wrong conclusion is a readable, correctable artifact — not a silent command that did the wrong thing.

## Always include a success criterion

This is the single highest-leverage habit. An agent that has "done something plausible" will stop; an agent told how success is *measured* keeps going until it's actually met — and tells you honestly if it can't get there.

Make the finish line explicit and verifiable:

- *"…and confirm the endpoint returns 200 before you call it done."*
- *"…verify the queue depth is dropping, not just that you restarted the process."*
- *"…show me the before-and-after metric so I can see the change took effect."*

A good success criterion is something the agent can *check by observation*, not something it can merely *assert*. "The service is healthy" is checkable; "I applied the fix" is not.

## Scope it explicitly

Ambiguity about scope is where unattended work goes wrong. State the boundary in the task itself:

- **Which environment:** *"…in staging only — do not touch production."*
- **Which resources:** *"…limited to the `web` fleet,"* *"…only resources tagged `team=payments`."*
- **How far to go:** *"…stop and report what you'd change before changing it,"* vs *"…go ahead and apply it."*

The agent will respect an explicit boundary. It cannot respect one you only had in your head. (Scope you state in the prompt is *in addition to* the hard limits your grants and credentials enforce — see [Running safely](running-safely.md).)

## Stage risky work

For anything that mutates infrastructure, ask for incremental, justified steps rather than a single sweeping action:

- *"Migrate them one at a time, verifying after each."*
- *"Justify the new instance size from the metrics before you resize anything."*
- *"Change one, confirm it's healthy, then do the rest."*

Staging turns a possible large mistake into a caught small one. It also surfaces the agent's reasoning *before* the bulk of the change, so you can stop it if the logic is off. This matters most for the optimisation and closed-loop work in [Tier 3 and Tier 4](the-value-tiers.md).

## One-shot vs iterative

Two modes of working, each suited to different work:

- **Interactive (you're at the keyboard).** Best for diagnosis and anything new or risky. You see the agent's plan unfold, you can redirect it, and you approve sensitive actions as they come up. Start here whenever you're not yet sure how the agent will approach something.
- **Scheduled (unattended).** Best for *proven, well-bounded* chores — a recurring waste sweep, a routine health check. A scheduled run has no human to answer questions or approve a borderline action, so only promote a task to a schedule once you've watched it run cleanly interactively, and keep its scope tight. See [Scheduled Runs](../schedules.md) for the mechanics and the per-schedule allowlist.

A reliable rule: **prove it interactively, then schedule it.** Don't hand a brand-new task straight to a schedule.

## A checklist

Before you submit a task, especially an unattended one:

- [ ] Did I describe a **symptom or goal**, not a pre-baked solution?
- [ ] Is there a **success criterion the agent can verify by observation**?
- [ ] Did I state the **scope** — environment, resources, how far to go?
- [ ] For mutating work, did I ask it to **stage and justify** rather than act in one sweep?
- [ ] Is this **interactive** (new/risky) or **scheduled** (proven/bounded) — and have I earned the right to schedule it?

Get these five right and the agent's output stops being a gamble and starts being something you'd put your name on.

Next: [bounding the task so a mistake stays cheap →](running-safely.md)
