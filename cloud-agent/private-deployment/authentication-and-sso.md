# Authentication & SSO

**Audience: org admin (with sysadmin for the config edits).** How people sign in to your private deployment.

## Email + password (works out of the box)

Every private deployment supports **email and password** sign-in with no configuration. The founding admin is created during install ([Install the appliance → Claim the founding admin](install-the-appliance.md#claim-the-founding-admin)); from there you invite or provision the rest of your team.

If [SMTP is configured](configuration.md#email-smtp), invitations and password resets go out by email. If not, you provision users by other means.

## Single sign-on — how it works on a private box

Because a private deployment runs on **your own domain**, it can't reuse ClowdOps' shared SSO app — an identity provider only trusts sign-in redirects to domains it has been told about. So SSO on a private box uses **your own identity provider**:

- **Your own Google / Microsoft / GitHub OAuth app** — you register an app with the provider, authorise your deployment's domain, and hand the box the client credentials.
- **Generic OIDC** — connect any standards-compliant OpenID Connect provider (Okta, Auth0, Entra ID, Keycloak, Ping, …).

Three things make this simple on the appliance:

- **You configure it once, on the box.** SSO settings are environment values in `operator.env` (see [Configuration](configuration.md#optional-operator-values-operatorenv)). No image rebuild, no per-user setup.
- **Buttons appear automatically.** The sign-in page reads the live configuration at load time. Configure a provider and its button shows up; remove it and the button disappears. Until you configure any, sign-in is **email + password**.
- **One domain, one callback.** Everything runs on your single appliance hostname, so there is exactly one redirect URL to register per provider, and no CORS or cookie settings to touch.

> [!NOTE]
> **Client secrets never reach the browser.** Only the public client ID and (for OIDC) the issuer URL are sent to the sign-in page. Secrets stay in `operator.env` on the box and are used only in the server-side token exchange.

### Where the settings go, and applying them

Add the lines shown below to the operator secrets file, then restart the stack:

```bash
# 1. Edit the operator env file
$EDITOR /etc/clowd/secrets/env/operator.env

# 2. Apply
cd /opt/clowd/deploy/topologies/appliance
docker compose up -d
```

This is the same file and flow as [SMTP and backups](configuration.md#optional-operator-values-operatorenv). Leaving a provider's lines out simply means its button is not shown.

### The redirect (callback) URL

Every provider asks for an **authorised redirect URI** (sometimes "callback URL" or "reply URL"). For a private deployment it is always your appliance URL plus `/auth/<provider>/callback`:

| Provider | Redirect URI to register |
| --- | --- |
| Google | `https://clowd.acme.example/auth/google/callback` |
| Microsoft | `https://clowd.acme.example/auth/microsoft/callback` |
| GitHub | `https://clowd.acme.example/auth/github/callback` |
| Generic OIDC | `https://clowd.acme.example/auth/oidc/callback` |

Replace `clowd.acme.example` with your own `CLOWD_SITE_ADDRESS` (the domain from [Configuration](configuration.md#the-essentials-env)). It must be **HTTPS** and match exactly — most "redirect URI mismatch" errors are a trailing slash or an `http://` vs `https://` difference.

---

## Google

1. In the [Google Cloud Console](https://console.cloud.google.com/) → **APIs & Services → Credentials**, create an **OAuth client ID** of type **Web application**.
2. Under **Authorised redirect URIs**, add `https://clowd.acme.example/auth/google/callback`.
3. Copy the **Client ID** and **Client secret** into `operator.env`:

```bash
GOOGLE_CLIENT_ID=1234567890-abc.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=...
```

To restrict sign-in to your company's Google Workspace, configure the OAuth consent screen as **Internal** within your Workspace organisation.

---

## Microsoft (Entra ID)

1. In the [Entra admin center](https://entra.microsoft.com/) → **App registrations → New registration**.
2. Set the **Redirect URI** (platform: **Web**) to `https://clowd.acme.example/auth/microsoft/callback`.
3. From **Overview**, copy the **Application (client) ID** and the **Directory (tenant) ID**.
4. Under **Certificates & secrets**, create a **client secret** and copy its value.
5. Add to `operator.env`:

```bash
MICROSOFT_CLIENT_ID=...
MICROSOFT_CLIENT_SECRET=...
# Your tenant's Directory (tenant) ID or primary domain — restricts sign-in to
# your organisation. Use "common" only if you intend to accept any Microsoft
# account (personal or work).
MICROSOFT_TENANT_ID=00000000-0000-0000-0000-000000000000
```

> [!TIP]
> Setting `MICROSOFT_TENANT_ID` to your own tenant is the difference between "only my company" and "any Microsoft user in the world." For a company deployment, always pin your tenant.

---

## GitHub

1. In GitHub → **Settings → Developer settings → OAuth Apps → New OAuth App** (an organisation-owned app if you want org control).
2. Set **Authorization callback URL** to `https://clowd.acme.example/auth/github/callback`.
3. Generate a **client secret**, then add to `operator.env`:

```bash
GITHUB_CLIENT_ID=...
GITHUB_CLIENT_SECRET=...
```

GitHub sign-in matches users by their **verified** GitHub email. Members without a verified email on their GitHub account can't be matched — invite them by email instead.

---

## Generic OIDC (Okta, Auth0, Entra, Keycloak, …)

The generic connector works with any provider that implements **OpenID Connect discovery** — it fetches `<issuer>/.well-known/openid-configuration` and wires up the authorisation, token, and key (JWKS) endpoints for you, using **PKCE** and **id_token signature verification** automatically.

1. In your identity provider, create an **OIDC / OpenID Connect web application**.
2. Set its redirect URI to `https://clowd.acme.example/auth/oidc/callback`.
3. Note the **issuer URL**, **client ID**, and **client secret**. The issuer is the base URL the provider documents for discovery, for example:
   - Okta — `https://acme.okta.com`
   - Auth0 — `https://acme.eu.auth0.com`
   - Entra ID — `https://login.microsoftonline.com/<tenant-id>/v2.0`
   - Keycloak — `https://id.acme.example/realms/<realm>`
4. Add to `operator.env`:

```bash
OIDC_ISSUER_URL=https://acme.okta.com
OIDC_CLIENT_ID=...
OIDC_CLIENT_SECRET=...
# Optional. Defaults shown.
OIDC_SCOPES=openid profile email
OIDC_DISPLAY_NAME=Acme SSO          # the label on the sign-in button
```

`OIDC_DISPLAY_NAME` is what the button reads — "Continue with Acme SSO". If omitted it reads "Continue with SSO".

> [!IMPORTANT]
> **The box must be able to reach the provider.** OIDC discovery, token exchange, and key fetching are made **from the appliance**, not the browser. A public IdP (Okta/Auth0/Entra) therefore needs outbound internet from the box; an on-prem IdP (e.g. Keycloak) needs to be reachable on the internal network. On a fully **air-gapped** deployment, only an in-network OIDC provider will work — public Google/Microsoft/GitHub sign-in requires outbound reachability they don't have.

> [!NOTE]
> The generic connector requires **OpenID Connect** (it validates a signed `id_token`). A provider that speaks bare OAuth 2.0 with no OIDC layer isn't supported through this path — use the named Google/Microsoft/GitHub connectors, or front the provider with an OIDC-capable gateway.

---

## Making SSO the only sign-in option

By default the email + password form is shown alongside any SSO buttons. To hide it and force everyone through your identity provider, add:

```bash
PASSWORD_LOGIN=false
```

> [!WARNING]
> Before turning this on, confirm at least one SSO provider works **and** that an admin account is reachable through it. Otherwise you can lock yourself out. Password sign-in for the founding admin is your recovery path — keep it enabled until SSO is verified end-to-end. If you do get locked out, re-enable it by removing this line and running `docker compose up -d`.

---

## How SSO accounts map to your team

The first time someone signs in with SSO, the deployment matches them to a user by their **verified email address**:

- **Already invited / provisioned** (their email exists on the box) → they are linked to that account and land in your organisation. **This is the recommended flow:** invite your team first (in the app, from **Settings → Organization**, or provision them), then have them sign in with SSO.
- **Not yet known** → a new account is created only if self-service registration is enabled on the box. In **invite-only** mode (`OPEN_REGISTRATION=false`), an unknown SSO user is refused — exactly so that only people you've invited can get in.

Because of this, the clean pattern for a private deployment is: **invite the people you want, then let them sign in with SSO.** Their first SSO login links to the invited account and drops them straight into your org with the role you gave them.

---

## Verifying & troubleshooting

**Check what the box is advertising.** The sign-in page builds its buttons from a small public config document. You can read it directly:

```bash
curl -s https://clowd.acme.example/api/public-config | jq .authProviders
```

Each configured provider appears with `"enabled": true`. If an OIDC provider shows `"enabled": false`, discovery failed — the box couldn't reach `<issuer>/.well-known/openid-configuration`. Check the issuer URL and network reachability.

| Symptom | Likely cause |
| --- | --- |
| Button doesn't appear | The provider's `*_CLIENT_ID` isn't set, or you didn't `docker compose up -d` after editing `operator.env`. |
| "redirect_uri mismatch" from the provider | The callback URL registered with the provider doesn't exactly match `https://<your-domain>/auth/<provider>/callback` (scheme, host, or trailing slash). |
| OIDC button missing / `enabled:false` | Discovery couldn't reach the issuer, or `OIDC_ISSUER_URL` is wrong. Confirm the box can `curl` the issuer's `.well-known/openid-configuration`. |
| SSO succeeds but the user has no organisation | They weren't invited first and self-registration created a bare account. Invite the email, then have them sign in again. |
| Sign-in loops back to the login page | The appliance URL must be **HTTPS** with a valid certificate — sign-in sessions are cookie-based and require a secure origin. Verify `CLOWD_SITE_ADDRESS` resolves and Caddy has issued a certificate. |

Still stuck? Your ClowdOps representative can help you register the identity-provider app and check the box's configuration.
