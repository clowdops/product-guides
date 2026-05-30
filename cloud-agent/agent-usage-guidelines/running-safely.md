[← Designing a good task](designing-good-tasks.md) · [Usage guidelines home](README.md)

# Running safely

**On this page:** [Safety is a posture, not a feature](#safety-is-a-posture-not-a-feature) · [Ephemeral by default](#ephemeral-by-default) · [Cap the spend](#cap-the-spend) · [Scope the credential, not just the grant](#scope-the-credential-not-just-the-grant) · [Put a ceiling on the expensive things](#put-a-ceiling-on-the-expensive-things) · [Independent backstops](#independent-backstops) · [Expect verification](#expect-verification) · [Putting it together](#putting-it-together)

Letting an agent touch real infrastructure is safe when a mistake stays *cheap and reversible* — not when you trust the agent to be perfect. This page is about engineering that property deliberately, so you can let the agent act without holding your breath.

## Safety is a posture, not a feature

ClowdOps gives you the controls — categorical grants, USD budgets, per-schedule allowlists, all described in [Guardrails & cost caps](../guardrails.md). This page is about the *posture* that makes good use of them: assume the agent will occasionally do something you didn't intend, and arrange the environment so that when it does, the blast radius is small and the bill is bounded.

The mental shift: don't ask *"can I trust the agent to get this right?"* Ask *"if it gets this wrong, how bad is it, and how fast do I recover?"* Make that answer cheap, and you can give the agent room to be useful.

## Ephemeral by default

The most effective safety control for experimental and provisioning work is **time-bounded resources**. Anything the agent stands up should carry an expiry from the moment it exists.

- **Tag everything with a TTL.** Have created resources carry an `expires-at` or `ttl` tag as a matter of course, so there's a machine-readable record of when each thing should be gone.
- **Make teardown part of the task.** A provisioning request should end with "…and tear it down when I'm done," so the happy path cleans up after itself.
- **Don't rely only on the agent to clean up.** The agent's teardown is the *happy path*; it is not a guarantee (see [Independent backstops](#independent-backstops)).

An environment that was always going to be deleted in an hour is one you can afford to let the agent build freely.

## Cap the spend

A USD budget is your hardest, simplest safety net — it bounds the worst case regardless of what the agent does.

- **Set a per-chat-session cap.** This is the best defence against a runaway loop: even if a single task goes sideways, its cost is bounded to that one session.
- **Set daily and monthly caps** at the sandbox and project level so no single context can run away with the account.
- **Keep experimental sandboxes on tight caps.** A sandbox you use to test intrusive operations should have a much lower ceiling than your everyday one — enough to spin up small, short-lived resources, not enough to leave expensive infrastructure running.

See [USD cost caps](../guardrails.md#usd-cost-caps) for where to set each.

## Scope the credential, not just the grant

Remember the two lines of defence: the **credential** is the hard outer boundary, and the **grant** gates what the agent reaches for within it. They are not redundant.

A grant can be misconfigured; a credential with no write permission *cannot* write no matter what. For any work where you want a guarantee rather than a policy, encode it in the credential:

- Use a **read-only credential** for pure diagnosis and investigation — the entire Tier 1 read phase needs nothing more.
- Give experimental work a credential scoped to a **dedicated test account or project**, never one with standing access to production.
- Reach for a broadly-permissioned credential only deliberately, in a sandbox that's tightly capped and ephemeral.

See [Credential Setup Recipes](../credentials/README.md) for ready-made read-only, cost-observer, and audit scopes.

## Put a ceiling on the expensive things

Categorical grants answer *"is this kind of action allowed,"* not *"how big."* Creating a tiny instance and creating a very large one are the same category — so the grant alone won't stop an expensive mistake. Put the size ceiling where it belongs: in the cloud account itself.

- Use your cloud provider's own guardrails (service control policies, organisation policies, quotas) to **deny the expensive-by-default resources** an experiment never needs — oversized instance families, GPU fleets, anything with a steep hourly rate.
- Cap resource sizes and counts at the account level so a single call can't provision something costly.

These ceilings live below ClowdOps and apply no matter what the agent or its grants decide. They turn "the agent could theoretically spin up something expensive" into "the account would refuse."

## Independent backstops

Every control above is stronger when something *other than the agent* enforces it:

- A **scheduled cleanup job** that deletes anything past its TTL tag — independent of whether the agent remembered to tear down.
- A **budget alarm** on the cloud account itself, separate from ClowdOps' caps, as a second tripwire.
- **Auto-disable on repeated failure** so a broken scheduled task stops itself instead of burning budget tick after tick (see [Guardrails](../guardrails.md#auto-disable-on-consecutive-failures)).

The principle: never let the agent be the *only* thing standing between an experiment and a runaway bill. Defence in depth means at least one backstop the agent can't forget or skip.

## Expect verification

Safety isn't only about cost and permissions — it's also about not trusting an *unverified* result. A change the agent claims it made, but never confirmed, is a quiet risk: it may have done nothing, or the wrong thing, while reporting success.

Build the check into the task, as covered in [Designing a good task](designing-good-tasks.md#always-include-a-success-criterion): the agent should end by *observing* that the symptom is resolved or the new state is healthy, not by asserting that a command ran. A run that verifies its own work is one you can act on without re-checking everything by hand.

## Putting it together

A sound posture for letting the agent do real, intrusive work:

1. **Dedicated, tightly-capped sandbox** with a credential scoped to a **non-production account**.
2. **Account-level ceilings** (SCPs / quotas) denying the expensive resource types outright.
3. **TTL tags on everything**, with an **independent janitor** that enforces them.
4. **Per-session and daily budget caps**, plus a **separate cloud-side budget alarm**.
5. **Tasks that state their scope and verify their own success** ([previous page](designing-good-tasks.md)).
6. **Prove interactively before scheduling**, and keep schedule allowlists minimal.

Get this posture in place once and intrusive experiments stop being scary — every mistake is bounded, reversible, and cheap. That's the whole goal: enough freedom for the agent to be genuinely useful, enough rails that being wrong never costs you much.

[← Back to the usage guidelines index](README.md)
