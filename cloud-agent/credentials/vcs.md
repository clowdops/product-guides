[← ClowdOps](../README.md) · [← Credential recipes](README.md)

# Code Repository Credentials

**On this page:** [GitHub](#github) · [GitLab](#gitlab) · [Azure DevOps](#azure-devops)

VCS credentials let the agent clone repositories, read files and history, inspect pull requests, and (if granted write scopes) push changes. All recipes below use the minimum read-only scopes.

---

## GitHub

**What you'll create:** a fine-grained Personal Access Token scoped to the repositories you need.

1. GitHub → top-right avatar → **Settings** → **Developer settings** → Personal access tokens → **Fine-grained tokens** → Generate new token.
2. Set a name and expiry (maximum 1 year; set a calendar reminder to rotate before it expires).
3. Under **Resource owner**, select the organisation or your personal account.
4. Under **Repository access**, select specific repositories or *All repositories*.
5. Under **Permissions**, set:

   | Permission | Scope | Also add if… |
   | --- | --- | --- |
   | Contents | Read | Always required |
   | Metadata | Read | Auto-selected |
   | Pull requests | Read | Agent should read PRs and reviews |
   | Actions | Read | Agent should read workflow run logs |
   | Issues | Read | Agent should read issues and comments |

6. Generate and copy the token immediately.

**ClowdOps fields:** paste the token into the *Personal access token* field.

> For organisation-wide access, a classic PAT with `repo` scope also works but grants broader access. Fine-grained tokens are preferred — they can be scoped to specific repos and expire independently.

---

## GitLab

**What you'll create:** a Personal Access Token, or a Group Access Token for narrower scope.

### Personal token (all projects the user can see)

1. Top-right avatar → **Edit profile** → **Access Tokens** → **Add new token**.
2. Set a name and expiry.
3. Select scopes: `read_api`, `read_repository`.
4. Create personal access token. Copy it immediately.

### Group token (scoped to a specific group and its subgroups)

1. Group → Settings → **Access Tokens** → Add new token.
2. Set a name, expiry, and role (**Reporter** is sufficient for read access).
3. Select scopes: `read_api`, `read_repository`.
4. Create and copy the token.

**ClowdOps fields:** Personal access token · Host URL (e.g. `https://gitlab.com` or your self-hosted instance URL).

---

## Azure DevOps

**What you'll create:** a Personal Access Token scoped to the organisation.

1. Azure DevOps portal → top-right user icon → **Personal access tokens** → **+ New Token**.
2. Set a name, select the **Organisation** (or *All accessible organisations*), and set an expiry.
3. Under **Scopes**, select **Custom defined** and tick:

   | Scope | Level | Also add if… |
   | --- | --- | --- |
   | Code | Read | Always required |
   | Build | Read | Agent should read pipeline results |
   | Release | Read | Agent should read release definitions and deployments |
   | Work Items | Read | Agent should read boards and backlogs |

4. Create and copy the token immediately.

**ClowdOps fields:** Organisation URL (e.g. `https://dev.azure.com/your-org`) · Personal access token.

> Tokens scoped to *All accessible organisations* work across multiple Azure DevOps organisations but are harder to audit. Prefer per-organisation tokens and create one credential per org in ClowdOps.
