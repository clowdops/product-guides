[← ClowdBI](README.md) · [Data projects →](data-projects.md)

# Getting Started

**On this page:** [Before you begin](#before-you-begin) · [Sign up](#sign-up) · [Your first question](#your-first-question) · [Where to go next](#where-to-go-next)

This page takes you from no account to your first grounded answer.

## Before you begin

You will need **an account on a BI platform ClowdBI supports**, with permission to read the datasets you want to ask about:

| Platform | What you need |
| --- | --- |
| **Power BI** | An account with **Build** permission on the target datasets (Workspace Admin, Member, or Contributor already have it) |
| **Looker** | API3 credentials (client ID + secret) with access to the models you want to query |
| **Tableau** | A Personal Access Token, and **API Access** permission on the data sources |

Full setup instructions for each are in [Connecting a BI source](connections/README.md).

> [!TIP]
> If you are evaluating ClowdBI against regulated data, read [Data privacy & personal data](data-privacy.md) before you connect anything.

## Sign up

### Step 1: Create your account

Go to the ClowdBI sign-up page and register with your email and a password, or use a social provider (Google, Microsoft, or GitHub).

After registering with email, check your inbox and click the verification link before continuing.

> [!NOTE]
> If the sign-up page shows an **"Invite only"** message instead of the registration form, ClowdOps is running in private preview. Check your inbox for an invite link, or contact your team's administrator. If you already have an account, use the **Sign in** link instead.

### Step 2: Create your organisation

On first login, the onboarding wizard launches automatically. Enter your organisation name and an optional website. These are used for billing and team management.

<!-- Screenshot: ![Onboarding step 1 — organisation name and website](images/onboarding-organisation.png) -->

### Step 3: Choose the AI model

Pick which AI provider powers your agent. **Platform default (recommended)** uses Flashback's own keys and bills LLM usage to your credit balance — nothing to configure.

If you would rather use your own AI account, choose the provider and supply an API key. You then pay that provider directly for tokens; ClowdOps bills only compute and a small metered fee. You can change this later per data project — see [Choosing the AI model](data-projects.md#choosing-the-ai-model).

### Step 4: Create your first data project

A **data project** is the working scope: it holds your BI connections, the catalog built from them, its conversations, and its dashboards.

Name it after the business area you are connecting rather than the platform — `Sales analytics` ages better than `Power BI`, since one project can hold connections to several platforms at once.

<!-- Screenshot: ![Onboarding — naming the first data project](images/onboarding-data-project.png) -->

### Step 5: Connect your BI source

You land on **Connect your BI source**, with a card for each supported platform.

<!-- Screenshot: ![Connect your BI source — Power BI, Looker and Tableau cards](images/connect-choose-provider.png) -->

Pick your platform and follow the flow — Microsoft sign-in for Power BI, a credentials dialog for Looker and Tableau. Step-by-step instructions per platform: [Connecting a BI source](connections/README.md).

### Step 6: Pick the datasets to connect

Once the connection succeeds you are shown everything the connected account can see, grouped by workspace. Tick the datasets you want the agent to be able to query and click **Connect *N* datasets**.

<!-- Screenshot: ![Dataset picker — workspaces expanded with datasets selected](images/connect-dataset-picker.png) -->

> [!TIP]
> Start narrow. Connect the two or three datasets you actually intend to ask about — you can add more at any time from the catalog. A smaller, well-chosen set gives sharper answers than everything your account can reach.

### Step 7: You are in

You land in the chat view with your data project selected, ready to ask a question.

## Your first question

The catalog is built **lazily** — the agent reads a dataset's schema the first time you ask something about it. So your first question does double duty: it triggers discovery and gets you an answer.

Start with something you already know the answer to. Verifying the agent against a number you can check builds far more confidence than a question you cannot validate:

- *"What was total revenue last month?"*
- *"Show me sales by region for this year."*
- *"Which product categories grew fastest quarter on quarter?"*

The agent identifies the entities and measures it needs, writes a native query, runs it, and explains the result. Expand **Show query** under any answer to see exactly what ran.

<!-- Screenshot: ![A chat turn — answer, result table, and the Show query disclosure](images/chat-first-answer.png) -->

If you would rather populate the catalog up front, open the catalog from the sidebar and click **Refresh catalog**.

> [!IMPORTANT]
> Check the first few answers against a source you trust. The agent grounds itself on your semantic model, but a model with ambiguous measures or unlabelled code columns can produce a confident answer that is subtly wrong. [Asking good questions](asking-good-questions.md) covers the four failure modes worth knowing.

## Where to go next

| If you want to… | Go to |
| --- | --- |
| Understand what the agent knows about your data | [The catalog](catalog.md) |
| Get more out of conversations | [Asking questions](chat.md) |
| Turn an answer into a live board | [Dashboards](dashboards.md) |
| Ask questions spanning two datasets | [Cross-dataset links](cross-dataset-links.md) |
| Know exactly what goes where | [Data privacy & personal data](data-privacy.md) |
| Invite colleagues, set budgets, manage billing | [Account & settings](../common/settings.md) |
