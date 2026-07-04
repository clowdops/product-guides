# Screenshot placeholders

Screenshots to capture for the private-deployment guides. Drop the PNGs in this
folder using the exact filenames below so the existing `![...](images/…)`
references resolve. Capture at a standard portal width, light theme, with a demo
org (no real customer data / secrets — redact any voucher).

| Filename | Where it's referenced | What to capture |
| --- | --- | --- |
| `deployments-list.png` | [register-a-deployment.md](../register-a-deployment.md) | **Settings → Deployments** list: the quota pill (e.g. `1 / 3`), a couple of rows with status badges, and the **Register deployment** button. |
| `register-dialog.png` | [register-a-deployment.md](../register-a-deployment.md) | The **Register deployment** dialog, empty form — Label, Hostname (Auto/BYO), Founding admin email, Propagate-users checkbox. |
| `install-command.png` | [register-a-deployment.md](../register-a-deployment.md) | The post-registration panel showing the **install command**, the one-time **voucher**, and the allocated hostname (redact the real voucher value). |

Optional extras that would help the guides:

| Filename | Suggested use |
| --- | --- |
| `status-active.png` | A deployment row at `active` with last-seen ticking — for [operations.md](../operations.md) status lifecycle. |
| `register-child.png` | The **Register child** dialog on a master box — for [federation-master-and-children.md](../federation-master-and-children.md). |
| `update-available.png` | A row showing the **update available** badge — for [operations.md](../operations.md#updating). |
