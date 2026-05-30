[← Usage guidelines](README.md) · [Where the agent earns its keep →](the-value-tiers.md)

# The agent and your pipelines

**On this page:** [Build problems vs search problems](#build-problems-vs-search-problems) · [Why not let the agent own the pipeline](#why-not-let-the-agent-own-the-pipeline) · [The "cheap IaC" anti-pattern](#the-cheap-iac-anti-pattern) · [How they complement each other](#how-they-complement-each-other) · [A rule of thumb](#a-rule-of-thumb)

The most common mistake when adopting an agent is to point it at the work you already automate well and ask it to do that — only conversationally. It will often succeed, which makes the mistake easy to keep making. This page is about why that's the wrong target, and what the right one looks like.

## Build problems vs search problems

| | **Build problem** | **Search problem** |
| --- | --- | --- |
| You know the desired end state… | up front | only once you've investigated |
| The right tool is… | deterministic (IaC, a script, a pipeline) | adaptive (an agent) |
| Success looks like… | the same result every time | the right result *this* time |
| Reviewed as… | a diff, before it runs | an outcome, after it runs |
| Examples | provision the standard VPC, roll out a release, apply a config | find why the deploy broke, reclaim waste, reproduce a bug in a fresh environment |

Infrastructure-as-code is the correct answer to a build problem and the agent does not improve on it. An agent is the correct answer to a search problem, where IaC was never an option because you couldn't write the steps down in advance.

## Why not let the agent own the pipeline

An agent is **non-deterministic by nature**. Given the same prompt twice it may take different paths, reach for different APIs, and — occasionally — reach a different conclusion. That variability is a *feature* on a search problem: it's the agent exploring. It is a *liability* on a build problem, where the entire value of the pipeline is that it produces the same reviewed outcome every single time.

A deterministic pipeline gives you things an agent structurally cannot:

- **A reviewable diff** before anything changes.
- **Idempotence** — run it twice, get the same state.
- **A version-controlled source of truth** you can roll back to.
- **Auditability** that doesn't depend on reading a transcript.

If a task's correctness depends on any of those properties, it belongs in code. Asking an agent to stand in for them trades away the exact guarantees that made the pipeline worth building.

> [!NOTE]
> This isn't a limitation to be fixed — it's the right division of labour. You wouldn't replace a unit test with a code review, or a backup job with a sticky note. Determinism and adaptivity are different tools for different shapes of problem.

## The "cheap IaC" anti-pattern

The tempting misuse is to treat the agent as a conversational shortcut around writing Terraform:

> *"Recreate our production VPC the way the staging one is set up."*

The agent can probably do it. But you've now produced a critical piece of infrastructure that has **no source of truth, no diff anyone reviewed, and no repeatable way to reproduce it.** The next person who needs to change it has nothing to read. You've spent the agent's adaptivity on a problem that wanted determinism, and you're left holding the worst of both worlds: a one-off artifact built by a process you can't replay.

The giveaway that you've wandered into this anti-pattern: **you already know exactly what you want built, and you'd be annoyed if the agent did it any other way.** That's a build problem wearing a chat prompt.

## How they complement each other

The productive pattern is not "agent *or* pipeline" — it's the agent working *around* your pipelines, in the gaps they don't cover:

- **Before** the pipeline: the agent reproduces a bug in a throwaway environment, or investigates which of five plausible causes is the real one, so you know *what* to codify.
- **Beside** the pipeline: the agent handles the long tail of one-off operational chores — reclaiming an orphaned volume, right-sizing an over-provisioned fleet, triaging a 3 a.m. alert — that were never worth a pipeline of their own.
- **After** the pipeline: the agent investigates *why* a deploy that passed CI still misbehaves in production, correlating live cloud state against the declared config.

In every one of these, the agent's output is often a *finding* or a *fix you then codify*, not a permanent unreviewed artifact. That's the healthy shape.

## A rule of thumb

Reach for the agent when **the hard part is figuring out what to do**, and reach for a pipeline when **the hard part is doing it the same way every time**. When a task has both — a tricky diagnosis *and* a change you'll want to repeat — let the agent do the diagnosis, then move the repeatable change into code.

Next: [the four classes of work the agent is genuinely good at →](the-value-tiers.md)
