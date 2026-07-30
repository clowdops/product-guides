[← Docs](../README.md) · [Common](README.md) · [← Contacts](contacts.md) · [Signals →](signals.md)

# Packs

**On this page:** [What a pack is](#what-a-pack-is) · [The list](#the-list) · [Creating one](#creating-one) · [Capturing one from chat](#capturing-one-from-chat) · [What a draft holds](#what-a-draft-holds) · [Publishing](#publishing) · [Bindings — how a pack reaches a session](#bindings--how-a-pack-reaches-a-session) · [Seeing which packs a session got](#seeing-which-packs-a-session-got) · [Versions and rollback](#versions-and-rollback) · [Deprecating and disabling](#deprecating-and-disabling) · [Platform default packs](#platform-default-packs) · [Who can do what](#who-can-do-what)

A **pack** is durable guidance your organisation publishes into its agent sessions — the conventions, preferences and reference files you would otherwise re-explain in every conversation.

Open it at **Settings → Packs**.

## What a pack is

Every team accumulates things the agent should just know. *Production changes go through the change window.* *We tag everything with a cost-centre.* *Here is our runbook for a failed deploy.*

Typed into a chat, that guidance lasts one conversation. A pack makes it durable: authored once, versioned, and delivered into sessions automatically.

> [!IMPORTANT]
> **A draft changes nothing.** Authoring and editing a pack has no effect on any session until an administrator publishes it. This is what makes packs safe to write collaboratively — anyone can propose a convention, and adopting it is a separate, deliberate act.

## The list

<!-- Screenshot: ![Packs list — source, product scope, status, current version and bindings](images/packs-list.png) -->

| Column | What it means |
| --- | --- |
| **Name** | Lowercase-kebab, for example `deployment-conventions` |
| **Source** | **org** — yours · **default** — shipped by the platform |
| **Product** | Which product's sessions it applies to |
| **Status** | **active** · **deprecated** · **disabled** |
| **Current** | The published version being delivered |
| **Bindings** | How many scopes deliver it automatically |

Filter by source and status. Click any row to open it.

## Creating one

**New pack** takes two fields:

- **Name** — lowercase-kebab, and it is how the agent refers to the pack.
- **Description** — one line. This is the pack's catalog entry, and it is what the agent reads when deciding whether a pack is relevant to the task in front of it. Write it for that reader: *"how we tag and size EC2 instances"* is useful; *"AWS stuff"* is not.

The pack is created as a draft.

## Capturing one from chat

You do not have to author packs on this page. Ask the agent, mid-conversation, to remember something for future sessions:

> *"Remember for future sessions: production deploys only happen Tuesday and Thursday, and always need a rollback plan attached."*

The agent drafts a pack from the conversation. It arrives here as a draft like any other, and an administrator publishes it — or does not.

This is usually the better path. The guidance is captured at the moment it is being explained, in the words it was explained in.

## What a draft holds

Open a pack and use the **Draft** tab.

**Prompt fragments** — the guidance itself, each with a title and its text. Several small fragments beat one long one: the agent can pull in the relevant piece rather than the whole document.

**Assets** — files the pack carries: a template, a policy document, a reference table.

**Applicability** — an optional list of credential providers. Leave it empty and the pack is always eligible. Name providers and the pack is delivered **only when a matching credential is present in the session** — an AWS tagging convention is noise in a session that only touches Azure.

Each saved draft can carry a **change note**, which shows in the version history.

## Publishing

**Publish** turns the current draft into a numbered version and makes it the pack's **current** version. From that moment, new sessions that receive this pack receive that version.

Publishing is administrator-only.

## Bindings — how a pack reaches a session

A published pack reaches a session in one of two ways.

**Bound** — an administrator attaches the pack to a scope on the **Bindings** tab. Every session in that scope receives it automatically, without anybody asking.

**On demand** — the agent reads the pack catalog, sees a description matching the task in front of it, and pulls the pack in itself.

This is why the description matters so much. A bound pack is delivered regardless; an unbound one is only ever found through its catalog line.

> [!TIP]
> Bind the packs that apply to *everything a scope does* — house conventions, escalation rules. Leave the situational ones unbound with a sharp description, so they arrive when relevant and stay out of the way otherwise.

## Seeing which packs a session got

The [ClowdInfra chat header](../cloud-agent/chat.md#active-packs) shows a chip per active pack — `name v3` — tinted by source, with a tooltip saying whether it was **bound by your org** or **activated on demand**.

A session that received no organisation packs shows no chips at all.

## Versions and rollback

The **Versions** tab lists every published version with its change note and who published it.

**Make this version current** rolls back — the named version becomes the one delivered to new sessions. Nothing is deleted, and you can roll forward again the same way.

Sessions already running keep the version they started with. A session's behaviour never changes underneath it.

## Deprecating and disabling

Both are administrator-only, and they do different things:

| Action | Effect |
| --- | --- |
| **Deprecate** | It leaves the on-demand catalog and attracts no new bindings, but **keeps delivering through existing bindings** |
| **Disable** | New sessions stop receiving it **entirely**; running sessions keep it; stamped history stays readable |

Deprecate is for *"stop reaching for this, but don't break the teams already relying on it."* Disable is for *"this is wrong, stop using it."*

Neither destroys history. A past session that received a pack still shows which version it got, whatever the pack's status is now.

## Platform default packs

Some packs are shipped by the platform rather than authored by you. They show **source: default** and cannot be edited.

An administrator can **disable a default pack for the organisation** — new sessions stop receiving it, running sessions keep it — and re-enable it later, after which new sessions receive it again. A disabled default shows *(org-disabled)* beside its name.

## Who can do what

| Action | Who |
| --- | --- |
| View packs, read versions and bindings | Any member |
| Create a pack, edit its draft | Any member |
| Publish, roll back | Administrators |
| Deprecate, disable, re-enable | Administrators |
| Add and remove bindings | Administrators |
| Disable a platform default for the org | Administrators |

Members can see and author because a draft changes nothing — hiding the page from them would remove discovery without removing any authority. Everything that *does* change a session is administrator-only and re-checked server-side, not merely hidden.
