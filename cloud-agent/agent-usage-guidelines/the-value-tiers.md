[← The agent and your pipelines](agent-vs-iac.md) · [Designing a good task →](designing-good-tasks.md)

# Where the agent earns its keep

**On this page:** [The four tiers](#the-four-tiers) · [Tier 1 — Diagnosis & remediation](#tier-1--diagnosis--remediation) · [Tier 2 — Ephemeral provisioning](#tier-2--ephemeral-provisioning) · [Tier 3 — Optimisation & rebalancing](#tier-3--optimisation--rebalancing) · [Tier 4 — Closed-loop operations](#tier-4--closed-loop-operations) · [Reading the tiers](#reading-the-tiers)

Once you've internalised that the agent is for search problems ([previous page](agent-vs-iac.md)), the next question is *which* search problems. In practice the genuinely valuable work clusters into four tiers, roughly ordered from "strongest fit" to "use with most care."

## The four tiers

| Tier | The work | Why the agent fits | Watch out for |
| --- | --- | --- | --- |
| **1 — Diagnosis & remediation** | "Here's a symptom, find the cause and fix it" | Pure search: many plausible causes, one real one | That it *verifies* the fix, not just applies a plausible one |
| **2 — Ephemeral provisioning** | Stand up throwaway infra, use it, tear it down | One-off and disposable — never worth a pipeline | Confirming the thing actually works before declaring success |
| **3 — Optimisation & rebalancing** | Reclaim waste, right-size, migrate to cheaper equivalents | Reasoning from live metrics, judging case by case | Over-eager changes; insist on staged, justified steps |
| **4 — Closed-loop operations** | Perceive a condition, react, verify, settle | A perception→action→verification loop with a clear target | Over-reaction to transient signals |

## Tier 1 — Diagnosis & remediation

**This is the agent's single strongest fit**, and the one that most clearly beats every alternative. The shape is always the same: you provide a *symptom*, not a solution, and the agent runs the loop a good engineer would — **investigate → hypothesise → act → verify → repeat.**

What makes it such a good fit is that diagnosis is *irreducibly* a search. A health check is failing and there are four plausible reasons — a security-group rule, a route, a NACL, a bad target. You don't know which until you look. A pipeline can't encode "look and figure it out"; that's precisely the part a human (or an agent) has to do. The agent reads the logs, traces the path, eliminates candidates, and lands on the real cause — then fixes the actual broken link rather than the first thing it touched.

**The reflection that matters here:** the value is in the *finding*, and the risk is in the *fix*. A confident, plausible-sounding remediation that doesn't actually resolve the symptom is worse than no remediation, because it looks like progress. The single most important habit when using the agent for diagnosis is to make verification part of the task — *"…and confirm the service is serving traffic again before you call it done."* A good diagnostic run ends by re-checking the original symptom, not by announcing that an API call succeeded.

> [!TIP]
> Diagnosis tasks are also the safest place to *start* with an agent, because the investigation phase is entirely read-only. You can build trust watching it reason over a problem before you ever grant it permission to change anything.

## Tier 2 — Ephemeral provisioning

The agent is excellent at standing up **disposable** infrastructure: a scratch cluster to host a service while you reproduce a bug, a temporary environment to validate a migration, a short-lived stack to load-test against. These are tasks that were never worth a pipeline precisely *because* they're one-off — the environment exists for an hour and then it's gone.

The fit here is different from Tier 1. Provisioning a known thing is closer to a build problem — so why give it to the agent at all? Because the *surrounding* work is a search: figuring out the right shape from a loose description, wiring up access, adapting when a step fails, and — crucially — **proving the result works.** The agent handles the whole arc (provision → deploy → smoke-test → report → tear down) as one adaptive flow, including the parts you'd otherwise babysit.

**The reflection that matters here:** the failure mode is declaring victory too early. "The provisioning call succeeded" is not the same as "the service is up and answering." Insist that an ephemeral environment is validated by an actual request against it before the agent reports success — and that teardown is part of the same task, so a forgotten environment doesn't quietly bill you for a week. (See [Running safely](running-safely.md) for how to enforce that with TTLs and backstops rather than trust.)

## Tier 3 — Optimisation & rebalancing

This is the "engineers would genuinely thank you for this" tier: reclaiming orphaned volumes and idle addresses, right-sizing an over-provisioned fleet from its own metrics, migrating resources to a cheaper-but-equivalent class. These are real, recurring chores that rarely get done because no single one is worth a project.

They fit the agent well because each decision needs *judgement from live data*: is this unattached volume genuinely abandoned, or detached for a reason? Is this instance over-provisioned, or just quiet this week? A static rule gets these wrong; reading the actual usage and reasoning case by case is exactly the agent's strength. Most of these changes are also **reversible**, which makes them comparatively safe to let the agent act on.

**The reflection that matters here:** the danger is an over-eager agent making a sweeping change in one motion. The right posture is **staged and justified** — *"migrate them one at a time, verifying after each,"* *"justify the new size from the metrics before you change anything."* You want the agent to show its reasoning and move incrementally, so a wrong call is caught at item one instead of item fifty. Optimisation work is where "explain before you act" pays off the most.

## Tier 4 — Closed-loop operations

The most "agentic" tier: the agent perceives a condition, takes an action, verifies the effect, and settles — a control loop with a measurable target. Reacting to a sustained load increase, draining and replacing an unhealthy node, responding to a capacity signal.

This is genuinely powerful and genuinely the tier to approach with the most care, because the same non-determinism that makes the agent good at search makes a *control loop* delicate. The question is no longer "can it do the action" but "does it react to the **right** signal, and not over-react to noise." A momentary spike is not a trend; a single failed probe is not an outage.

**The reflection that matters here:** define the trigger precisely and demand evidence of the effect. *"…when CPU stays above the threshold for a sustained period,"* not *"…when CPU is high"*; *"…confirm the new capacity is taking traffic before you stop adding,"* not *"…scale out."* Closed-loop tasks are where you should watch the agent's judgement most closely before trusting it unattended, and where a tight budget cap is your most important safety net.

## Reading the tiers

The ordering is deliberate. **Tier 1 is where to start** — read-only investigation builds trust at zero risk. **Tiers 2 and 3** add controlled, mostly-reversible changes once you trust the diagnosis. **Tier 4** is where the agent acts on its own perception in a loop, and is worth the most scrutiny.

Across all four, the same two themes recur, and they're the subject of the next two pages: **phrase the task as a goal with a verifiable success criterion** ([Designing a good task](designing-good-tasks.md)), and **bound it so a mistake stays cheap** ([Running safely](running-safely.md)).
