---
icon: folder-tree
---

# Projects, Sandboxes & Credentials

## Projects and sandboxes

**Projects** are team-level groupings. Every sandbox belongs to a project. Use projects to separate concerns — for example, one project per team or per application domain.

**Sandboxes** are the execution scope. All agent runs, templates, schedules, and credentials are tied to a sandbox. A common pattern is one sandbox per cloud account or per environment (dev / staging / prod).

Switch between projects and sandboxes at any time using the dropdowns at the top of the left sidebar. The agent always operates within the currently selected sandbox.

---

## Credentials

Credentials connect the agent to your cloud providers and AI APIs. They are stored encrypted and never exposed in plaintext after creation.

Open the **Credentials** tab inside any sandbox to manage them.

### Cloud credentials

Cloud credentials grant the agent access to your infrastructure. Supported providers:

| Provider | Type | Required fields |
|---|---|---|
| **AWS** | Cloud | Access Key ID, Secret Access Key, Region |
| **GCP** | Cloud | Service Account JSON key |
| **Azure** | Cloud | Tenant ID, Client ID, Client Secret, Subscription ID |
| **SSH** | Compute / VMs | Host, Username, Private key |
| **GitHub** | VCS | Personal access token or App credentials |
| **GitLab** | VCS | Personal access token, Host URL |
| **Azure DevOps** | VCS | Organisation URL, Personal access token |

<figure><img src="../.gitbook/assets/cloud-agent-credentials-cloud-tab.png" alt=""><figcaption>Cloud tab — connecting infrastructure providers</figcaption></figure>

To add a cloud credential:

1. Click **Add credential** in the Cloud tab.
2. Select a provider (AWS, GCP, Azure, GitHub, etc.).
3. Fill in the required fields (e.g., Access Key ID + Secret for AWS).
4. Save. The credential appears in the list with a safe display hint (e.g., `AKIA1234 / us-east-1`).

Credentials you create at the project level are reusable across sandboxes. From the Credentials tab you can **associate** existing credentials with the current sandbox or **dissociate** ones no longer needed.

### AI credentials

AI credentials let the agent call LLM APIs on your behalf (OpenAI, Anthropic, Google Gemini, AWS Bedrock, etc.).

<figure><img src="../.gitbook/assets/cloud-agent-credentials-ai-tab.png" alt=""><figcaption>AI tab — connecting LLM providers</figcaption></figure>

The process is identical to cloud credentials: add, fill provider fields, save, and associate with the sandbox.

{% hint style="info" %}
You need at least one AI credential in the sandbox for the agent to function. Without one, the chat composer is disabled.
{% endhint %}

### Gateway tokens

Gateway tokens are sandbox-scoped bearer tokens in OpenAI-compatible format. They let external tools or scripts call Cloud Agent's AI gateway directly, without exposing your underlying provider keys.

To create a gateway token:

1. Open the **Gateway Tokens** tab (inside Credentials).
2. Click **Generate token**.
3. Copy the token immediately — it is shown only once.

You can create multiple tokens per sandbox (useful for separating dev and CI environments) and revoke any of them individually.
