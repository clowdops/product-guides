# Configuration

**Audience: sysadmin.** Where settings live on the box, and the optional values you can turn on. The connected installer writes a working `.env` for you — most installs never edit anything here. Reach for this page to add email, backups, or custom sign-in.

## Where configuration lives

Everything is under the appliance directory (`/opt/clowd/deploy/topologies/appliance` on a standard install) and the secrets directory (`/etc/clowd/secrets`):

| File | Holds | Edit by hand? |
| --- | --- | --- |
| `.env` | Static, non-secret choices: hostname, TLS, image tags, database names. | Rarely — the installer writes it. |
| `/etc/clowd/secrets/env/auto.env` | Auto-generated secrets (DB passwords, encryption keys). | **Never.** Generated once; back it up, don't touch. |
| `/etc/clowd/secrets/env/operator.env` | **Optional operator values** — SMTP, SSO, S3 backups. | **Yes — this is the file you add to.** |

After editing `operator.env` or `.env`, apply changes with:

```bash
cd /opt/clowd/deploy/topologies/appliance
docker compose up -d
```

## The essentials (`.env`)

Two values define the edge. The installer sets them from your registration; you'd only change them for a manual install:

```bash
# A real domain → automatic HTTPS via Let's Encrypt
CLOWD_SITE_ADDRESS=clowd.acme.example
CLOWD_PUBLIC_URL=https://clowd.acme.example
```

To pin a stable version instead of tracking the latest, set the image tags (`TAG_BACKEND`, `TAG_FRONTEND`, `TAG_FOA`, `TAG_CAE`) to a release tag rather than `main`.

## Optional operator values (`operator.env`)

Everything below is **optional**. Leave a section blank and that feature is simply off — nothing breaks. Add the lines to `/etc/clowd/secrets/env/operator.env`, then `docker compose up -d`.

### Email (SMTP)

Without SMTP, the box can't send invitations or password-reset emails — you provision users by other means. To enable it:

```bash
SMTP_HOST=smtp.acme.example
SMTP_PORT=587
SMTP_USER=clowd@acme.example
SMTP_PASSWORD=...
SMTP_SECURE=true
SMTP_FROM=clowd@acme.example
```

### Off-box backups (S3)

Point the nightly database backup at any S3-compatible bucket:

```bash
BACKUP_S3_ACCESS_KEY=...
BACKUP_S3_SECRET_KEY=...
BACKUP_S3_BUCKET=clowd-backups
BACKUP_S3_REGION=eu-west-1
```

Without these, there are no automatic off-box backups — you're responsible for snapshotting the host. See [Operations → Backup & recovery](operations.md#backup--recovery).

### Single sign-on (SSO)

The sign-in buttons (Google / Microsoft / GitHub, or any **generic OIDC** provider) appear only when you configure a provider. Because a private deployment runs on its own domain, **you supply your own OAuth client** — the shared ClowdOps client won't accept your box's address.

This is covered in its own page: **[Authentication & SSO](authentication-and-sso.md)** — client IDs and secrets, the redirect URL to register, generic OIDC, and forcing SSO-only sign-in. Until you configure it, sign-in is **email + password**, which works out of the box.

## What is *not* configured here

- **AI provider keys** (OpenAI, Anthropic, …) and **cloud credentials** (AWS, GCP, Azure, SSH) are entered **in the app UI**, per organisation, and encrypted at rest. They are never environment variables and never leave the box. This is the same "bring your own keys" model as SaaS — see the main [Workspace & credentials](../your-workspace.md) guide.
- **Billing / Stripe** is disabled on a private deployment. Your usage is covered by the licence; there is no subscription or credit-card surface. Related billing-only admin screens are hidden.

## Federation values (advanced / manual installs)

The connected installer sets these automatically — you only touch them for a **manual** or **air-gapped** install. In `.env`:

```bash
DEPLOYMENT_MODE=private
DEPLOYMENT_ROLE=child                 # child | master
AUTHORITY_URL=https://platform.clowdops.ai
ENROLLMENT_VOUCHER=fbd_...            # one-time, from the Deployments page
CENTRAL_LICENSE_PUBKEY=...            # base64, from <authority>/federation/pubkey?format=base64
```

Leaving `DEPLOYMENT_MODE` unset produces a plain, unlicensed standalone box. For the full manual/air-gapped path, see [Master & children](federation-master-and-children.md).
