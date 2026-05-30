[← ClowdOps](../README.md)

# Agent usage guidelines

**On this page:** [What this section is](#what-this-section-is) · [The one idea to take away](#the-one-idea-to-take-away) · [The articles](#the-articles) · [A quick self-test](#a-quick-self-test)

Knowing *how* to drive ClowdOps is the easy part — you type a request and the agent runs. The harder, more valuable skill is knowing **which jobs to hand it**. This section is about judgement: where an AI agent genuinely outperforms your existing tooling, where it doesn't, and how to phrase and bound a task so the result is something you'd trust.

## What this section is

These pages are opinionated. They are written for cloud-ops, platform, and SRE engineers who already live in Terraform, `kubectl`, and the cloud console, and who are deciding whether — and how — to let an agent into that workflow. Nothing here is a feature reference; for the mechanics of grants, budgets, and scheduling see [Guardrails & cost caps](../guardrails.md).

## The one idea to take away

> An agent is not a cheaper way to run the work you already automate. It is a way to do the work you **can't** automate — the ambiguous, one-off, investigate-then-act tasks that never paid back the cost of a pipeline.

Most cloud automation answers a **build problem**: a known desired state, applied repeatably, reviewed as a diff. Infrastructure-as-code owns that, and it should keep owning it — a deterministic outcome deserves a deterministic tool.

The agent earns its place on **search problems**: *something is ambiguous; investigate, form a hypothesis, act, verify, repeat.* That loop is exactly where determinism gives you nothing, because you don't know the answer in advance. Diagnosing a broken deployment, sweeping for waste, standing up a throwaway environment to reproduce a bug — these are searches, not builds. Keep that distinction in mind and almost every other guideline here follows from it.

## The articles

| Article | What it covers |
| --- | --- |
| [The agent and your pipelines](agent-vs-iac.md) | Why a non-deterministic agent should not own a deterministic pipeline — and how the two complement each other instead of competing |
| [Where the agent earns its keep](the-value-tiers.md) | The four classes of work the agent is genuinely good at: diagnosis & remediation, ephemeral provisioning, optimisation & rebalancing, and closed-loop operations |
| [Designing a good task](designing-good-tasks.md) | How to phrase a request so you get a trustworthy result: describe symptoms not solutions, set a success criterion, scope it, and expect the agent to verify its own work |
| [Running safely](running-safely.md) | The operational posture for letting the agent touch real infrastructure: ephemeral-by-default, cost caps, credential scoping, and independent backstops |

## A quick self-test

Before you hand the agent a task, ask: *if I gave this same task to ten different engineers, would I expect the same exact change from all ten?*

- **Yes** → it's a build problem. It wants a pipeline, not an agent. Write the code, review the diff, apply it.
- **No — they'd each investigate and might do it differently** → it's a search problem. This is where the agent shines.

The rest of this section is about making the most of the second case.
