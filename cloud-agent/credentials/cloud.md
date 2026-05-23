[← ClowdOps](../README.md) · [← Credential recipes](README.md)

# Cloud Credentials

**On this page:** [Read-only discovery](#read-only-discovery) · [Cost analysis](#cost-analysis)

---

## Read-only discovery

The base credential for any cloud use case. Grants the agent permission to list and read resources across all services — no write or delete access.

### AWS

**What you'll create:** an IAM user with `ReadOnlyAccess`.

**Console**

1. IAM → Users → **Create user** → name it (e.g. `clowdops-auditor`). Do not enable console access.
2. Attach policies directly → search for `ReadOnlyAccess` → tick it → Next → Create user.
3. Click the new user → **Security credentials** tab → **Create access key** → select *Third-party service* → Next → Create.
4. Copy the **Access Key ID** and **Secret Access Key** immediately — AWS will not show the secret again.

**CLI**

```bash
aws iam create-user --user-name clowdops-auditor

aws iam attach-user-policy \
  --user-name clowdops-auditor \
  --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

aws iam create-access-key --user-name clowdops-auditor
# Save AccessKeyId and SecretAccessKey from the output
```

**ClowdOps fields:** Access Key ID · Secret Access Key · Region (your primary region).

> `ReadOnlyAccess` covers `List`, `Describe`, and `Get` across virtually all AWS services and allows reading data inside resources (for example downloading S3 objects). It contains no `Put`, `Post`, `Update`, or `Delete` actions.

---

### GCP

**What you'll create:** a Service Account with `Viewer` at organisation level.

**Step 0 — enable the required APIs**

```bash
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  cloudasset.googleapis.com \
  cloudbilling.googleapis.com \
  compute.googleapis.com \
  sqladmin.googleapis.com \
  cloudfunctions.googleapis.com \
  container.googleapis.com \
  pubsub.googleapis.com \
  iam.googleapis.com \
  --project=YOUR_PROJECT_ID
```

These APIs must be enabled in the project where you create the Service Account. Skipping any one causes the corresponding discovery step to time out or return a permission error.

**Console**

1. IAM & Admin → Service Accounts → **+ Create Service Account** → name it (e.g. `clowdops-auditor`) → Create and Continue → Done.
2. Copy the service account's email address (e.g. `clowdops-auditor@your-project.iam.gserviceaccount.com`).
3. Switch to **Organisation level** using the top project dropdown → IAM & Admin → IAM → **Grant Access**.
4. Paste the service account email → assign **Viewer** (`roles/viewer`) → Save.
5. Back in the project: IAM & Admin → Service Accounts → click the account → **Keys** → **Add Key** → Create new key → JSON → Create. A JSON file downloads — keep it secure.

**CLI**

```bash
export PROJECT_ID=your-project-id
export ORG_ID=your-org-id   # find with: gcloud organizations list
export SA_NAME=clowdops-auditor
export SA_EMAIL=${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com

# Create the service account
gcloud iam service-accounts create $SA_NAME \
  --display-name="ClowdOps Auditor" \
  --project=$PROJECT_ID

# Grant Viewer at the organisation level
gcloud organizations add-iam-policy-binding $ORG_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/viewer"

# Generate the JSON key
gcloud iam service-accounts keys create auditor-key.json \
  --iam-account=$SA_EMAIL \
  --project=$PROJECT_ID
```

**ClowdOps fields:** paste the entire contents of `auditor-key.json` into the *Service Account JSON key* field.

> `roles/viewer` grants metadata read access only (you can see that a bucket exists, not its contents). To read data inside resources, add `roles/storage.objectViewer` for Cloud Storage and `roles/bigquery.dataViewer` for BigQuery.

---

### Azure

**What you'll create:** an App Registration (Service Principal) with `Reader` at the Root Management Group.

**Console**

1. Microsoft Entra ID → App registrations → **+ New registration** → name it (e.g. `ClowdOpsAuditor`), single-tenant → Register.
2. On the Overview page, copy **Application (client) ID** and **Directory (tenant) ID**.
3. Certificates & secrets → **+ New client secret** → set a description and expiry → Add. Copy the **Value** immediately — Azure will not show it again.
4. Management groups → **Tenant Root Group** → Access control (IAM) → + Add → **Add role assignment** → Role: `Reader` → Members: select *User, group, or service principal* → search for `ClowdOpsAuditor` → Review + assign.

**CLI**

```bash
# Create App Registration and Service Principal
APP_ID=$(az ad app create --display-name ClowdOpsAuditor --query appId -o tsv)
az ad sp create --id $APP_ID
SP_OBJ_ID=$(az ad sp show --id $APP_ID --query id -o tsv)

# Generate a client secret (valid 2 years)
CLIENT_SECRET=$(az ad app credential reset \
  --id $APP_ID --years 2 --query password -o tsv)

# Assign Reader at the Root Management Group
# The root management group ID equals the tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)

az role assignment create \
  --assignee-object-id $SP_OBJ_ID \
  --assignee-principal-type ServicePrincipal \
  --role Reader \
  --scope "/providers/Microsoft.Management/managementGroups/${TENANT_ID}"

echo "Tenant ID:     $TENANT_ID"
echo "Client ID:     $APP_ID"
echo "Client Secret: $CLIENT_SECRET"
echo "Subscription:  $(az account show --query id -o tsv)"
```

**ClowdOps fields:** Tenant ID · Client ID · Client Secret · Subscription ID (any subscription in scope).

> `Reader` grants Control Plane access — you can see resource properties. To read actual data inside resources (blob contents, Key Vault secrets, Service Bus messages), add the relevant Data Plane roles: `Storage Blob Data Reader`, `Key Vault Secrets User`, and so on.

---

## Cost analysis

Start with the **[read-only discovery](#read-only-discovery)** credential above, then add the billing permissions below. Everything else stays the same.

### AWS

**Two extra steps:**

**1. Enable IAM billing access (root account required — one-time)**

Log in as the root account → click your account name (top right) → Account → scroll to *IAM User and Role Access to Billing Information* → Edit → tick *Activate IAM Access* → Update. Without this toggle, billing policies attached to IAM users have no effect regardless of what's attached.

**2. Attach the billing policy**

```bash
aws iam attach-user-policy \
  --user-name clowdops-auditor \
  --policy-arn arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess
```

This grants read access to Cost Explorer, Budgets, and usage reports.

> **Cost Explorer API pricing:** each API request costs $0.01. ClowdOps caches cost data within a session, but avoid scheduling cost-heavy prompts at a high frequency.

---

### GCP

**Two extra steps:**

**1. Enable billing export to BigQuery**

GCP's Cloud Billing API only returns catalog pricing, not historical usage costs. To get actual spend data, export it to BigQuery first: Billing → **Billing export** → Standard usage cost → select or create a BigQuery dataset → Save.

**2. Grant billing and BigQuery access**

```bash
# Billing Account Viewer (account-level metadata)
gcloud beta billing accounts add-iam-policy-binding YOUR_BILLING_ACCOUNT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/billing.viewer"

# BigQuery access on the billing export project/dataset
gcloud projects add-iam-policy-binding YOUR_BILLING_PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/bigquery.dataViewer"

gcloud projects add-iam-policy-binding YOUR_BILLING_PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/bigquery.user"
```

Find your billing account ID at Billing → Account Management (format: `XXXXXX-XXXXXX-XXXXXX`).

> Once the export is live, the agent queries your billing data via SQL against the BigQuery dataset. First export typically arrives within 24 hours of enabling it.

---

### Azure

**One extra step:** assign `Cost Management Reader` at the billing scope.

```bash
az role assignment create \
  --assignee-object-id $SP_OBJ_ID \
  --assignee-principal-type ServicePrincipal \
  --role "Cost Management Reader" \
  --scope "/providers/Microsoft.Billing/billingAccounts/YOUR_BILLING_ACCOUNT_ID"
```

Via portal: Cost Management + Billing → select your Billing Account or Billing Profile → Access control (IAM) → + Add → Add role assignment → `Cost Management Reader` → assign to `ClowdOpsAuditor`.

> On Enterprise Agreement subscriptions, the billing scope structure differs — you may need to assign the role at the EA enrollment level. Check which scope your Cost Management dashboard is scoped to.
