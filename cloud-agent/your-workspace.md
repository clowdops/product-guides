[← ClowdOps](README.md) · [← Getting Started](getting-started.md) · [Chat →](chat.md)

# Projects, Sandboxes & Credentials

**On this page:** [Projects and sandboxes](#projects-and-sandboxes) · [Credentials](#credentials) · [How your keys stay private at rest](#how-your-keys-stay-private-at-rest) · [Cloud credentials](#cloud-credentials) · [AI credentials](#ai-credentials) · [Notification channels](#notification-channels)

## Projects and sandboxes

**Projects** are team-level groupings. Every sandbox belongs to a project. Use projects to separate concerns — for example, one project per team or per application domain.

**Sandboxes** are the execution scope. All agent runs, templates, schedules, and credentials are tied to a sandbox. A common pattern is one sandbox per cloud account or per environment (dev / staging / prod).

Switch between projects and sandboxes at any time using the dropdowns at the top of the left sidebar. The agent always operates within the currently selected sandbox.

---

## Credentials

Credentials connect the agent to your cloud providers and AI APIs. They are stored encrypted and never exposed in plaintext after creation.

Open the **Credentials** tab inside any sandbox to manage them.

### How your keys stay private at rest

Your cloud and AI credentials are not “one password in a database row.” ClowdOps uses a **federated protection model** for sensitive material at rest: the pieces that *could* unlock data are deliberately **split across the trust boundary**, so no single store, process, or compromise path holds the whole story. There is no lone master key sitting in one drawer waiting to decrypt everything.

In practice, sealed bundles are stored as **layered ciphertext**—a modern envelope design where bulk data is encrypted under keys that are themselves wrapped under a separate asymmetric trust anchor. Integrity is checked before anything is trusted, and **cryptographic proof-of-possession** is required before sealed configuration is released to an execution node. That mirrors how the agent tier boots: encrypted material is fetched from the control plane only after a **signed, time-bound attestation**, and only then unwrapped locally with material that never ships as plaintext over the wire.

The net effect is **defence in depth that earns the name**: even a sophisticated breach of one layer should still leave an attacker staring at noise—because federation was the point from day one, not an afterthought.

### Cloud credentials

Cloud credentials grant the agent access to your infrastructure. Supported providers:

| Provider | Type | Required fields |
| --- | --- | --- |
| **AWS** | Cloud | Access Key ID, Secret Access Key, Region |
| **GCP** | Cloud | Service Account JSON key |
| **Azure** | Cloud | Tenant ID, Client ID, Client Secret, Subscription ID |
| **SSH** | Compute / VMs | Host, Username, Private key |
| **GitHub** | VCS | Personal access token or App credentials |
| **GitLab** | VCS | Personal access token, Host URL |
| **Azure DevOps** | VCS | Organisation URL, Personal access token |

<!-- Screenshot: ![Cloud tab — connecting infrastructure providers](./images/cloud-agent-credentials-cloud-tab.png) -->

To add a cloud credential:

1. Click **Add credential** in the Cloud tab.
2. Select a provider (AWS, GCP, Azure, GitHub, and so on).
3. Fill in the required fields (for example Access Key ID + Secret for AWS).
4. Save. The credential appears in the list with a safe display hint (for example `AKIA1234 / us-east-1`).

Credentials you create at the project level are reusable across sandboxes. From the Credentials tab you can **associate** existing credentials with the current sandbox or **dissociate** ones no longer needed.

### AI credentials

AI credentials let the agent call LLM APIs on your behalf (OpenAI, Anthropic, Google Gemini, AWS Bedrock, and so on).

<!-- Screenshot: ![AI tab — connecting LLM providers](./images/cloud-agent-credentials-ai-tab.png) -->

The process is identical to cloud credentials: add, fill provider fields, save, and associate with the sandbox.

> [!IMPORTANT]
> You need at least one AI credential in the sandbox for the agent to function. Without one, the chat composer is disabled.

#### Which model the agent uses

ClowdOps picks the chat model automatically from the AI credentials attached to the sandbox. The platform has a provider-priority list (OpenAI → Anthropic → Gemini → Bedrock by default); the resolver intersects that list with which providers your sandbox actually has keys for and selects the first match.

The picked model is shown in the chat header badge once the first turn completes (for example `$0.07 / $5.00 · gpt-5.2`). To change the model, add or remove AI credentials so the priority resolution lands on a different provider.

### Notification channels

Notification channels let the agent push messages to where your team already is — Slack, Microsoft Teams, PagerDuty, or email (SMTP). They appear in the **Notifications** tab of the Credentials section.

| Provider | Required fields |
| --- | --- |
| **Slack** | Incoming webhook URL |
| **Microsoft Teams** | Incoming webhook URL |
| **PagerDuty** | Routing key (Events API v2) |
| **SMTP** | Host, port, username, password, sender address, recipient address(es) |

The process is the same as for other credentials: click **Add notification channel** in the Notifications tab, select the provider, fill in the fields, and save.

> [!IMPORTANT]
> Notification credentials are **server-side only**. The webhook URL or API key is never injected into the sandbox shell — the platform makes the outbound request on the agent's behalf. This is intentional: it keeps secrets out of bash history and audit logs.

For a step-by-step setup guide for each provider (including CLI examples), see [Credential Setup Recipes](credentials/README.md).

Once a channel is attached to a sandbox, the agent can use it in two ways:
- **Ad-hoc during chat** — ask the agent to *"post this finding to Slack"* and it will call the `notify` tool (see [Sending notifications from chat](chat.md#sending-notifications)).
- **Automatic schedule digests** — configure a channel on a schedule and the platform posts a summary after each run (see [Post-run digest](schedules.md#step-6-post-run-digest)).
