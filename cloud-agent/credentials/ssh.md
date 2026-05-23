[← ClowdOps](../README.md) · [← Credential recipes](README.md)

# Server Access (SSH)

**On this page:** [Step 1 — create a user](#step-1--create-a-dedicated-user-on-the-target-host) · [Step 2 — generate a key pair](#step-2--generate-an-ssh-key-pair) · [Step 3 — install the public key](#step-3--install-the-public-key-on-the-host) · [Step 4 — restrict the user (optional)](#step-4--restrict-what-the-user-can-do-optional) · [Step 5 — verify](#step-5--verify-the-connection) · [ClowdOps fields](#clowdops-fields)

SSH credentials let the agent run shell commands on a host — querying logs, inspecting processes, reading configuration, or running diagnostic scripts.

---

## Step 1 — create a dedicated user on the target host

```bash
sudo adduser --disabled-password --gecos "" clowdops
sudo mkdir -p /home/clowdops/.ssh
sudo chmod 700 /home/clowdops/.ssh
sudo chown clowdops:clowdops /home/clowdops/.ssh
```

---

## Step 2 — generate an SSH key pair

Run this on your local machine:

```bash
ssh-keygen -t ed25519 -C "clowdops-agent" -f ~/.ssh/clowdops_key
# Leave the passphrase empty — the agent uses the key non-interactively
```

This produces `~/.ssh/clowdops_key` (private) and `~/.ssh/clowdops_key.pub` (public).

---

## Step 3 — install the public key on the host

```bash
# Using ssh-copy-id
ssh-copy-id -i ~/.ssh/clowdops_key.pub clowdops@your-host

# Or manually, from your local machine
cat ~/.ssh/clowdops_key.pub | ssh your-admin-user@your-host \
  "sudo tee -a /home/clowdops/.ssh/authorized_keys && \
   sudo chmod 600 /home/clowdops/.ssh/authorized_keys && \
   sudo chown clowdops:clowdops /home/clowdops/.ssh/authorized_keys"
```

---

## Step 4 — restrict what the user can do (optional)

For audit-only access, add a `Match` block in `/etc/ssh/sshd_config.d/clowdops.conf`:

```
Match User clowdops
    AllowTcpForwarding no
    X11Forwarding no
    PermitTTY yes
```

Or restrict to specific sudo commands with no password prompt via `/etc/sudoers.d/clowdops`:

```
clowdops ALL=(ALL) NOPASSWD: /usr/bin/journalctl, /bin/cat, /bin/ls, /bin/df, /usr/bin/top
```

Reload sshd after any config changes:

```bash
sudo systemctl reload sshd
```

---

## Step 5 — verify the connection

```bash
ssh -i ~/.ssh/clowdops_key clowdops@your-host "echo ok"
```

If this prints `ok`, the credential is ready to add to ClowdOps.

---

## ClowdOps fields

| Field | Value |
| --- | --- |
| **Host** | Hostname or IP address of the server (e.g. `10.0.0.5` or `bastion.example.com`) |
| **Username** | `clowdops` (or whatever name you gave the user) |
| **Private key** | Full contents of `~/.ssh/clowdops_key` — the private file, not `.pub` |

> If your server listens on a non-standard SSH port, include it in the Host field as `hostname:2222`.
