[← ClowdOps](../README.md) · [← Credential recipes](README.md)

# Security Inspection

**On this page:** [What you need](#what-you-need) · [Azure — Microsoft Graph](#azure--microsoft-graph) · [Secret scanning in the sandbox](#secret-scanning-in-the-sandbox)

The [read-only discovery](cloud.md#read-only-discovery) credential already includes IAM read access on all three providers — no separate security role is required. From a single `ReadOnlyAccess` / `Viewer` / `Reader` credential, the agent can enumerate IAM users, roles, policies, group memberships, firewall rules, public-access configurations, and more.

## What you need

| Provider | Credential | Covers |
| --- | --- | --- |
| AWS | Read-only ([setup](cloud.md#aws)) | IAM users, roles, policies, S3 ACLs, security groups, CloudTrail |
| GCP | Read-only ([setup](cloud.md#gcp)) | IAM bindings, service accounts, firewall rules, org policies |
| Azure | Read-only ([setup](cloud.md#azure)) | RBAC assignments, NSGs, policy definitions, resource locks |
| Azure (extended) | Read-only + Graph (below) | User inventory, M365 licenses, sign-in activity, audit logs |

---

## Azure — Microsoft Graph

Required for M365/D365 license analysis, user inventory, and sign-in audit logs. Grant these as **Application** permissions (not Delegated) on top of the base App Registration — the agent runs unattended.

### Portal

1. Microsoft Entra ID → App registrations → your app → **API permissions** → + Add a permission → Microsoft Graph → **Application permissions**.
2. Search for and tick each permission:

   | Permission | Role GUID | Enables |
   | --- | --- | --- |
   | `Organization.Read.All` | `498476ce-e0fe-48b0-b801-37ba7e2685c6` | Tenant-owned licenses and seat counts |
   | `User.Read.All` | `df021288-bdef-4463-88db-98f22de89214` | User list with assigned licenses |
   | `Directory.Read.All` | `7ab1d382-f21e-4acd-a863-ba3e13f7da61` | Full user, group, and license enumeration |
   | `Reports.Read.All` | `230c1aed-a721-4c5d-9cb4-a90514e508ef` | M365 / D365 usage reports |
   | `AuditLog.Read.All` | `b0afded3-3588-46d8-8b3d-9842eff778da` | Sign-in activity and audit logs |

3. Click **Grant admin consent for \<tenant\>** and confirm. Verify each row shows a green ✓ in the Status column.

> The *Grant admin consent* button requires a Global Administrator, Privileged Role Administrator, Application Administrator, or Cloud Application Administrator. If you don't have one of those roles, ask someone who does — permissions stay pending until the button is clicked.

### CLI

The Graph app ID and permission GUIDs are constants — they are the same across every tenant.

```bash
GRAPH="00000003-0000-0000-c000-000000000000"  # Microsoft Graph app ID (constant)

az ad app permission add --id $APP_ID --api $GRAPH \
  --api-permissions \
    498476ce-e0fe-48b0-b801-37ba7e2685c6=Role \
    df021288-bdef-4463-88db-98f22de89214=Role \
    7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role \
    230c1aed-a721-4c5d-9cb4-a90514e508ef=Role \
    b0afded3-3588-46d8-8b3d-9842eff778da=Role

az ad app permission admin-consent --id $APP_ID
```

The `=Role` suffix marks these as Application permissions — using `=Scope` would configure them as Delegated, which does not work for unattended access.

### Verifying

```bash
# Log in as the Service Principal
az login --service-principal \
  --username $APP_ID \
  --password $CLIENT_SECRET \
  --tenant $TENANT_ID

# Check Organization.Read.All
az rest --method get \
  --url 'https://graph.microsoft.com/v1.0/subscribedSkus' \
  --query 'value[].{sku:skuPartNumber, total:prepaidUnits.enabled, consumed:consumedUnits}' \
  -o table

# Check Directory.Read.All + AuditLog.Read.All
az rest --method get \
  --url "https://graph.microsoft.com/v1.0/users?\$select=userPrincipalName,signInActivity&\$top=5" \
  -o json
```

A table of SKUs means `Organization.Read.All` is working. If `signInActivity` appears in the second call, all audit permissions are live.

| Response | Meaning |
| --- | --- |
| Table of SKUs | `Organization.Read.All` is working |
| `signInActivity` field present | All audit permissions are live |
| 403 | Consent didn't land — re-check portal and click *Grant admin consent* again from an admin account |
| 401 | SP credentials are wrong (expired secret, wrong tenant) — not a permissions issue |
| `signInActivity` is `null` on every user | Tenant is on Entra ID free tier; see note below |

> **Entra ID P1/P2 required for sign-in activity.** On the free tier, `signInActivity` returns `null` for every user even with `AuditLog.Read.All` granted — this is a tenant SKU limitation, not a permissions issue. Check Entra ID → Overview → Licenses. Fall back to `lastPasswordChangeDateTime` or skip sign-in correlation if upgrading is not an option.

---

## Secret scanning in the sandbox

Once a VCS credential is attached (see [Code repositories](vcs.md)), the agent has `trufflehog` and `gitleaks` available in its sandbox to scan repository history for leaked secrets.

| Tool | Command | Best for |
| --- | --- | --- |
| `trufflehog` | `trufflehog git file://<path> --only-verified` | Live-verifying findings against provider APIs — verified secrets are still active and dangerous |
| `gitleaks` | `gitleaks git <path>` | Fast detection-only sweep over full git history — good as a first-pass triage |

Example prompts to try:

- *"Scan this repo's git history for leaked secrets and tell me which ones are still live."*
- *"Run gitleaks across all repos in this org and summarise findings by severity."*
- *"Check whether any AWS keys committed to this repo in the last 6 months are still valid."*
