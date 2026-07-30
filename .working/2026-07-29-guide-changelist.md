# Product-guide change list — 2026-07-29

**Baseline.** The guide was last updated at `8208426` (2026-07-19 11:56 +0200, *"add bi product guide"*).
**Head.** `clowdops-console` @ `deae5c0` (2026-07-29), branch `harden/dev-foundation-2026-07-25`. Twenty commits land after the guide cut; sixteen of them change what a user sees.

The changes fall into two classes that need **different publication treatment**, so they are listed separately.

- **Class A — live and ungated.** Shipped behaviour that every entitled user already sees. The guide is stale about it *today*.
- **Class B — the eight common-infrastructure components.** Merged dark. Each requires a deployment flag *and* a per-organisation grant. `component-status.yaml` marks all eight `production_ready: false`.

---

## 0. Decision needed before drafting Class B

**Description.** Class B features are invisible to an organisation that has not been granted them — no sidebar entry, and the route itself redirects to Settings rather than explaining. That redirect is deliberate: `RequireComponent` declines to say *"this feature is not enabled for your organization"* because the message is itself information about a cohort rollout the tenant is not in.

A published guide describing those pages contradicts that design.

**Alternatives.**

| Option | Consequence |
| --- | --- |
| **(a) Write and publish now**, marked *"only if enabled for your organisation"* | Ready on day one, self-service. But it tells every reader the cohort exists, which is exactly what the console refuses to do — and most readers will look for pages they cannot reach. |
| **(b) Write now, hold in a branch, publish per component as its cohort opens** | Matches the rollout, no information leak. Costs one release gate per component. |
| **(c) Publish Class A now; treat Class B as a separate guide release later** | Simplest, but Class B drafting drifts and lands late. |

**Recommendation: (b)** — ship Class A immediately as a normal guide update, draft Class B in full now against a `feature/common-infra-guide` branch, and merge each component's pages the day its cohort opens. It keeps the guide honest with the product's own disclosure rule and still has copy ready in advance.

---

## 1. Two defects found while auditing (fix regardless)

The console's (?) help buttons deep-link into this repo from one map per product. Two entries do not resolve:

| Console constant | Target | Status |
| --- | --- | --- |
| `DOCS.settings*` (8 anchors: profile, security, org, members, plan, billing, usage, activity) | `cloud-agent/team-and-settings.md#…` | **404** — the file is `common/settings.md` |
| `DOCS.referrals` | `cloud-agent/referrals.md` | **404** — the file is `common/referrals.md` |

Both broke in the 2026-07-18 monorepo merge, when the settings surface moved into `console-ui` and the pages moved to `common/`. Fix is a one-line edit each in `packages/console-ui/src/lib/docs.ts` — it is a console change, not a guide change, but the guide owns the anchor slugs.

**Standing constraint from now on:** guide headings are in-product help targets. `BI_DOCS` deep-links `data-projects.md#choosing-the-ai-model` and `#budgets`; `DOCS` links eight `common/settings.md` anchors. Renaming any of those headings breaks a (?) button silently.

---

## 2. Class A — live and ungated

### A1 · ClowdBI: connection management
`cbed99d`, `329457a` · **Pages:** `bi-agent/connections/README.md`, `tableau.md`, `looker.md`, `power-bi.md`

The **Connected sources** card is new; ClowdBI previously had no way to repair a connection at all.

- Each connection lists provider glyph, label, and where it points — Tableau shows server **and site**, Looker its base URL, Power BI the account.
- **Edit** re-opens the Looker/Tableau connect form pre-filled — the repair path for a wrong Site or a rotated PAT. Power BI has **Reconnect** (OAuth re-authorisation) instead; there is no edit form.
- **Remove**, with confirmation: *"Datasets from X will stop being queryable. This can't be undone; you can reconnect later."*
- Every connection carries a **Personal / Shared** badge.
- The Tableau Site gotcha is now stated in the UI — *"the Site is the segment after `/#/site/` in your URL — not the PAT name"*. `tableau.md`'s troubleshooting table should be reconciled with that wording.

### A2 · ClowdBI: publish / revoke a shared connection (BI-RLS-01)
`7e3eaf9` · **Pages:** `bi-agent/connections/README.md` (new section), `data-projects.md#who-can-query`, `dashboards.md#who-can-see-a-dashboard`, `data-privacy.md`

**This makes existing guide text wrong.** `data-projects.md:68` says a shared service account means *"everyone in the project queries through this one connection"*. That is no longer true on its own — a shared connection is **credless until published**.

- A shared connection shows **Published / Not published / Revoked**, plus its **"Runs as"** label.
- **Publish** requires two fields, both mandatory: a **data classification** (e.g. *internal*, *confidential*) and a **"Runs as" label** (e.g. *Sales shared account*), shown to every viewer of a dashboard the connection backs. The dialog states the reason: *every viewer* of a bound dashboard queries with the shared connection's own access, not just project members who happen to open the board.
- **Revoke** takes an optional reason and is immediate — the connection goes credless and no viewer can query until it is published again.
- A **personal** connection never gets these controls; it is viewer-scoped by construction.

New concept for the guide's vocabulary: *viewer-scoped* vs *shared runs-as*, and the fact that publishing is an explicit owner/admin sign-off rather than a side effect of connecting.

### A3 · ClowdBI: the data project is now a tabbed shell
`f589b7e` · **Pages:** `bi-agent/data-projects.md`, `catalog.md`, `common/README.md`

Tabs: **Catalog** (default, doubles as the project home) · **Connections** · **Members** · **AI model** · **Usage**. The old `/settings` path redirects to Connections.

- **Members is new for ClowdBI** — project-level membership was previously ClowdInfra-only.
- **Usage is new for ClowdBI** as a tab — per-data-project spend and the budget editor. `data-projects.md:107` already promises this; it is now actually there.
- **AI model** replaces *"Project settings (the gear icon on the catalog page)"* — `data-projects.md:81` describes navigation that no longer exists.
- Every tab carries a (?) linking into this guide — see the standing constraint in §1.

### A4 · Unified sign-in across products
`c288e2c` · **Pages:** `common/settings.md#security`, both `getting-started.md`

Authentication is owned by the ClowdInfra origin (`platform.clowdops.ai`) — it hosts the login form and its origin is the one registered with Google/Microsoft. Signing out of ClowdBI hands you to the platform login. The session cookie is shared across the console domain, so **signing out anywhere ends the session everywhere**. Login screens now carry a link back to `clowdops.ai`.

### A5 · ClowdInfra: project shell shared with ClowdBI
`f589b7e` · **Pages:** `cloud-agent/your-workspace.md` (screenshots only)

No behavioural change, but the project nav, inline rename and budget pill are now the shared component. Existing screenshots will drift.

### A6 · ClowdBI dashboards: rendering fixes
`e3b5c33`, `550000a` · **Pages:** `bi-agent/dashboards.md`

Panel overlap on the canvas is fixed (auto-layout no longer collides), and date-grain compilation is fixed — *"by month"* now produces the right axis and series. Worth a short **time grain** subsection with a screenshot: `asking-good-questions.md` tells readers to *"name the grain"* but the guide never shows what a by-month panel looks like.

### A7 · Product hub fails closed
`6e9fb44` · **Pages:** `common/settings.md#product-entitlement`

While entitlements are still loading — or if the call fails — the hub now shows **only the product you are already in**, instead of advertising both. One sentence: what you can enter is proven by the server, never assumed.

---

## 3. Class B — the eight common-infrastructure components

### Shared framing (write once, link from each page)

- A component needs **both** a deployment that has it **and** a grant to your organisation. Either missing ⇒ nothing appears.
- Absent means *absent*: no sidebar entry, and typing the URL returns you to Settings. It is not greyed out and it does not explain itself.
- Platform admins see the full picture at **Settings → Platform admin → (org) → Component grants**: stored grant beside effective state, labelled *Not deployed here* / *Deployed, not granted* / *Granted and usable*, with an explicit warning that a grant for a component the deployment lacks is stored but inert. Grants are re-read every 60 seconds, and switching or impersonating an organisation never reuses another org's answer.

### B1 · Approvals — `action_policy`
**Settings → Approvals** · member-level · **New page:** `cloud-agent/approvals.md`, linked from `guardrails.md` and `schedules.md`

The unattended counterpart to today's in-chat confirmation. A scheduled run that reaches a gated action class **does not fail** — it queues the action and carries on; a person decides later.

- Stat strip: Waiting / Expiring in 24h / Executed (7d) / Failed (7d). Tabs: Waiting · Executed · Failed · Rejected · Expired · All.
- Each row: action class, a preview of the exact payload, who proposed it (*A person* / *Scheduled task*), expiry as a distance (*"expires in 3h"*), high-priority flag, and the policy **frozen at proposal** rendered in the past tense — *"was gate (org)"*. That is what the platform was allowed to do when it asked, not what it is allowed to do today.
- Four promises the guide must state, because each one otherwise generates a support ticket:
  1. Approving runs **exactly the payload shown** — nothing is re-planned or re-generated at execution time.
  2. *Approved but not yet executed* is normal — the sweeper picks it up.
  3. *"executed, delivery unconfirmed"* means the transport accepted the call but never confirmed delivery. It is not a success.
  4. A conflict on resolve means somebody else decided first; refresh rather than retry.

`guardrails.md` needs a paragraph tying the two confirmation paths together.

### B2 · Connections — `connection_inventory`
**Settings → Connections** · project-scoped · **Pages:** new section in `cloud-agent/your-workspace.md`, pointer from `credentials/README.md`

The external systems a project reaches — a Power BI tenant, a Slack workspace, an SMTP host — and what the platform has *observed* about each.

- Health: **healthy / expiring / degraded / broken / unknown / disabled**, with a reason line and the number of credentials behind the connection.
- Key promise: health comes from **real deliveries and real token refreshes**, never a reachability poll. **`unknown` is not `healthy`** — the badge deliberately looks different.
- *"identity not shared"* explains why two credentials did not fold into one connection: the provider exposes no non-secret identity key.
- Project-scoped rather than org-scoped, because an org-wide list would leak the existence of another project's integrations.

### B3 · Contacts — `contact_registry`
**Settings → Contacts / Contact lists / Contact settings** · **New page:** `common/contacts.md`, cross-ref from `bi-agent/data-privacy.md`

**Highest priority in Class B** — this is DPO-facing content.

**Contacts** (all members). The people the organisation knows: *Member / Guest / External / Unresolved*, with handles (verified flag), company, and list membership. *"A directory, not a login system — nothing here grants anyone access to anything."* Populated by hand or by the agent recording a person during a conversation.

**Coverage is stated, not implied.** When the org is walled, the page says how many contacts you can see and that colleagues may see a different set — so two people comparing lists do not conclude the directory is broken.

**Possible duplicates** (admins) → **Merge**. The duplicate is kept as a pointer, so anything already referring to it still resolves.

**Contact lists.** A list holds people and nothing else — no consent, no subscriptions, no meeting history; those live with the product that owns them. Product-maintained lists and lists whose owner left the organisation are labelled.

**Contact settings** (admins only):
- **Who can see contacts** — *Everyone* vs *Only what is shared* (members see what they added plus anything on a list shared with them; administrators always see everything). Changing it alters no contact, only who sees what.
- **Re-add someone who was erased** — lift the erasure block, recorded against the administrator's name. It re-creates nothing; it only allows the person to be added again.
- **Recent changes** — merges, erasures, links and sharing changes across the directory.

**Erasure** deserves its own subsection, verbatim-faithful to the dialog:
- It is the data-subject erasure, it cannot be undone, and it requires a typed acknowledgement.
- Name, company and every handle are deleted; the person is removed from every list.
- Products holding data about them are asked to delete it; anything kept for a legal reason is **recorded as an exception rather than silently kept**.
- A one-way marker stops a future import or sync quietly bringing them back. An administrator can lift it deliberately, and that is recorded.
- An anonymised placeholder row remains so existing references do not break.
- **What it does not reach** — details typed into past conversations or written into generated documents live outside the registry and are not removed.
- Afterwards the dialog shows the **per-store disposition record**: what was deleted, suppressed, deliberately retained and on what basis, and what was not reached. That record exists only at that moment, so the guide should tell people to capture it if they may have to describe the erasure to the person it was performed for.

### B4 · Packs — `pack_registry`
**Settings → Packs**, plus chips on the ClowdInfra chat header · **New page:** `cloud-agent/packs.md`, paragraph in `chat.md`

Reusable guidance and files an organisation publishes into its agent sessions.

- Author on the page, or ask the agent in chat to *"remember this for future sessions"* (the `draft_pack` tool). **A draft changes nothing until an admin publishes it.**
- List: name, source (**org** / **default**), product scope, status (**active / deprecated / disabled**), current version, binding count.
- Detail dialog: **Versions · Draft · Bindings**. A draft holds prompt fragments (title + guidance text), assets, and applicability by credential provider — *empty means always eligible; otherwise delivered only when a matching credential is present*.
- Admin-only lifecycle, with the consequences the dialogs already state precisely:
  - **Deprecate** — leaves the on-demand catalog and attracts no new bindings, but keeps delivering through existing ones.
  - **Disable** — new sessions stop receiving it entirely; running sessions keep it; stamped history stays readable.
  - **Platform default packs** can be disabled for the org and re-enabled — *"new sessions will receive it again."*
  - **Make a version current** — the rollback path.
- **Chat header chips**: `name vN`, tinted by source, tooltip distinguishing *bound by your org* from *activated on demand*. A session with no org packs renders nothing.

### B5 · Artifacts — `artifact_substrate`
**Project → Artifacts** (ClowdInfra) · **New page:** `cloud-agent/artifacts.md`, pointers from `your-workspace.md` and `chat.md`

Documents, briefs and digests kept in a project — drafted in chat (*"draft a weekly digest of this week's findings"*), revised over time, approved when right.

- **Version strip**: click to view, **double-click to compare** (line-level diff); ✓ marks the approved version.
- **Approve records that the version's CONTENT is agreed. Sending or publishing it is always a separate action.** Approval names an exact version — an edit must be saved first, and a version that changed underneath is refused rather than approved in its new form.
- **Save as new version** is compare-and-set: if somebody else edited first you are told to reopen, not to retry.
- **Binary artifacts** are stored and versioned but cannot be edited or sent over a notification.
- Content removed by retention renders as its own state, not as an empty document.
- **Archive** is admin-only.
- Project scope *is* the confidentiality boundary: an artifact minted in another project is not listed here and cannot be opened from here even by id.

### B6 · Evidence & citations — `evidence_citation`
**ClowdBI answers** · **Pages:** `bi-agent/chat.md` (rewrite, not append), `asking-good-questions.md`, `data-privacy.md`, `README.md`

- Inline superscript **`[1]`** markers on fact sentences; **⚠** on an uncited fact. Interpretation and recommendation sentences are **not** marked by default.
- **Coverage line** under every annotated answer: *"all N facts cited"*, or *"N facts · M cited · K uncited ⚠"*, plus *"K unplaced"* when the model annotated claims whose wording did not match its own answer. A **show sentence types** toggle reveals interpretation/recommendation counts.
- Answers produced before citations show *"produced before citations — not annotated"* — deliberately distinct from *"0 of N cited"*.
- **Evidence panel** per claim: the recorded query and result, the pins rendered as words (*"model X · dataset A + B · recorded …"*), the grade (verbatim quotes render as quotes; derived and paraphrase never do), and an optional link out to the source.
- **This absorbs today's "Show query" disclosure.** `chat.md`'s "showing the query" section needs rewriting rather than extending — there is now one renderer of a recorded query, reached two ways.
- Terminal states are rendered honestly, never as nothing: *"Evidence you don't have access to"*, *"Evidence no longer available"*, *"Evidence superseded (pin no longer latest)"*.
- The **"checked"** affordance carries frozen wording that the guide should quote verbatim, because changing it is an owner decision:
  > Result checked against its query at answer time — not a check of the sentence above.
- A reference cannot reach outside its own turn; one naming a different turn is refused and says so.

### B7 · Knowledge review — `fact_governance`
**Settings → Knowledge review** · admin-only, hidden until a proposal exists · **Fold into `common/contacts.md`**

Suggested contact merges — the MVP's only category.

- Row: a **Knowledge** chip, the survivor · merged-away pair, a *consequential* flag, and a confidence percentage.
- Dialog: survivor/loser preview, handle union, list transfer, the user-link outcome, why it was proposed (*"Resolved together before"*, *"Same name and email domain"*), the option to **flip** the direction, and rejection with an optional *"why are these different people?"* note.
- **Reversible** — an admin can unmerge while handles stay unclaimed.
- Deliberately a **second, separate confirmation species** from Approvals: its own chip, its own surface, no cross-fire. The guide should say so, or the two queues read as duplicates.

### B8 · Signals — `signal_store`
**Settings → Signals** · reads member-level, dismiss admin-only · **New page:** `common/signals.md`, cross-ref from `settings.md#activity` and `#system-notifications`

One row per **condition**, not per event — a budget cap, a run of guardrail denials, a failing schedule, an unstable connection. Repeat observations fold in as *sightings*.

- **Answer "why is this here twice?" up front.** Activity is *history*: every occurrence, per-user read state. Signals is *attention*: one record per condition, org-shared status, a lifecycle, and a dismissal somebody has to sign. Signal-producing events keep appearing in both.
- Tabs: **Live · New · Picked up · Dismissed · History**, a priority filter, and an *"N new"* badge.
- Detail: sighting count with first/last seen and expiry; *"Below its alert threshold: recorded and visible here, but not yet notified"*; score provenance (relevance / freshness / urgency, the scoring method, and the producer); evidence; **what was done**; and a link to the predecessor record of the same condition.
- **Dismissal requires a rationale**, shown to whoever sees the signal next. Dismissing suppresses alerts *at or below* the current level but keeps recording — if the condition worsens it **reopens with your reason attached**. The dismissal note travels on the list row too, so a dismissed-but-climbing condition never looks like a quiet one.
- A coverage note appears when some signals fall outside your scope.
- **New notification subscription row — "Signals"**: a daily digest of what is worth acting on. Immediate alerts still ride the existing event types; this is the summary, and the Signals page is there whether or not you subscribe. `settings.md#system-notifications` needs the row.

---

## 4. Cross-cutting edits

| File | Edit |
| --- | --- |
| `common/settings.md` | "On this page" nav + new sections for Approvals, Connections, Contacts, Contact lists, Contact settings, Packs, Knowledge review, Signals. Add the **Signals** digest row to System notifications. Note that these appear only when granted. |
| `common/README.md` | Extend "where product-specific settings live"; repoint the ClowdBI AI-model row to the **AI model tab**. |
| `cloud-agent/README.md` | Nav strip + guides table + **Key concepts**: Pack, Artifact, Connection, Pending action, Signal, Contact. |
| `bi-agent/README.md` | Nav strip + guides table + **Key concepts**: published connection / runs-as, citation & evidence. Reconcile the "what reaches the AI model" section with the citation sidecar. |
| `bi-agent/data-projects.md` | §"Who can query" is now incomplete (publish gate); §"Choosing the AI model" navigation is wrong. |
| `bi-agent/dashboards.md` | Runs-as label on a bound board; new time-grain note. |
| `cloud-agent/guardrails.md` | In-chat confirmation vs the queued-approval path. |
| `cloud-agent/schedules.md` | An unattended run now defers rather than fails. |

## 5. Screenshots to capture

Class A: BI Connected sources card · publish dialog · revoke dialog · data-project tab bar · a by-month dashboard panel. *(5)*

Class B: Approvals queue · Connections list · Contacts directory · Contact settings · Erase dialog with the disposition record · Contact lists · Packs list · Pack detail (Draft tab) · Pack chips on the chat header · Artifacts library · Artifact panel with the version strip and diff · a ClowdBI answer with markers and coverage line · Evidence panel · Knowledge review dialog · Signals queue · Signal detail with a dismissal disclosure · Component grants (platform admin). *(17)*

`bi-agent/images/PLACEHOLDERS.md` and `cloud-agent/private-deployment/images/PLACEHOLDERS.md` already track the existing debt; extend rather than duplicate.
