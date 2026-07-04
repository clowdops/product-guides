# Prerequisites

**Audience: sysadmin.** What you need in place before running the installer. Read this alongside [Register a deployment](register-a-deployment.md) (done by an org admin in the portal) — you'll need the install command it produces.

## The host

A **fresh, dedicated Linux/amd64 VPS**. Don't co-locate it with other workloads — the agent spawns disposable sandbox containers and expects the box to itself.

| Resource | Minimum | Recommended | Notes |
| --- | --- | --- | --- |
| **Architecture** | linux/amd64 | linux/amd64 | ARM is not supported. |
| **vCPU** | 2 | 4+ | |
| **RAM** | 8 GB | 16 GB+ | 8 GB is enough to boot and enrol; 16 GB+ is needed once the agent runs sandboxes. |
| **Disk** | 25 GB | 40 GB+ | The constraint is container images. Each sandbox runtime is ~3.5 GB and core services add a few GB. |
| **OS** | Any modern Linux with Docker | Ubuntu 22.04 / Debian 12 | The installer installs Docker if it's absent. |

> [!NOTE]
> The installer pre-warms sandbox runtime images so the agent works instantly. The full set is large. If disk or bandwidth is tight, you can pull fewer — see the `--sandbox-images` flag in [Install the appliance](install-the-appliance.md).

## Docker

Docker Engine with the Compose plugin. **You don't have to install it yourself** — the install command does it if it's missing. If you prefer to pre-install, any recent Docker Engine works; verify with `docker info`.

## Network

### Inbound

Open these ports to the box:

| Port | Why |
| --- | --- |
| **80** | Let's Encrypt certificate validation (HTTP-01) and HTTP→HTTPS redirect. |
| **443** | The application (HTTPS). |

No other inbound ports are required. The database, message broker, and internal services are never exposed.

### Outbound

A **connected** deployment needs to reach:

- Its **authority** — `platform.clowdops.ai` (or your master box) — for enrolment and heartbeats.
- **Public container registries** (`ghcr.io`, `docker.io`) to pull images at install and update time.
- Whatever **AI providers and cloud APIs** your agents will actually call (you supply those keys per-org in the app).

An **air-gapped** deployment reaches none of the above at runtime — it runs on a signed licence and pulls images from a master's mirror. See [Master & children](federation-master-and-children.md).

## DNS

You have two hostname options, chosen in the register dialog:

- **Auto (`clowdops.ai`)** — Central creates the DNS record for you (`<label>.dply.clowdops.ai`) pointing at the box's public IP. **Nothing to do here** except make sure the box has a public IP and port 80 is reachable, so the certificate can be issued.
- **Bring your own** — you own the hostname. **Create a DNS A record** for it pointing at the box's public IP *before* you run the installer, so the certificate is issued on first boot. Example:

  ```
  clowd.acme.example.  A  203.0.113.7
  ```

Children on an internal network always bring their own hostname (resolved by your internal DNS).

## Access

- **Root / sudo** on the box (the installer sets up Docker, secrets, and system directories).
- The **install command** from the portal — it embeds a one-time voucher. An org admin generates it in [Register a deployment](register-a-deployment.md).

## Checklist

- [ ] Fresh linux/amd64 VPS, 16 GB RAM, 40 GB disk, public IP
- [ ] Ports 80 and 443 open inbound
- [ ] Outbound reachability to `platform.clowdops.ai` and the container registries (connected mode)
- [ ] DNS A record created (bring-your-own hostname only)
- [ ] Root/sudo access
- [ ] Install command copied from the portal

Next: [Install the appliance](install-the-appliance.md).
