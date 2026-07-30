[← Docs](../README.md) · [Common](README.md) · [← Connections](connections.md) · [Packs →](packs.md)

# Contacts

**On this page:** [What the registry is](#what-the-registry-is) · [The directory](#the-directory) · [How contacts get here](#how-contacts-get-here) · [Adding and editing](#adding-and-editing) · [Contact lists](#contact-lists) · [Who can see what](#who-can-see-what) · [Duplicates and merging](#duplicates-and-merging) · [Knowledge review](#knowledge-review) · [Erasing a person](#erasing-a-person) · [Re-adding someone who was erased](#re-adding-someone-who-was-erased) · [The change record](#the-change-record)

The contact registry is your organisation's shared record of **people it knows about** — colleagues, customers, external collaborators, and people the agent has encountered but not yet identified.

Three pages sit under Settings: **Contacts**, **Contact lists**, and **Contact settings**.

> [!IMPORTANT]
> **This is a directory, not a login system.** Nothing on these pages grants anyone access to anything. A contact is a record *about* a person; a member is an account that can sign in. The two are related — a contact can be linked to a member — but adding somebody here gives them nothing.

## What the registry is

Before it existed, each product kept its own idea of who a person was. The same customer appeared as an email address in one place, a name in another, and a row in a third, with nothing tying them together and no single place to answer *"what do we hold about this person?"*.

The registry is that single place. It matters most for two things: getting a person's identity right across products, and being able to act completely when they ask you to erase them.

## The directory

**Settings → Contacts.**

<!-- Screenshot: ![Contacts directory — search, kind and list filters, and the contact table](images/contacts-directory.png) -->

Each contact carries a name, a kind, an affiliation, one or more handles, and its list memberships.

| Kind | Meaning |
| --- | --- |
| **Member** | Also has a platform account in this organisation |
| **Guest** | A recurring external collaborator |
| **External** | Someone the organisation knows |
| **Unresolved** | A person we have observed but not yet identified |

A **handle** is a way of reaching or recognising someone — usually an email address. The primary handle shows in the table with a **verified** marker when it has been confirmed; additional handles show as a `+N` count.

Filter by search text, kind, or list. Administrators get one extra filter: by default the directory shows **active** contacts only, and administrators can switch it to show **merged** or **erased** records instead.

## How contacts get here

Two ways, and the empty state says so because it is the one thing a new user cannot guess:

- **Somebody adds one** on this page.
- **The agent records a person** during a conversation — a name that came up in a run, an address a report was sent to.

The second is why *Unresolved* exists as a kind. The agent noticed a person; nobody has yet said who they are.

## Adding and editing

**Add contact** takes a name and at least one handle. Click any contact to open its detail view, where you can edit fields, add and remove handles, set which handle is primary, change list membership, and link the contact to a platform account.

## Contact lists

**Settings → Contact lists.**

A list is a named group of people — a pilot cohort, a customer segment, an escalation group.

> [!NOTE]
> **A list holds people and nothing else.** No consent state, no subscription status, no meeting history. Those belong to the product that owns them, and keeping them out of the registry is what stops the directory from quietly becoming a marketing database.

Each list shows its name, how many people are on it, and who it is shared with. Two labels appear on lists you cannot fully manage:

- **Maintained automatically** — the list belongs to a product, which keeps its membership current. Editing it by hand would be overwritten.
- **Owner has left** — the person who created it is no longer in the organisation, so administrators manage it.

What a new list is visible to depends on your organisation's sharing posture, and the page tells you which applies before you create one.

## Who can see what

**Settings → Contact settings** (administrators only) carries one organisation-wide dial.

| Setting | Effect |
| --- | --- |
| **Everyone** | Every member sees every contact. Right for a team working from one shared address book. |
| **Only what is shared** | Members see the contacts they added, plus anyone on a list shared with them. Right when different teams should not see each other's people. Administrators always see everything. |

Changing this alters no contact. It changes who the directory shows to whom, and switching back restores the previous view.

**The directory says which applies.** When the organisation is set to *only what is shared*, the Contacts page states how many contacts you can see and warns that colleagues may see a different set. Two people comparing lists should never be left to work out for themselves that the tool is behaving correctly.

## Duplicates and merging

The same person is easily recorded twice — once as `j.smith@acme.com`, once as `jsmith@acme.co.uk`.

Administrators see a **Possible duplicates** card at the top of the directory when a lookup matched more than one contact. Nothing is ever merged automatically.

Merging asks you to pick the duplicate. Its handles and list memberships move to the surviving record, and:

> [!NOTE]
> The duplicate is **kept as a pointer**, not deleted. Anything that already referred to it — a past conversation, a report, another product's record — still resolves to the right person.

## Knowledge review

**Settings → Knowledge review** (administrators only). The page appears only when there is something to review.

Where the duplicates card reacts to a lookup you just made, knowledge review is the queue of merges the platform has *proposed on its own* — two records it believes are the same person.

Each row shows the pair, a confidence percentage, and a **consequential** flag when the merge would change something beyond the registry.

Opening one shows:

| | |
| --- | --- |
| **Survivor / Merged away** | Both records side by side — handles, lists, and what happens to each |
| **Evidence** | Why it was proposed: *"Resolved together before"* or *"Same name and email domain"*, with confidence |
| **Note** | Whether this pair was raised before, and how it was resolved then |
| **Reversible** | An administrator can unmerge afterwards, while the handles stay unclaimed |

Three outcomes: **Merge**, **Merge (flipped)** if the proposal picked the wrong survivor, or **Different people…** which rejects it with an optional reason and stops it being suggested again.

> [!NOTE]
> This is a separate queue from [Approvals](approvals.md) on purpose. Approvals decides whether the platform may *do* something; knowledge review decides whether something the platform *believes* is true. They carry different badges, live on different pages, and never appear in each other's lists.

## Erasing a person

This is the data-subject erasure — the one you run when somebody exercises a right to be forgotten. It is on the contact's detail view, and it **cannot be undone**. You are asked to type an acknowledgement before it proceeds.

<!-- Screenshot: ![Erase dialog — what happens, and the typed acknowledgement](images/contacts-erase.png) -->

### What it does

- Their name, company and every handle are deleted.
- They are removed from every contact list.
- Products holding data about this person are **asked to delete it**. Anything a product must keep for a legal reason is **recorded as an exception rather than silently kept**.
- A one-way marker is stored so a future import or sync cannot quietly bring them back. An administrator can lift it deliberately, and that is recorded.
- An anonymised placeholder row remains so existing references do not break. It carries nothing that identifies them.

### What it does not reach

> [!IMPORTANT]
> Details about this person that were **typed into past conversations** or **written into generated documents** live outside the registry and are **not** removed by this action.

If somebody described a customer in a chat message, that text is in the conversation, not in the contact record. Erasure cannot reach it. Plan for this before you promise a completion date to the person asking — you may need to delete conversations or [artifacts](../cloud-agent/artifacts.md) separately.

### The record it produces

When the erasure finishes, the dialog stays open and shows **what this erasure did**: a per-store line for every place that holds data about the person, saying what was deleted, what was suppressed, what was deliberately retained and on what basis, and what could not be reached. Anything retained under a declared legal basis is called out separately, in amber, with the reason.

> [!TIP]
> **Capture this record.** It is the only moment it exists in full, and it is exactly what you would need if you later have to describe the erasure to the person it was performed for, or to a regulator. A summary is written to the change record below, but the per-store detail is on screen now.

### If the contact is linked to an account

A contact linked to an active platform account cannot be erased — registry erasure is not account deletion, and the dialog refuses with an explanation. Offboard the user, or unlink them from the contact, first.

## Re-adding someone who was erased

**Settings → Contact settings → Re-add someone who was erased.**

The one-way marker left by an erasure blocks that person's details from returning through an import or a later lookup. If they have since asked to be re-engaged, an administrator can lift the block by entering the handle.

Lifting it **re-creates nothing**. It only allows the person to be added again, by whoever does so next. The action is recorded against the administrator's name and the date.

> [!IMPORTANT]
> This is the one control that undoes part of a data-subject erasure. It is deliberately effortful, and it leaves a name on the record. Only lift a block when the person has actually asked to be re-engaged.

## The change record

**Settings → Contact settings → Recent changes** lists merges, erasures, links and sharing changes across the whole directory, with the actor and timestamp for each.

Individual contacts carry their own history on their detail view. Organisation-wide events also reach the main [Activity log](settings.md#activity).
