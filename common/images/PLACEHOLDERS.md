# Screenshot placeholders

Screenshots to capture for the **shared** guide pages — the ones under `common/`,
which look the same in every ClowdOps product. Drop PNGs in this folder using the
exact filenames below so the existing `<!-- Screenshot: ... -->` references
resolve when uncommented.

Capture at a standard desktop width, light theme, against a **demo organisation**
— no real customer data, no real names, no secrets. These pages are the ones a
DPO or an auditor is most likely to read, so a screenshot showing a real person's
name is a worse mistake here than anywhere else in the guide.

Capture from either product; these surfaces are identical in both.

## Priority — the guide leans on these

| Filename | Page | What to capture |
| --- | --- | --- |
| `contacts-erase.png` | [contacts.md](../contacts.md#erasing-a-person) | The erase dialog **before** confirming: the "what happens" list, the "what this does not reach" note, and the typed acknowledgement field. Use an obviously fictional contact |
| `approvals-queue.png` | [approvals.md](../approvals.md#opening-it) | The queue with a **waiting** row showing its payload preview, the *"was gate (org)"* policy line, and an expiry distance. Ideally a second row showing *executed, delivery unconfirmed* |
| `signals-queue.png` | [signals.md](../signals.md#the-queue) | The queue on **Live**, with a mix of priorities and at least one dismissed-but-reopened row carrying its dismissal reason inline |

## Supporting

| Filename | Page | What to capture |
| --- | --- | --- |
| `contacts-directory.png` | [contacts.md](../contacts.md#the-directory) | The directory with the search box, kind and list filters, and a handful of contacts across different kinds. Include the coverage line if the demo org is set to *only what is shared* |
| `connections-list.png` | [connections.md](../connections.md#opening-it) | The connections list showing **at least three different health badges** — the point of the page is that they differ. Include one `unknown` and one with a reason line |
| `packs-list.png` | [packs.md](../packs.md#the-list) | The packs table with both an **org** and a **default** pack, a current version, and a non-zero binding count |
| `settings-billing-page.png` | [settings.md](../settings.md#billing) | Billing — three stat cards, the buy-credits tile, and the transactions list. *(Pre-existing placeholder, not yet captured.)* |

## Optional extras

| Filename | Suggested use |
| --- | --- |
| `contacts-settings.png` | The sharing-posture radio pair and the erasure-block card — [contacts.md](../contacts.md#who-can-see-what) |
| `knowledge-review.png` | A merge proposal open, showing survivor vs merged-away and the evidence line — [contacts.md](../contacts.md#knowledge-review) |
| `signal-detail.png` | A reopened signal with its dismissal disclosure at the top — [signals.md](../signals.md#when-a-dismissed-signal-comes-back) |
| `pack-detail-draft.png` | The Draft tab with prompt fragments and applicability — [packs.md](../packs.md#what-a-draft-holds) |
