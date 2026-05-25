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
| **OCI** | Cloud | Tenancy OCID, User OCID, Key Fingerprint, API Private Key (PEM), Region (optional) |
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

Every sandbox needs access to an AI model to function. There are two ways to provide it, configured per project in the **AI** tab of Project → Credentials. The two modes are mutually exclusive.

#### BYOK — bring your own key

Add your own API key for OpenAI, Anthropic, Google Gemini, or AWS Bedrock in the project AI tab. Associate it with a sandbox and the agent uses it for all LLM calls in that sandbox.

- **You pay your AI provider directly** for token usage. This cost does not appear in your ClowdOps billing history.
- **ClowdOps bills** sandbox compute time and a small metered usage fee, shown as *BYOK LLM (metered)* and *Sandbox compute* in Settings → Billing.
- The **model resolver** selects the active provider from a priority list (OpenAI → Anthropic → Gemini → Bedrock by default), intersected with which providers are actually attached to the sandbox. The picked model appears in the chat header badge (for example `$0.04 / $5.00 · claude-sonnet-4`).

> [!IMPORTANT]
> A sandbox with no AI credential attached has its chat composer disabled — the agent cannot run until at least one is associated.

To change which model the agent uses, add or remove AI credentials so the priority list resolves to a different provider.

#### Platform-provided AI

At the top of the AI tab on the Project → Credentials page, an **AI provider** selector lets you choose OpenAI, Anthropic, Gemini, or Bedrock and use Flashback's own keys — no credential to create or rotate.

- **LLM cost is billed to your organisation's credit balance**, alongside sandbox compute. Both appear in Settings → Billing as *Platform LLM* and *Sandbox compute*.
- When a platform provider is selected, the **Add AI credential** button in the AI tab is disabled. The two modes cannot be active at the same time.
- To switch **from platform to BYOK**: change the selector to *BYOK — use my own keys* and add an AI credential below.
- To switch **from BYOK to platform**: remove every AI credential from the project first, then select a provider. The selector is replaced by an informational note while any BYOK key is present.

#### Cost at a glance

| Mode | LLM cost | Compute cost |
| --- | --- | --- |
| **BYOK** | On your AI provider's bill | On your ClowdOps balance (*BYOK LLM (metered)* + *Sandbox compute*) |
| **Platform** | On your ClowdOps balance (*Platform LLM*) | On your ClowdOps balance (*Sandbox compute*) |

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
