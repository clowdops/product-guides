# Install the Appliance

**Audience: sysadmin.** You have a fresh Linux/amd64 VPS ([Prerequisites](prerequisites.md)) and the install command an org admin generated in [Register a deployment](register-a-deployment.md). This page runs it and brings the box up.

## Run the installer

SSH to the box and paste the command from the portal, as root:

```bash
curl -fsSL https://platform.clowdops.ai/install.sh | sudo bash -s -- --token=<voucher>
```

That's it — the installer is unattended and idempotent (safe to re-run). It:

1. **Preflights** the host (specs, architecture).
2. **Installs Docker** if it's missing.
3. **Decodes the voucher** — it carries the authority URL, the licence-verify public key, your allocated hostname, and the role.
4. **Downloads the appliance bundle** (Docker Compose stack + Caddy edge config) from the authority.
5. **Writes `.env`**, generates the box's secrets and cryptographic keypair.
6. **Starts the stack** (`docker compose up`), applies database migrations, and seeds.
7. **Self-enrols** with the authority, receives the signed licence, and starts heartbeating.
8. **Caddy obtains a TLS certificate** (Let's Encrypt, HTTP-01) for your hostname.

The first run pulls several GB of images, so give it a few minutes.

### Pulling fewer sandbox images

By default the installer pre-warms the full set of sandbox runtimes so every agent type works instantly. To save disk/bandwidth, append `--sandbox-images` with just the runtimes you need:

```bash
# Just the chat runtime (smallest footprint)
curl -fsSL https://platform.clowdops.ai/install.sh | sudo bash -s -- --token=<voucher> --sandbox-images=chat

# None at install time (pulled on first use instead)
... --sandbox-images=none
```

Available runtimes: `chat`, `document`, `general`, `aws`, `gcp`, `azure`, `ssh`.

## Verify enrolment

**In the portal**, the deployment row flips `registered → enrolled → active`, `last seen` starts ticking, and the licence expiry appears.

**On the box**, confirm the same:

```bash
# Enrolment + heartbeat in the backend logs
docker logs clowd-backend-server 2>&1 | grep -i federation
#   → "federation: enrolled ..." then "federation: heartbeat loop started"

# The signed licence is on disk
sudo cat /etc/clowd/secrets/federation/license.json
```

If it doesn't reach `active`, see [Operations → Troubleshooting](operations.md#troubleshooting).

## TLS and the hostname

- **Auto hostname** — Central created the DNS record at enrolment; Caddy issues the certificate within a few minutes of DNS propagating. Until then the box serves plain HTTP (enrolment and heartbeats work regardless).
- **Bring-your-own hostname** — make sure your A record already points at the box (you did this in [Prerequisites](prerequisites.md#dns)); Caddy issues the certificate on first boot.

Then browse to your hostname (e.g. `https://paris-dc1.dply.clowdops.ai`).

## Claim the founding admin

The **founding admin email** from the register dialog becomes the box's first platform admin. Once the deployment reports healthy, the ClowdOps portal surfaces a one-time **set-password link** for that email on the Deployments page — open it, set a password, and log in.

If you ran a **manual install**, or no link is shown, create the admin directly on the box instead. The installer prints this command when it finishes:

```bash
cd /opt/clowd/deploy/topologies/appliance
docker compose --profile bootstrap run --rm admin-init \
    --email you@acme.example --first-name You --last-name Admin
```

This flags the account's organisation as platform admin (no env var or restart needed — the backend recognises it within ~60 seconds) and prints a temporary password. **Log in and rotate it immediately.**

## Back up now, before anything else

Two things on the box are irreplaceable. Back them up off-box the moment the install succeeds:

- **`/etc/clowd/secrets/keys`** — the master encryption key. Lose it and all encrypted data (credentials, secrets) is unrecoverable.
- **`/etc/clowd/secrets/federation`** — the deployment keypair and signed licence. Lose it and the box must re-enrol, consuming a fresh quota slot.

Also back up the `caddy-data` Docker volume (TLS certificates/account). See [Operations → Backup & recovery](operations.md#backup--recovery).

## What's next

- Set optional values — SMTP for email, S3 for backups, SSO — in [Configuration](configuration.md).
- Add AI provider and cloud credentials **in the app UI**, per organisation (they're encrypted at rest; nothing routes through ClowdOps infrastructure).
- Running a federated estate? See [Master & children](federation-master-and-children.md).
