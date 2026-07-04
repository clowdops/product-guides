# Operations

**Audience: org admin + sysadmin.** Day-2: understanding status, updating, backing up, decommissioning, and fixing the common snags.

## Status lifecycle

Every deployment moves through these states, visible on the Deployments page:

| Status | Meaning |
| --- | --- |
| `registered` | Slot reserved, voucher minted — no box has enrolled yet. |
| `enrolled` | The box enrolled and got its licence, but hasn't reported healthy heartbeats yet. |
| `active` | Healthy and heartbeating. The normal steady state. |
| `dormant` | The box went silent (no heartbeats for a while). It may still be running in grace; investigate. |
| `decommissioned` | Retired on purpose. Its quota slot is freed. |

A healthy install progresses `registered → enrolled → active` within a few minutes.

## Quota

Your organisation has a **deployment quota** (default **3**), shown as a pill on the Deployments page (e.g. `2 / 3`). Registering counts against it; **decommissioning** frees a slot. To raise the cap, contact your ClowdOps representative.

## Licences, grace, and degraded operation

A private deployment runs on a **signed, offline-verifiable licence** — valid **365 days**, renewed automatically while the box can reach its authority. There's no Stripe, no card, nothing to click monthly.

If the licence lapses, or the box can't reach its authority, it does **not** shut off. It degrades gracefully, in this order:

1. **A warning banner** appears in the app.
2. After the **grace period (21 days)**, the box **blocks new sessions** — no new agent chats or sandbox launches.
3. It **never fails closed**: login and reads keep working, and **running chats are never killed**.

"Lapsed" and "authority unreachable" are treated the same way, so a temporary network cut is harmless well within the grace window.

## Updating

When a newer appliance version is published, the deployment row shows an **update available** badge. To update, on the box:

```bash
cd /opt/clowd/deploy/topologies/appliance
sudo ./install.sh          # idempotent — pulls new images and restarts
```

The installer is safe to re-run: it pulls the newer images, applies any database migrations, and restarts the stack. Pin `TAG_*` in `.env` to a specific release if you want to control exactly when versions change ([Configuration](configuration.md)).

## Backup & recovery

Back these up **off-box**. If the host dies, this is what lets you rebuild it:

| What | Path / volume | If you lose it |
| --- | --- | --- |
| **Master encryption key** | `/etc/clowd/secrets/keys` | All encrypted data (credentials, secrets) is unrecoverable. |
| **Federation identity + licence** | `/etc/clowd/secrets/federation` | The box must re-enrol, consuming a fresh quota slot. On a master, you also lose child-signing — every child must re-enrol. |
| **TLS certificates** | the `caddy-data` Docker volume | Re-issued automatically, but you'll briefly hit Let's Encrypt rate limits on a busy rebuild. |
| **Database** | via the S3 backup ([Configuration](configuration.md#off-box-backups-s3)) or your own host snapshots | All application data. |

The auto-generated secrets in `/etc/clowd/secrets/env/auto.env` are also worth backing up so a rebuild reuses the same database passwords.

## Decommissioning

To retire a deployment cleanly:

1. **In the portal** — on the Deployments page, **Decommission** the row. This frees the quota slot and cannot be undone.
2. **On the box** — tear the stack down:
   ```bash
   cd /opt/clowd/deploy/topologies/appliance
   docker compose down -v
   ```
3. **Destroy the VPS.** If you used an auto (`clowdops.ai`) hostname, its DNS record is harmless but not auto-removed — ask your ClowdOps contact to clean it up if you care.

A decommissioned row stays in the list (greyed out) until you **Delete** it, which removes it and its licences for good.

## Troubleshooting

| Symptom | Cause & fix |
| --- | --- |
| **Voucher rejected** | Expired (72 h lifetime) or already used. Re-register in the portal for a fresh command. |
| **Status stuck at `enrolled`, never `active`** | Heartbeats aren't reaching the authority. Check the box can egress to `platform.clowdops.ai` (or its master), then read `docker logs clowd-backend-server 2>&1 \| grep -i federation`. |
| **No HTTPS yet** | DNS still propagating, or port 80 blocked so Let's Encrypt can't validate. The box runs on plain HTTP until the certificate lands; enrolment/heartbeats work regardless. Confirm the A record and that port 80 is open. |
| **Out-of-memory / containers restarting on boot** | Host too small. 8 GB boots but the agent needs 16 GB+. Resize, or install with `--sandbox-images=none` and avoid running the agent. |
| **Row never appears after install** | The install ran against the wrong authority (a voucher from preview points at preview, not prod). Register on the same portal you expect the box to show up in. |
| **SSO buttons missing** | No provider configured. Sign in with email + password, then set up SSO — see [Authentication & SSO](authentication-and-sso.md). |

Still stuck? Gather `docker logs clowd-backend-server` and the deployment's label/status, and contact your ClowdOps representative.
