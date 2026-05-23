[← ClowdOps](../README.md) · [← Workspace & credentials](../your-workspace.md)

# Credential Setup Recipes

This section gives you ready-to-run recipes for each common role. Pick the guide that matches what you want to do, follow the steps for your provider, and paste the result into the **Credentials** tab of your sandbox.

## Quick pick

| I want to… | Role | Guide |
| --- | --- | --- |
| Discover and query cloud resources | DevOps / SRE | [Cloud — read-only](cloud.md#read-only-discovery) |
| Analyse costs and spend | FinOps | [Cloud — read-only + billing](cloud.md#cost-analysis) |
| Run security and IAM audits | SecOps | [Security inspection](security.md) |
| Work with repositories and CI | Dev / DevOps | [Code repositories](vcs.md) |
| Run commands on a server | DevOps / SRE | [Server access](ssh.md) |

## Guides

| Guide | What it covers |
| --- | --- |
| [Cloud credentials](cloud.md) | Read-only discovery and cost analysis for AWS, GCP, and Azure |
| [Security inspection](security.md) | IAM auditing, Azure Graph permissions, and secret scanning with trufflehog / gitleaks |
| [Code repositories](vcs.md) | GitHub fine-grained PATs, GitLab tokens, Azure DevOps PATs |
| [Server access](ssh.md) | SSH key setup, dedicated user, and optional read-only restrictions |
