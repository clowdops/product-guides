[← ClowdOps](README.md) · [← Projects, Sandboxes & Credentials](your-workspace.md) · [Chat →](chat.md)

# Artifacts

**On this page:** [What an artifact is](#what-an-artifact-is) · [Where they live](#where-they-live) · [Creating one](#creating-one) · [The library](#the-library) · [Opening one](#opening-one) · [Versions](#versions) · [Comparing two versions](#comparing-two-versions) · [Editing](#editing) · [Approving a version](#approving-a-version) · [Sending one](#sending-one) · [Binary artifacts](#binary-artifacts) · [Archiving and retention](#archiving-and-retention) · [Why the project boundary matters](#why-the-project-boundary-matters)

An **artifact** is a document the agent and your team work on together — a weekly digest, an incident brief, a findings report, a customer-facing summary. It is drafted, revised over time, and approved when it is right.

Open the **Artifacts** tab inside any project.

## What an artifact is

Chat output is ephemeral. The agent produces a good summary, it scrolls away, and next week somebody asks it to produce the same thing again from scratch.

An artifact is that output made durable and revisable: it has a title, a full version history, an approval state, and it lives beside the project rather than inside one conversation.

## Where they live

Artifacts are **project-scoped**, and the project is not a filter — it is the confidentiality boundary the server enforces on every read. An artifact created in one project is not listed in another and cannot be opened from there, even by someone who knows its identifier.

This is why the tab sits beside the project's Members and Credentials rather than in organisation settings.

## Creating one

Ask the agent, in chat:

> *"Draft a weekly digest of this week's findings."*
> *"Write up what we just found as an incident brief."*

The artifact appears in the library, marked as drafted by the agent. You can also write one directly by opening an existing artifact and saving a new version — the library itself is populated by the agent in ordinary use.

## The library

<!-- Screenshot: ![Artifacts library — title, kind, approval state and last update](images/artifacts-library.png) -->

Each entry shows its title, its kind, whether it was drafted by the agent or created here, when it was last updated, and two badges where they apply: **approved** and **archived**.

## Opening one

**Open** brings up the artifact panel: the version strip along the top, the content below, and the actions beneath that.

<!-- Screenshot: ![Artifact panel — version strip, body, and approve action](images/artifact-panel.png) -->

## Versions

Every save creates a new version. The strip shows them as `v1`, `v2`, `v3` …, with a **✓** on the approved one.

Click any version to view it. Nothing is ever overwritten — a version you can see is a version you can go back to.

Beneath the content, a line names the selected version, whether the agent or a person authored it, and when.

## Comparing two versions

**Double-click** a version in the strip to compare it against the one currently selected. The panel switches to a line-level diff showing what changed between them.

This is what an approval decision usually turns on: not what the document says, but what changed since the last version somebody agreed to.

Double-click the same version again to leave the comparison.

## Editing

The body is directly editable. **Save as new version** commits your edit as the next version in the strip.

If somebody else saved while you were editing, the save is refused and you are told to reopen. This is deliberate — your next action should be to read what they wrote, not to retry and overwrite it.

## Approving a version

**Approve this version** records that the content is agreed.

> [!IMPORTANT]
> **Approval records agreement about content. Sending or publishing is always a separate action.** Approving a customer-facing brief does not send it to the customer.

Two rules follow from approval naming an exact version:

- **You must save an edit before approving.** The panel says so when the body is dirty — approval names a version, and unsaved text is not one.
- **A version that changed underneath you cannot be approved by accident.** Approval is submitted against the exact version on screen; if it is no longer what the server holds, the approval is refused rather than silently applied to the new content.

## Sending one

An approved artifact is what the agent reaches for when you ask it to send something:

> *"Send the approved digest to the ops channel."*

The agent sends the artifact's content through a [notification channel](notifications.md). The two-step shape — approve the content, then send it — is what stops a draft going out because somebody asked the agent to "send the digest" while it was still being written.

## Binary artifacts

Some artifacts hold binary content rather than text — a generated image, an exported file. They are stored and versioned here like any other, but they **cannot be edited in the panel and cannot be sent over a notification**. The panel says so, with the content size.

## Archiving and retention

**Archive** (administrators) takes an artifact out of active use. It remains readable, and its content becomes read-only.

Content removed under a retention policy renders as its own state, with an explanation — not as an empty document. An artifact whose body has aged out looks different from one that was saved empty, because those are different facts.

## Why the project boundary matters

Two things follow from artifacts being project-scoped, and both are worth knowing before you decide where work happens:

- **Sensitive drafting belongs in its own project.** An incident brief naming individuals should live where only the people handling the incident have access — not in the general project everybody is a member of.
- **Erasure does not reach here.** If a person's details were written into an artifact, [erasing their contact record](../common/contacts.md#erasing-a-person) does not remove them from the document. The artifact is a separate place, and it has to be dealt with separately.
