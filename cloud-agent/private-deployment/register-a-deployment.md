# Register a Deployment

**Audience: org admin.** Registering reserves a slot for your new box and mints the one-time voucher its installer needs. You do this in the ClowdOps portal *before* anyone touches the server.

## Open the Deployments page

Log in to the portal as an **organisation admin** and go to **Settings → Deployments**.

![The Settings → Deployments page: the quota pill, a deployment row with its status badge, and the Register deployment button.](images/deployments-list.png)

The page lists every deployment your organisation runs, each with a live **status** and **last seen** time, and a quota pill (e.g. `1 / 3`) showing how many of your allowed slots are in use. If you're at your cap, decommission one first or ask your ClowdOps contact to raise the limit.

## Register

Click **Register deployment** to open the dialog.

![The Register a deployment dialog, with the Label, Hostname, Child-facing authority URL, Founding admin email, and Propagate users fields.](images/register-dialog.png)

Fill in:

| Field | What to enter |
| --- | --- |
| **Label** | A short name for the box, e.g. `paris-dc1`. Used in the auto hostname and throughout the portal. |
| **Hostname** | **Auto (clowdops.ai)** — Central provisions `<label>.dply.clowdops.ai` and its TLS certificate for you. **Bring my own** — you supply a hostname you've pointed at the box (see [Prerequisites → DNS](prerequisites.md#dns)). |
| **Child-facing authority URL** *(optional)* | Only if this box will itself be a **master** for internal children. Enter the internal URL its children will dial, e.g. `https://master.internal.acme`. Leave blank for a standalone deployment. See [Master & children](federation-master-and-children.md). |
| **Founding admin email** | The email that becomes the first platform admin on the new box. Defaults to yours. |
| **Propagate organisation users** | Optional. One-shot copies your org's user roster into the new box (names, emails, roles only — never passwords or keys). Copied users are inactive until they sign in via SSO or are invited. Each one consumes a seat on the new deployment. Leave off unless you specifically want it. |

Click **Register**.

## Copy the install command

The dialog now shows everything the sysadmin needs:

![The post-registration panel with the install command, the one-time voucher, and the allocated hostname.](images/install-command.png)

| What | Notes |
| --- | --- |
| **Install command** | A one-liner to run on the box as root. It embeds the voucher and points at the correct authority. **Copy this exact command** — don't retype it. |
| **Voucher (one-time)** | The enrolment secret, shown **once**. It's already inside the install command; copy it separately only if you need it for a manual install. |
| **Allocated hostname** | The box's address (auto mode only). |

The install command looks like this:

```bash
curl -fsSL https://platform.clowdops.ai/install.sh | sudo bash -s -- --token=<voucher>
```

> [!IMPORTANT]
> The voucher is shown only once and expires in **72 hours**. Copy the install command now and hand it to whoever provisions the box. If it expires or gets lost, just register again — the slot isn't consumed until a box actually enrols.

Hand the command to your sysadmin and continue at [Install the appliance](install-the-appliance.md).

## After the box comes up

Back on the Deployments page, watch the new row move through its lifecycle:

`registered` → `enrolled` → `active`

Once it's **active**, the founding-admin account is ready to claim — see [Install the appliance → Claim the founding admin](install-the-appliance.md#claim-the-founding-admin). If a row sticks at `enrolled` or never appears, see [Operations → Troubleshooting](operations.md#troubleshooting).
