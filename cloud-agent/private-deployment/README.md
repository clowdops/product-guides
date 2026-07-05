# Private Deployment

**[Prerequisites](prerequisites.md)** · **[Register a deployment](register-a-deployment.md)** · **[Install the appliance](install-the-appliance.md)** · **[Configuration](configuration.md)** · **[Master & children](federation-master-and-children.md)** · **[Operations](operations.md)** · **[Authentication & SSO](authentication-and-sso.md)**

A **private deployment** runs the entire ClowdOps stack on hardware you control — your own VPS, your own domain, your own data. The agent, its sandboxes, the database, and every credential stay inside your perimeter. Nothing routes through ClowdOps' shared infrastructure.

You still get the full product: chat, sandboxes, schedules, guardrails, notifications. What changes is *where it runs* and *how it's licensed* — a signed, offline-verifiable licence instead of a monthly Stripe subscription.

> [!NOTE]
> This guide has two audiences. **Org admins** register the deployment and manage it from the ClowdOps portal — start at [Register a deployment](register-a-deployment.md). **Sysadmins** provision the Linux host and run the installer — start at [Prerequisites](prerequisites.md) then [Install the appliance](install-the-appliance.md).

## Who it's for

- Organisations with **data-residency or sovereignty** requirements (the box never phones customer data home).
- **Air-gapped** or network-restricted environments (a private deployment runs fully offline on a signed licence).
- Teams that want a **dedicated, isolated** instance rather than shared multi-tenant SaaS.

## The shape of it

A private deployment enrols with **Central** — the ClowdOps platform at `platform.clowdops.ai` — which acts as the licensing authority. Central mints the licence and tracks how many deployments your organisation runs. It receives only what it needs to license and account for the deployment — licence status and **aggregate usage totals** — and **never** your chats, credentials, prompts, or data. See [Operations → What leaves the box](operations.md#what-leaves-the-box) for the exact list.

There are two roles a box can take:

| Role | What it is | Its authority | Hostname |
| --- | --- | --- | --- |
| **Connected deployment** | A box that enrols directly with Central. The usual choice. Can later act as a **master** for its own children. | Central (`platform.clowdops.ai`) | Auto `<label>.dply.clowdops.ai`, or bring your own |
| **Child** | A box that enrols with one of *your* connected deployments acting as a master — for internal-network or air-gapped estates. | Your master box | Bring your own (internal DNS) |

So there are three words but only two things to install: a **connected** box (which simply *becomes* a **master** the moment it has children of its own) and a **child**. Most customers only ever run connected deployments; masters and children exist for larger, segmented, or air-gapped estates — see [Master & children](federation-master-and-children.md).

## The journey at a glance

1. **Register** in the portal → **Settings → Deployments → Register deployment**. Central mints a one-time voucher and shows you an install command. *(Org admin — [details](register-a-deployment.md).)*
2. **Provision** a fresh Linux/amd64 VPS with ports 80 and 443 open. *(Sysadmin — [details](prerequisites.md).)*
3. **Run the install command** on the box as root. It installs Docker, pulls the stack, enrols, and starts. Or run the **[guided setup script](install-the-appliance.md#guided-setup-recommended)**, which walks you through role, hostname, and sign-in (SSO) in one pass. *(Sysadmin — [details](install-the-appliance.md).)*
4. **Verify** in the portal — the deployment's status flips `registered → enrolled → active`. Claim the founding-admin account and log in.

That's the whole thing. The rest of this guide covers the details of each step, plus [configuration](configuration.md), [day-2 operations](operations.md), and [authentication](authentication-and-sso.md).

## Defaults worth knowing

| Setting | Default | Meaning |
| --- | --- | --- |
| Deployment quota | 3 per organisation | How many live deployments you can run. Ask your ClowdOps contact to raise it. |
| Voucher lifetime | 72 hours | A registration voucher expires if unused. Re-register to get a fresh one. |
| Licence validity | 365 days | Renewed automatically while the box can reach its authority. |
| Grace period | 21 days | How long a box keeps working after its licence lapses or its authority goes silent. |
| Heartbeat | every 5 minutes | How often the box reports status to its authority. |

## Guides

| Guide | Audience | What it covers |
| --- | --- | --- |
| [Prerequisites](prerequisites.md) | Sysadmin | Host sizing, OS, ports, DNS, outbound connectivity |
| [Register a deployment](register-a-deployment.md) | Org admin | The portal flow, the register dialog, getting your install command |
| [Install the appliance](install-the-appliance.md) | Sysadmin | Running the installer, verifying enrolment, claiming the founding admin |
| [Configuration](configuration.md) | Sysadmin | `.env` and operator values — TLS, SMTP, backups, AI keys |
| [Master & children](federation-master-and-children.md) | Both | Federated estates, internal networks, air-gapped installs |
| [Operations](operations.md) | Both | Status lifecycle, updates, backups, decommissioning, what leaves the box, troubleshooting |
| [Authentication & SSO](authentication-and-sso.md) | Org admin | Sign-in options (custom SSO details coming soon) |
