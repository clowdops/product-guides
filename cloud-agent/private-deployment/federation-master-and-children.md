# Master & Children

**Audience: org admin + sysadmin.** Most customers run one or more standalone **connected** deployments and never need this page. Reach for it when you have an **internal-network** or **air-gapped** estate: one box acts as a local authority (a **master**) that licenses and serves its own **children**.

## When you need a master

A plain connected deployment enrols directly with Central and needs outbound reachability to `platform.clowdops.ai`. That doesn't work when:

- Boxes live on an **internal network** with no direct route to the internet.
- The environment is **air-gapped** by policy.
- You want a **single point of contact** with Central for a fleet of boxes.

In those cases you promote one connected deployment to a **master**. It holds a delegation from Central and can then license children entirely inside your perimeter. Children talk only to the master; only the master talks to Central.

```
Central (platform.clowdops.ai)
   └── Master  (your connected deployment, reachable inside your network)
         ├── Child A  (internal / air-gapped)
         └── Child B  (internal / air-gapped)
```

> [!NOTE]
> The tree is **one level deep**. A master has children; a child cannot have its own children. On a child, the Register button is hidden — it mints nothing.

## Make a master

A master is just a connected deployment that was told where its children will reach it. Set this at registration time:

1. Register the box as a normal connected deployment ([Register a deployment](register-a-deployment.md)).
2. In the register dialog, fill **Child-facing authority URL** with the address its children will dial from inside your network — an internal IP or corporate-DNS name, e.g. `https://master.internal.acme`.
3. Install it as usual.

That box can now license children.

## Register a child

From the **master's own** portal (log in to the master box, **Settings → Deployments**):

1. Click **Register child**. The role is fixed to `child` — its authority is this master.
2. Give it a **label** and an **internal hostname** (a DNS A record on *your* network pointing at the child box). Children are bring-your-own-hostname only — there's no automatic public DNS.
3. Copy the install command and run it on the child box, exactly as for a connected deployment.

The child enrols with the master, receives a master-signed licence (which chains back to Central's key), and heartbeats to the master. The master rolls its children's count up to Central so your organisation's quota stays accurate — without Central ever seeing the individual child boxes.

## Air-gapped installs

For a child with no internet at all, the master also acts as a **container-registry mirror**: it serves the appliance images to its children over HTTPS, so they never need `ghcr.io` or `docker.io`. This is restricted to internal source IPs — the private images are never exposed publicly.

Air-gapped children set both image registries to the master's address so *every* image pulls from the master:

```bash
REG_GHCR=master.internal.acme
REG_HUB=master.internal.acme
```

The connected installer configures this automatically in mirror mode. For a fully hand-run air-gapped install, you transfer the appliance bundle and licence by file rather than over the network — contact your ClowdOps representative for the offline install procedure, which is beyond this quick-start guide.

## Backups on a master

A master's `/etc/clowd/secrets/federation` directory holds both its own licence **and** the delegation that lets it sign children's licences. Back it up with the same care as the master encryption key — losing it means re-enrolling the master *and* all its children. See [Operations → Backup & recovery](operations.md#backup--recovery).
