# Screenshot placeholders

Screenshots to capture for the ClowdBI guide. Drop PNGs in this folder using the
exact filenames below so the existing `<!-- Screenshot: ... -->` references
resolve when uncommented.

Capture at a standard desktop width, light theme, against a **demo organisation**
— no real customer data, no real names, no secrets. Where a screenshot would
show a dataset name, use the demo project.

## Priority — the guide leans on these

| Filename | Page | What to capture |
| --- | --- | --- |
| `chat-main-ui.png` | [chat.md](../chat.md) | A full chat turn: question, prose answer, chart or table result, sidebar visible |
| `chat-show-query.png` | [chat.md](../chat.md) | The **Show query** disclosure expanded, revealing DAX. The habit this guide pushes hardest |
| `catalog-overview.png` | [catalog.md](../catalog.md) | Catalog page with Entities / Measures / Relationships sections visible |
| `catalog-entity-columns.png` | [catalog.md](../catalog.md) | An entity expanded, showing type / summable / cardinality badges — **include at least one red personal-data badge** |
| `dashboard-detail.png` | [dashboards.md](../dashboards.md) | A saved board: KPI row, a chart or two, parameter bar, "As of" timestamp |
| `chat-pii-notice-banner.png` | [data-privacy.md](../data-privacy.md) | The amber privacy notice banner in a turn. Use a fake address (`someone@example.com`) |

## Onboarding & connections

| Filename | Page | What to capture |
| --- | --- | --- |
| `onboarding-organisation.png` | [getting-started.md](../getting-started.md) | Onboarding step 1 — organisation name and website |
| `onboarding-data-project.png` | [getting-started.md](../getting-started.md) | Onboarding — naming the first data project |
| `connect-choose-provider.png` | [getting-started.md](../getting-started.md), [connections/README.md](../connections/README.md) | **Connect your BI source** with the three provider cards |
| `connect-dataset-picker.png` | [getting-started.md](../getting-started.md), [connections/README.md](../connections/README.md) | Dataset picker, a workspace expanded with two or three datasets ticked |
| `chat-first-answer.png` | [getting-started.md](../getting-started.md) | A first answer with its result table and the Show query disclosure collapsed |
| `connect-powerbi-card.png` | [connections/power-bi.md](../connections/power-bi.md) | The Power BI connect card with its Build-permission help text |
| `connect-looker-form.png` | [connections/looker.md](../connections/looker.md) | Connect Looker dialog — base URL, client ID, secret, and the access-mode choice |
| `connect-tableau-form.png` | [connections/tableau.md](../connections/tableau.md) | Connect Tableau dialog — server, site, PAT name and secret |

## Third-party UIs (captured on the vendor's side)

These are on the BI platform, not in ClowdBI. Redact tenant names.

| Filename | Page | What to capture |
| --- | --- | --- |
| `powerbi-build-permission.png` | [connections/power-bi.md](../connections/power-bi.md) | Power BI **Manage permissions** dialog with **Build** ticked |
| `looker-api3-keys.png` | [connections/looker.md](../connections/looker.md) | Looker Admin → Users → **API3 Keys** with **New API3 Key** |
| `tableau-pat-creation.png` | [connections/tableau.md](../connections/tableau.md) | Tableau **My Account Settings → Personal Access Tokens** |

## Feature detail

| Filename | Page | What to capture |
| --- | --- | --- |
| `sidebar-overview.png` | [data-projects.md](../data-projects.md) | Sidebar — project selector, New chat, Data projects, Dashboards, conversation list |
| `project-settings-ai.png` | [data-projects.md](../data-projects.md) | The data project's **AI model** tab — provider selection and the BYOK card |
| `chat-inline-dashboard.png` | [dashboards.md](../dashboards.md) | The inline dashboard card in a chat turn with **Save as dashboard** |
| `links-panel.png` | [cross-dataset-links.md](../cross-dataset-links.md) | Links panel with a proposed link showing overlap evidence, and a confirmed one |

## Citations, connections and grain

| Filename | Page | What to capture |
| --- | --- | --- |
| `chat-citations.png` | [chat.md](../chat.md#citations-and-coverage) | An answer with inline `[1]` markers **and at least one ⚠ uncited fact**, with the coverage line beneath. The ⚠ is the point — a fully-cited example does not show what the line is for |
| `evidence-panel.png` | [evidence.md](../evidence.md#the-evidence-panel) | The evidence panel open on a claim: the quoted claim, the recorded query, its result, and the pins line. Include the green **checked** marker if one is present |
| `connections-tab.png` | [connections/README.md](../connections/README.md#managing-an-existing-connection) | The data project's **Connections** tab with at least two connections — one **Personal**, one **Shared / Published** with its runs-as label visible |
| `connection-publish.png` | [connections/README.md](../connections/README.md#publishing-a-shared-connection) | The **Publish this connection** dialog, both fields filled with plausible demo values (*internal*, *Sales shared account*) |
| `dashboard-time-grain.png` | [dashboards.md](../dashboards.md#time-grain) | A by-month trend panel with a readable date axis — 12 months of data, not 3 points |

## Also referenced

`common/settings.md` references `images/settings-billing-page.png` (in
[`common/images/`](../../common/), not this folder) and reuses two existing
ClowdInfra screenshots for the usage dashboard and system notifications.

## Optional extras

| Filename | Suggested use |
| --- | --- |
| `dashboard-edit-mode.png` | Layout editing with a panel mid-drag — [dashboards.md](../dashboards.md#editing-the-layout) |
| `dashboard-share.png` | **Share this snapshot** with a public link created — [dashboards.md](../dashboards.md#sharing-a-snapshot) |
| `panel-needs-attention.png` | A degraded panel with **Ask the agent to fix it** — [dashboards.md](../dashboards.md#when-a-panel-breaks) |
| `hub-product-chooser.png` | The product hub showing ClowdInfra and ClowdBI cards — [common/settings.md](../../common/settings.md#product-entitlement) |
