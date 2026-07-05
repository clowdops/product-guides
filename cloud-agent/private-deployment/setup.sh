#!/usr/bin/env bash
# =============================================================================
# ClowdOps private deployment — guided setup
# =============================================================================
# An all-in-one, interactive companion to the private-deployment guide. It walks
# a sysadmin through every decision, writes the box's optional configuration
# (SSO / SMTP / S3 backups / login policy), and then hands off to the official
# Central installer to install Docker, enrol the box, and bring the stack up.
#
# It does NOT replace the Central installer — it WRAPS it, so the enrolment,
# licensing, and bring-up logic always stays in one place. What this script adds
# is the part the installer leaves manual: operator.env (sign-in providers, mail,
# backups), plus friendly guidance for each choice.
#
# WHAT YOU NEED FIRST
#   An org admin must have registered this box in the portal
#   (Settings -> Deployments -> Register deployment / Register child) and handed
#   you the install command it produced. That command carries a one-time VOUCHER
#   and points at the correct AUTHORITY (Central, or your master box). This
#   script needs that voucher — it cannot mint one (registration is a portal
#   action done in a browser).
#
# QUICK START
#   sudo ./setup.sh                                  # fully interactive
#   sudo ./setup.sh --install-command='curl -fsSL https://platform.clowdops.ai/install.sh | sudo bash -s -- --token=fbd_XXXX'
#   sudo ./setup.sh --token=fbd_XXXX                 # + authority defaults to Central
#
# MODES
#   (default)        Install: configure -> pre-seed operator.env -> run installer -> verify.
#   --reconfigure    Change SSO/SMTP/backups on an already-installed box, then
#                    apply with `docker compose up -d`. Skips the installer.
#   --dry-run        Show the operator.env and the exact install command that
#                    WOULD be produced. Writes nothing, runs nothing.
#
# Run `./setup.sh --help` for the full flag reference.
#
# The role (master / child) is decided in the portal and baked into the voucher;
# this script reads it back and reflects it. Public-IP detection is only a
# sanity check, never the decision.
# =============================================================================

set -euo pipefail

SETUP_VERSION="1.0.0"

# --- paths (overridable via env, matching the Central installer) -------------
INSTALL_DIR="${CLOWD_INSTALL_DIR:-/opt/clowd}"
SECRETS_DIR="${SECRETS_DIR:-/etc/clowd/secrets}"
APP_DIR="$INSTALL_DIR/deploy/topologies/appliance"
OPERATOR_ENV="$SECRETS_DIR/env/operator.env"

# --- inputs / decisions (each has a matching flag; prompts default to these) -
INSTALL_COMMAND=""
TOKEN=""
AUTHORITY_URL="https://platform.clowdops.ai"
ROLE=""                      # master | child | connected  (default: from voucher)
HOSTNAME_OVERRIDE=""         # bring-your-own DNS name
SERVE_MIRROR=""              # master only: serve a registry mirror to children
AUTHORITY_IP=""              # child only: pin the master's host to an internal IP
SANDBOX_IMAGES=""            # all | chat | none | comma list

SSO_LIST=""                  # comma list from --sso; empty => ask interactively
GOOGLE_CLIENT_ID="" ; GOOGLE_CLIENT_SECRET=""
MICROSOFT_CLIENT_ID="" ; MICROSOFT_CLIENT_SECRET="" ; MICROSOFT_TENANT_ID=""
GITHUB_CLIENT_ID="" ; GITHUB_CLIENT_SECRET=""
OIDC_ISSUER_URL="" ; OIDC_CLIENT_ID="" ; OIDC_CLIENT_SECRET=""
OIDC_SCOPES="" ; OIDC_DISPLAY_NAME=""

PASSWORD_LOGIN=""            # true | false
OPEN_REGISTRATION=""         # true | false

SMTP_HOST="" ; SMTP_PORT="" ; SMTP_USER="" ; SMTP_PASSWORD="" ; SMTP_SECURE="" ; SMTP_FROM=""
BACKUP_S3_ACCESS_KEY="" ; BACKUP_S3_SECRET_KEY="" ; BACKUP_S3_BUCKET="" ; BACKUP_S3_REGION=""

MODE="install"              # install | reconfigure | dryrun
INTERACTIVE=1
ASSUME_YES=0

# --- derived at runtime ------------------------------------------------------
VOUCHER_ROLE=""             # role as registered in the portal (from enrollment-info)
AUTO_HOST=""                # auto hostname (auto DNS mode)
MASTER_AUTHORITY_URL=""     # non-empty => this box is a master
REGISTRY_URL=""             # non-empty => air-gapped: pull images from master mirror
PUBLIC_IP=""
SITE_HOST=""                # the host used to build SSO callback URLs
IS_AIRGAPPED=0

# =============================================================================
# Small helpers
# =============================================================================
c_g='\033[1;32m'; c_y='\033[1;33m'; c_r='\033[1;31m'; c_b='\033[1;34m'; c_0='\033[0m'
log()  { printf "${c_g}==>${c_0} %s\n" "$*"; }
step() { printf "\n${c_b}### %s${c_0}\n" "$*"; }
info() { printf "    %s\n" "$*"; }
warn() { printf "${c_y}WARNING:${c_0} %s\n" "$*" >&2; }
die()  { printf "${c_r}ERROR:${c_0} %s\n" "$*" >&2; exit 1; }

# ask VAR "prompt" — prompts using the variable's current value as the default.
# A flag-provided value therefore becomes the default; Enter keeps it.
ask() {
    local __var=$1 __prompt=$2 __cur=${!1:-} __ans
    if [[ $INTERACTIVE -eq 0 ]]; then return; fi
    if [[ -n $__cur ]]; then
        read -r -p "$__prompt [$__cur]: " __ans || true
    else
        read -r -p "$__prompt: " __ans || true
    fi
    printf -v "$__var" '%s' "${__ans:-$__cur}"
}

# ask_secret VAR "prompt" — no echo; Enter keeps any current value.
ask_secret() {
    local __var=$1 __prompt=$2 __cur=${!1:-} __ans hint=""
    if [[ $INTERACTIVE -eq 0 ]]; then return; fi
    [[ -n $__cur ]] && hint=" (press Enter to keep current)"
    read -rs -p "$__prompt$hint: " __ans || true; echo
    [[ -n $__ans ]] && printf -v "$__var" '%s' "$__ans"
}

# ask_yn VAR "prompt" default(yes|no) — stores yes|no.
ask_yn() {
    local __var=$1 __prompt=$2 __def=${3:-no} __ans hint
    [[ $__def == yes ]] && hint="Y/n" || hint="y/N"
    if [[ $INTERACTIVE -eq 0 ]]; then
        __ans=${!1:-$__def}
    else
        read -r -p "$__prompt [$hint]: " __ans || true
        __ans=${__ans:-$__def}
    fi
    case "$__ans" in [Yy]*|yes) printf -v "$__var" '%s' yes;; *) printf -v "$__var" '%s' no;; esac
}

confirm() { # confirm "prompt" default(yes|no) -> returns 0 for yes
    local ans def=${2:-no} hint
    [[ $ASSUME_YES -eq 1 ]] && return 0
    [[ $INTERACTIVE -eq 0 ]] && { [[ $def == yes ]] && return 0 || return 1; }
    [[ $def == yes ]] && hint="Y/n" || hint="y/N"
    read -r -p "$1 [$hint]: " ans || true
    ans=${ans:-$def}
    case "$ans" in [Yy]*|yes) return 0;; *) return 1;; esac
}

# json_get KEY <<< json — pull a flat string field, same approach as install.sh.
json_get() { sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p" | head -1; }

need_cmd() { command -v "$1" >/dev/null 2>&1 || die "$1 is required but not installed"; }

# existing_val KEY — read a value already in operator.env (used as prompt default
# so a --reconfigure run preserves anything you don't change).
existing_val() { [[ -f $OPERATOR_ENV ]] && grep -E "^$1=" "$OPERATOR_ENV" 2>/dev/null | tail -1 | cut -d= -f2- || true; }

usage() {
cat <<'EOF'
ClowdOps private deployment — guided setup

USAGE
  sudo ./setup.sh [flags]

MODES
  --reconfigure            Change operator config on an installed box, then
                           `docker compose up -d`. Skips the installer.
  --dry-run                Print the operator.env and install command that would
                           be produced; write and run nothing.
  --non-interactive        Never prompt; take every value from flags/defaults.
  --yes                    Auto-confirm the final "Proceed?" summary.

ENROLMENT (install mode)
  --install-command='...'  Paste the whole one-liner from the portal; the token
                           and authority URL are parsed from it.
  --token=fbd_...          The one-time enrolment voucher (if not pasting above).
  --authority-url=URL      Enrolment authority. Default https://platform.clowdops.ai
                           For a child this is your master box's URL.
  --role=master|child|connected   Override the voucher's role (rarely needed).
  --hostname=HOST          Bring-your-own DNS name (else the auto hostname is used).
  --serve-mirror           Master only: also serve a container-registry mirror to
                           air-gapped children.
  --authority-ip=IP        Child only: pin the master's hostname to an internal IP
                           in /etc/hosts (when you have no internal DNS).
  --sandbox-images=SET     all | chat | none | comma list
                           (chat,document,general,aws,gcp,azure,ssh). Default: chat.

SIGN-IN (SSO)
  --sso=LIST               Comma list of providers to configure:
                           google,microsoft,github,oidc  (else you're asked).
  --google-client-id / --google-client-secret
  --ms-client-id / --ms-client-secret / --ms-tenant-id
  --github-client-id / --github-client-secret
  --oidc-issuer / --oidc-client-id / --oidc-client-secret
  --oidc-scopes / --oidc-display-name
  --password-login=true|false     Keep email+password sign-in. Default true.
                                  (false is refused on first install — see guide.)
  --open-registration=true|false  Allow self-service sign-up. Default false
                                  (invite-only, recommended for private boxes).

EMAIL (SMTP) — optional
  --smtp-host --smtp-port --smtp-user --smtp-password --smtp-secure=true|false --smtp-from

OFF-BOX BACKUPS (S3) — optional
  --backup-s3-access-key --backup-s3-secret-key --backup-s3-bucket --backup-s3-region

  -h, --help               This help.

Secrets passed as flags are visible in your shell history / process list — for a
one-off run, prefer the interactive prompts (they never echo secrets).
EOF
}

# =============================================================================
# Argument parsing
# =============================================================================
parse_args() {
    local a v
    for a in "$@"; do
        case "$a" in
            --install-command=*) INSTALL_COMMAND="${a#*=}" ;;
            --token=*)           TOKEN="${a#*=}" ;;
            --authority-url=*)   AUTHORITY_URL="${a#*=}" ;;
            --role=*)            ROLE="${a#*=}" ;;
            --hostname=*)        HOSTNAME_OVERRIDE="${a#*=}" ;;
            --serve-mirror)      SERVE_MIRROR=1 ;;
            --authority-ip=*)    AUTHORITY_IP="${a#*=}" ;;
            --sandbox-images=*)  SANDBOX_IMAGES="${a#*=}" ;;
            --sso=*)             SSO_LIST="${a#*=}" ;;
            --google-client-id=*)     GOOGLE_CLIENT_ID="${a#*=}" ;;
            --google-client-secret=*) GOOGLE_CLIENT_SECRET="${a#*=}" ;;
            --ms-client-id=*)         MICROSOFT_CLIENT_ID="${a#*=}" ;;
            --ms-client-secret=*)     MICROSOFT_CLIENT_SECRET="${a#*=}" ;;
            --ms-tenant-id=*)         MICROSOFT_TENANT_ID="${a#*=}" ;;
            --github-client-id=*)     GITHUB_CLIENT_ID="${a#*=}" ;;
            --github-client-secret=*) GITHUB_CLIENT_SECRET="${a#*=}" ;;
            --oidc-issuer=*)          OIDC_ISSUER_URL="${a#*=}" ;;
            --oidc-client-id=*)       OIDC_CLIENT_ID="${a#*=}" ;;
            --oidc-client-secret=*)   OIDC_CLIENT_SECRET="${a#*=}" ;;
            --oidc-scopes=*)          OIDC_SCOPES="${a#*=}" ;;
            --oidc-display-name=*)    OIDC_DISPLAY_NAME="${a#*=}" ;;
            --password-login=*)       PASSWORD_LOGIN="${a#*=}" ;;
            --open-registration=*)    OPEN_REGISTRATION="${a#*=}" ;;
            --smtp-host=*)     SMTP_HOST="${a#*=}" ;;
            --smtp-port=*)     SMTP_PORT="${a#*=}" ;;
            --smtp-user=*)     SMTP_USER="${a#*=}" ;;
            --smtp-password=*) SMTP_PASSWORD="${a#*=}" ;;
            --smtp-secure=*)   SMTP_SECURE="${a#*=}" ;;
            --smtp-from=*)     SMTP_FROM="${a#*=}" ;;
            --backup-s3-access-key=*) BACKUP_S3_ACCESS_KEY="${a#*=}" ;;
            --backup-s3-secret-key=*) BACKUP_S3_SECRET_KEY="${a#*=}" ;;
            --backup-s3-bucket=*)     BACKUP_S3_BUCKET="${a#*=}" ;;
            --backup-s3-region=*)     BACKUP_S3_REGION="${a#*=}" ;;
            --reconfigure)     MODE="reconfigure" ;;
            --dry-run)         MODE="dryrun" ;;
            --non-interactive) INTERACTIVE=0 ;;
            --yes|-y)          ASSUME_YES=1 ;;
            -h|--help)         usage; exit 0 ;;
            *) die "unknown argument: $a  (see --help)" ;;
        esac
    done

    # A pasted install command carries both the authority (the curl host) and token.
    if [[ -n $INSTALL_COMMAND ]]; then
        v="$(printf '%s' "$INSTALL_COMMAND" | grep -oE 'https?://[^/ ]+' | head -1 || true)"
        [[ -n $v ]] && AUTHORITY_URL="$v"
        v="$(printf '%s' "$INSTALL_COMMAND" | grep -oE -- '--token=[^ ]+' | head -1 | cut -d= -f2 || true)"
        [[ -n $v ]] && TOKEN="$v"
    fi
    AUTHORITY_URL="${AUTHORITY_URL%/}"

    # No TTY and not told to be non-interactive: fall back to non-interactive so
    # reads don't block or consume a piped script.
    [[ -t 0 ]] || INTERACTIVE=0
}

# =============================================================================
# Phase 0 — preflight & voucher lookup
# =============================================================================
preflight() {
    step "Preflight"
    need_cmd curl
    # --dry-run writes and runs nothing, so it needs neither root nor amd64 — it
    # can be previewed from a laptop. Enforce both only for real side-effect runs.
    if [[ $MODE != dryrun ]]; then
        [[ "${EUID:-$(id -u)}" -eq 0 ]] || die "run as root (use sudo) — this writes under /etc/clowd and drives Docker."
        local arch; arch="$(uname -m)"
        [[ "$arch" == "x86_64" || "$arch" == "amd64" ]] || die "linux/amd64 required (got $arch)."
        info "root OK, architecture $arch OK."
    fi

    if [[ $MODE == reconfigure ]]; then
        [[ -f "$APP_DIR/.env" ]] || die "no existing install at $APP_DIR — run without --reconfigure first."
        # Recover the live hostname so we can show correct SSO callback URLs.
        SITE_HOST="$(grep -E '^CLOWD_SITE_ADDRESS=' "$APP_DIR/.env" | tail -1 | cut -d= -f2 | sed 's/:80$//')"
        [[ -n $SITE_HOST ]] || SITE_HOST="<your-appliance-host>"
        info "reconfigure mode — installed box detected at $APP_DIR (host: $SITE_HOST)."
        return
    fi

    [[ -n $TOKEN ]] || {
        if [[ $INTERACTIVE -eq 1 ]]; then
            info "Paste the install command from the portal, or just the voucher."
            ask INSTALL_COMMAND "Install command (blank to enter the voucher directly)"
            if [[ -n $INSTALL_COMMAND ]]; then
                v="$(printf '%s' "$INSTALL_COMMAND" | grep -oE 'https?://[^/ ]+' | head -1 || true)"; [[ -n $v ]] && AUTHORITY_URL="${v%/}"
                v="$(printf '%s' "$INSTALL_COMMAND" | grep -oE -- '--token=[^ ]+' | head -1 | cut -d= -f2 || true)"; [[ -n $v ]] && TOKEN="$v"
            fi
            [[ -n $TOKEN ]] || ask TOKEN "Voucher (fbd_...)"
            [[ -n $TOKEN ]] || ask AUTHORITY_URL "Authority URL"
        fi
    }
    [[ -n $TOKEN ]] || die "a voucher is required (--token=... or paste --install-command=...)."
    AUTHORITY_URL="${AUTHORITY_URL%/}"
    log "authority: $AUTHORITY_URL"

    # Look up what the portal registered for this voucher (read-only; does not
    # consume it — the backend enrols on boot). Best-effort: on failure we fall
    # back to prompts/defaults so an operator on a flaky link can still proceed.
    local info_json
    if info_json="$(curl -fsSL "$AUTHORITY_URL/federation/enrollment-info?token=$TOKEN" 2>/dev/null)"; then
        VOUCHER_ROLE="$(printf '%s' "$info_json" | json_get role)"
        AUTO_HOST="$(printf '%s' "$info_json" | json_get hostname)"
        MASTER_AUTHORITY_URL="$(printf '%s' "$info_json" | json_get masterAuthorityUrl)"
        REGISTRY_URL="$(printf '%s' "$info_json" | json_get registryUrl)"
        info "voucher recognised (role: ${VOUCHER_ROLE:-unknown}${AUTO_HOST:+, hostname: $AUTO_HOST})."
    else
        warn "could not reach $AUTHORITY_URL/federation/enrollment-info — the voucher may be expired, or the authority unreachable. Continuing with your explicit choices."
    fi
}

# =============================================================================
# Phase 1 — role reconciliation (voucher decides; public IP sanity-checks)
# =============================================================================
resolve_role() {
    step "Deployment role"
    # Public-IP detection is a cross-check only, never the decision.
    PUBLIC_IP="$(curl -fsSL --max-time 8 https://api.ipify.org 2>/dev/null || true)"

    # Effective role: explicit flag > voucher > master-hint > default child.
    if [[ -z $ROLE ]]; then
        if [[ -n $VOUCHER_ROLE ]]; then ROLE="$VOUCHER_ROLE"
        elif [[ -n $MASTER_AUTHORITY_URL ]]; then ROLE="master"
        else ROLE=""; fi
    fi
    # Normalise: a box with a child-facing URL is a master; anything Central-facing
    # that isn't a child we treat as "connected" for messaging.
    [[ -n $MASTER_AUTHORITY_URL && $ROLE != child ]] && ROLE="master"

    if [[ -z $ROLE ]]; then
        info "The role is set when the box is registered in the portal; the voucher normally carries it."
        info "  connected — public box that enrols with Central (the usual choice)"
        info "  master    — connected box that also licenses your internal children"
        info "  child     — internal / air-gapped box that enrols with your master"
        ask ROLE "Role (connected|master|child)"
        [[ -n $ROLE ]] || ROLE="child"
    fi

    case "$ROLE" in master) info "Role: master (licenses children).";;
                     child)  info "Role: child (enrols with your master).";;
                     *)      info "Role: connected deployment.";; esac

    # Sanity checks against the detected public IP.
    # Sanity-check warnings stop an interactive operator to reconsider; a
    # non-interactive run trusts its explicit flags and only warns.
    if [[ $ROLE == child ]]; then
        if [[ -n $PUBLIC_IP ]]; then
            warn "This box has a public IP ($PUBLIC_IP) but is registered as a CHILD."
            info "Children are normally internal/air-gapped. If you meant a public 'connected' box, re-register it in the portal."
            [[ $INTERACTIVE -eq 1 ]] && { confirm "Continue as a child anyway?" no || die "Aborted — re-register the box with the intended role."; }
        fi
    else
        if [[ -z $PUBLIC_IP ]]; then
            warn "No public IP detected, but this box is registered as ${ROLE}."
            info "A ${ROLE} box must reach its authority and (for auto DNS + TLS) be publicly reachable on ports 80/443."
            [[ $INTERACTIVE -eq 1 ]] && { confirm "Continue anyway?" no || die "Aborted — check the box's networking, then re-run."; }
        fi
    fi

    # Air-gapped signal: the authority advertises a registry mirror, or a child
    # with no public IP. Drives the SSO branch (public IdPs won't be reachable).
    if [[ -n $REGISTRY_URL || ( $ROLE == child && -z $PUBLIC_IP ) ]]; then
        IS_AIRGAPPED=1
        [[ -n $REGISTRY_URL ]] && info "Air-gapped: images will be pulled from the master mirror ($REGISTRY_URL)."
    fi

    # Master extras.
    if [[ $ROLE == master ]]; then
        [[ -z $SERVE_MIRROR ]] && { local m=no; ask_yn m "Serve a container-registry mirror to air-gapped children?" no; [[ $m == yes ]] && SERVE_MIRROR=1; }
    fi
    # Child with no internal DNS may need to pin the master's host to an IP.
    if [[ $ROLE == child && -z $AUTHORITY_IP && $INTERACTIVE -eq 1 ]]; then
        info "If your child can't resolve the master's hostname via internal DNS, pin it to an IP (else leave blank)."
        ask AUTHORITY_IP "Master IP to pin (optional)"
    fi
    return 0
}

# =============================================================================
# Phase 2 — hostname / SSO callback base
# =============================================================================
resolve_hostname() {
    step "Hostname"
    if [[ -n $HOSTNAME_OVERRIDE ]]; then
        SITE_HOST="$HOSTNAME_OVERRIDE"
    elif [[ -n $AUTO_HOST ]]; then
        if [[ $INTERACTIVE -eq 1 ]]; then
            info "The portal allocated the auto hostname: $AUTO_HOST"
            local byo=no; ask_yn byo "Use a bring-your-own hostname instead?" no
            if [[ $byo == yes ]]; then ask HOSTNAME_OVERRIDE "Your hostname (DNS A record must already point here)"; SITE_HOST="$HOSTNAME_OVERRIDE"; else SITE_HOST="$AUTO_HOST"; fi
        else
            SITE_HOST="$AUTO_HOST"
        fi
    else
        # No auto hostname (child, or lookup failed). Bring-your-own required for TLS + SSO.
        [[ $ROLE == child ]] && info "Children are bring-your-own-hostname (resolved by your internal DNS)."
        ask HOSTNAME_OVERRIDE "Hostname for this box (blank = serve plain HTTP on the IP for now)"
        SITE_HOST="${HOSTNAME_OVERRIDE:-<your-appliance-host>}"
    fi

    if [[ -n $HOSTNAME_OVERRIDE ]]; then
        warn "Create a DNS A record for '$HOSTNAME_OVERRIDE' pointing at this box BEFORE bring-up, so the TLS certificate is issued on first boot."
    fi
    info "Sign-in callback URLs will use: https://$SITE_HOST"
}

# =============================================================================
# Phase 3 — sandbox images
# =============================================================================
resolve_sandbox_images() {
    step "Sandbox runtime images"
    [[ $MODE == reconfigure ]] && return
    if [[ -z $SANDBOX_IMAGES && $INTERACTIVE -eq 1 ]]; then
        info "The agent launches disposable per-session sandboxes. Pre-warming them makes agents work instantly; each is ~3.5 GB."
        info "  1) chat only          (smallest — good for a first bring-up)   [default]"
        info "  2) all                (chat document general aws gcp azure ssh)"
        info "  3) none               (pulled on first use instead)"
        info "  4) custom             (comma list)"
        local choice=1; ask choice "Choose 1-4"
        case "$choice" in
            2|all)  SANDBOX_IMAGES="all" ;;
            3|none) SANDBOX_IMAGES="none" ;;
            4|custom) ask SANDBOX_IMAGES "Comma list (chat,document,general,aws,gcp,azure,ssh)" ;;
            *) SANDBOX_IMAGES="chat" ;;
        esac
    fi
    [[ -n $SANDBOX_IMAGES ]] || SANDBOX_IMAGES="chat"
    [[ $SANDBOX_IMAGES == all ]] && SANDBOX_IMAGES="chat,document,general,aws,gcp,azure,ssh"
    info "Sandbox images: $SANDBOX_IMAGES"
}

# =============================================================================
# Phase 4 — SSO wizard
# =============================================================================
sso_callback() { printf 'https://%s/auth/%s/callback' "$SITE_HOST" "$1"; }

configure_google() {
    printf "\n  ${c_g}Google${c_0}\n"
    info "1. Google Cloud Console -> APIs & Services -> Credentials -> Create OAuth client ID (type: Web application)."
    info "2. Add this Authorised redirect URI:"
    info "     $(sso_callback google)"
    info "3. For company-only sign-in, set the OAuth consent screen to 'Internal'."
    ask        GOOGLE_CLIENT_ID     "   Google Client ID"
    ask_secret GOOGLE_CLIENT_SECRET "   Google Client Secret"
    return 0
}
configure_microsoft() {
    printf "\n  ${c_g}Microsoft (Entra ID)${c_0}\n"
    info "1. Entra admin center -> App registrations -> New registration."
    info "2. Add a Web platform Redirect URI:"
    info "     $(sso_callback microsoft)"
    info "3. Copy the Application (client) ID and Directory (tenant) ID; create a client secret."
    ask        MICROSOFT_CLIENT_ID     "   Microsoft Client ID"
    ask_secret MICROSOFT_CLIENT_SECRET "   Microsoft Client Secret"
    [[ -z $MICROSOFT_TENANT_ID ]] && MICROSOFT_TENANT_ID="common"
    info "Pin your tenant ID for 'only my company'. Leave 'common' only to accept ANY Microsoft account."
    ask        MICROSOFT_TENANT_ID     "   Microsoft Tenant ID"
    [[ $MICROSOFT_TENANT_ID == common ]] && warn "MICROSOFT_TENANT_ID=common accepts any Microsoft account worldwide."
    return 0
}
configure_github() {
    printf "\n  ${c_g}GitHub${c_0}\n"
    info "1. GitHub -> Settings -> Developer settings -> OAuth Apps -> New OAuth App (org-owned for org control)."
    info "2. Authorization callback URL:"
    info "     $(sso_callback github)"
    info "3. Generate a client secret."
    info "Note: GitHub matches users by their VERIFIED GitHub email."
    ask        GITHUB_CLIENT_ID     "   GitHub Client ID"
    ask_secret GITHUB_CLIENT_SECRET "   GitHub Client Secret"
    return 0
}
configure_oidc() {
    printf "\n  ${c_g}Generic OIDC${c_0} (Okta, Auth0, Entra, Keycloak, Ping, ...)\n"
    info "1. In your identity provider, create an OIDC / OpenID Connect web application."
    info "2. Set its redirect URI to:"
    info "     $(sso_callback oidc)"
    info "3. Note the ISSUER base URL (the provider's discovery root), e.g.:"
    info "     Okta     https://acme.okta.com"
    info "     Auth0    https://acme.eu.auth0.com"
    info "     Entra    https://login.microsoftonline.com/<tenant-id>/v2.0"
    info "     Keycloak https://id.acme.example/realms/<realm>"
    info "The box must be able to reach <issuer>/.well-known/openid-configuration."
    ask        OIDC_ISSUER_URL    "   OIDC Issuer URL"
    ask        OIDC_CLIENT_ID     "   OIDC Client ID"
    ask_secret OIDC_CLIENT_SECRET "   OIDC Client Secret"
    [[ -z $OIDC_SCOPES ]] && OIDC_SCOPES="openid profile email"
    ask        OIDC_SCOPES        "   OIDC scopes"
    ask        OIDC_DISPLAY_NAME  "   Button label (e.g. 'Acme SSO')"
    return 0
}

configure_sso() {
    step "Single sign-on (SSO)"
    if [[ $SITE_HOST == "<your-appliance-host>" ]]; then
        warn "No final hostname yet — SSO callbacks need your real HTTPS host. You can set SSO later with --reconfigure once the hostname/cert are live."
    fi
    if [[ $IS_AIRGAPPED -eq 1 ]]; then
        info "This box is air-gapped/internal. Public providers (Google/Microsoft/GitHub) need outbound internet the box doesn't have —"
        info "use a Generic OIDC provider reachable on your internal network (e.g. Keycloak)."
    fi

    # Seed prompt defaults from any existing operator.env so reconfigure preserves them.
    GOOGLE_CLIENT_ID="${GOOGLE_CLIENT_ID:-$(existing_val GOOGLE_CLIENT_ID)}"
    MICROSOFT_CLIENT_ID="${MICROSOFT_CLIENT_ID:-$(existing_val MICROSOFT_CLIENT_ID)}"
    MICROSOFT_TENANT_ID="${MICROSOFT_TENANT_ID:-$(existing_val MICROSOFT_TENANT_ID)}"
    GITHUB_CLIENT_ID="${GITHUB_CLIENT_ID:-$(existing_val GITHUB_CLIENT_ID)}"
    OIDC_ISSUER_URL="${OIDC_ISSUER_URL:-$(existing_val OIDC_ISSUER_URL)}"
    OIDC_CLIENT_ID="${OIDC_CLIENT_ID:-$(existing_val OIDC_CLIENT_ID)}"
    OIDC_DISPLAY_NAME="${OIDC_DISPLAY_NAME:-$(existing_val OIDC_DISPLAY_NAME)}"

    local want_google=0 want_ms=0 want_gh=0 want_oidc=0

    if [[ -n $SSO_LIST ]]; then
        case ",$SSO_LIST," in *,google,*) want_google=1;; esac
        case ",$SSO_LIST," in *,microsoft,*) want_ms=1;; esac
        case ",$SSO_LIST," in *,github,*) want_gh=1;; esac
        case ",$SSO_LIST," in *,oidc,*) want_oidc=1;; esac
    elif [[ $INTERACTIVE -eq 1 ]]; then
        local yn
        if [[ $IS_AIRGAPPED -eq 1 ]]; then
            yn=no; ask_yn yn "Configure a Generic OIDC provider?" yes; [[ $yn == yes ]] && want_oidc=1
        else
            yn=no; ask_yn yn "Configure Generic OIDC (Okta/Auth0/Entra/Keycloak)?" no; [[ $yn == yes ]] && want_oidc=1
            yn=no; ask_yn yn "Configure Google sign-in?"    no; [[ $yn == yes ]] && want_google=1
            yn=no; ask_yn yn "Configure Microsoft sign-in?" no; [[ $yn == yes ]] && want_ms=1
            yn=no; ask_yn yn "Configure GitHub sign-in?"    no; [[ $yn == yes ]] && want_gh=1
        fi
    else
        # Non-interactive: infer intent from whichever credentials/flags were passed.
        [[ -n $GOOGLE_CLIENT_ID ]]    && want_google=1
        [[ -n $MICROSOFT_CLIENT_ID ]] && want_ms=1
        [[ -n $GITHUB_CLIENT_ID ]]    && want_gh=1
        [[ -n $OIDC_ISSUER_URL ]]     && want_oidc=1
    fi

    [[ $want_oidc   -eq 1 ]] && configure_oidc
    [[ $want_google -eq 1 ]] && { [[ $IS_AIRGAPPED -eq 1 ]] && warn "Google won't work on an air-gapped box (no outbound)."; configure_google; }
    [[ $want_ms     -eq 1 ]] && { [[ $IS_AIRGAPPED -eq 1 ]] && warn "Microsoft won't work on an air-gapped box (no outbound)."; configure_microsoft; }
    [[ $want_gh     -eq 1 ]] && { [[ $IS_AIRGAPPED -eq 1 ]] && warn "GitHub won't work on an air-gapped box (no outbound)."; configure_github; }

    # Clear any half-filled provider (id without secret) so we don't write a broken button.
    [[ -z $GOOGLE_CLIENT_ID    ]] && GOOGLE_CLIENT_SECRET=""
    [[ -z $MICROSOFT_CLIENT_ID ]] && MICROSOFT_CLIENT_SECRET=""
    [[ -z $GITHUB_CLIENT_ID    ]] && GITHUB_CLIENT_SECRET=""
    [[ -z $OIDC_ISSUER_URL     ]] && { OIDC_CLIENT_ID=""; OIDC_CLIENT_SECRET=""; }

    if [[ -z $GOOGLE_CLIENT_ID$MICROSOFT_CLIENT_ID$GITHUB_CLIENT_ID$OIDC_ISSUER_URL ]]; then
        info "No SSO configured — sign-in will be email + password."
    fi
    return 0
}

# =============================================================================
# Phase 5 — login policy
# =============================================================================
configure_login_policy() {
    step "Login policy"
    local has_sso=0
    [[ -n $GOOGLE_CLIENT_ID$MICROSOFT_CLIENT_ID$GITHUB_CLIENT_ID$OIDC_ISSUER_URL ]] && has_sso=1

    # OPEN_REGISTRATION: default to invite-only for private deployments.
    if [[ -z $OPEN_REGISTRATION ]]; then
        local cur; cur="$(existing_val OPEN_REGISTRATION)"
        local ans=no
        info "Invite-only refuses unknown SSO users — recommended for a private box."
        ask_yn ans "Allow self-service registration (open sign-up)?" "$([[ $cur == true ]] && echo yes || echo no)"
        [[ $ans == yes ]] && OPEN_REGISTRATION="true" || OPEN_REGISTRATION="false"
    fi
    info "Open registration: $OPEN_REGISTRATION"

    # PASSWORD_LOGIN: never allow disabling it on a first install (lock-out risk).
    # A dry-run previews an install, so it uses the same install semantics.
    if [[ $MODE != reconfigure ]]; then
        if [[ ${PASSWORD_LOGIN:-true} == false ]]; then
            warn "PASSWORD_LOGIN=false is refused on first install — verify SSO end-to-end first, then re-run with --reconfigure."
        fi
        PASSWORD_LOGIN="true"
    else
        # reconfigure: allow SSO-only, with a guard.
        if [[ -z $PASSWORD_LOGIN ]]; then
            local cur; cur="$(existing_val PASSWORD_LOGIN)"
            local ans=yes
            ask_yn ans "Keep email + password sign-in enabled?" "$([[ $cur == false ]] && echo no || echo yes)"
            [[ $ans == yes ]] && PASSWORD_LOGIN="true" || PASSWORD_LOGIN="false"
        fi
        if [[ $PASSWORD_LOGIN == false ]]; then
            [[ $has_sso -eq 1 ]] || die "Refusing PASSWORD_LOGIN=false with no SSO configured — that locks everyone out."
            warn "Forcing SSO-only sign-in. Confirm at least one SSO provider works AND an admin can sign in through it."
            info "Recovery if locked out: remove PASSWORD_LOGIN from $OPERATOR_ENV and run 'docker compose up -d'."
            confirm "Disable password sign-in now?" no || PASSWORD_LOGIN="true"
        fi
    fi
    info "Password login: $PASSWORD_LOGIN"
}

# =============================================================================
# Phase 6 — SMTP + S3 (optional)
# =============================================================================
configure_smtp() {
    step "Email (SMTP) — optional"
    SMTP_HOST="${SMTP_HOST:-$(existing_val SMTP_HOST)}"
    if [[ -z $SMTP_HOST && $INTERACTIVE -eq 1 ]]; then
        local yn=no; ask_yn yn "Configure SMTP now (needed for invites & password-reset emails)?" no
        [[ $yn == yes ]] || { info "SMTP off — you'll provision users by other means."; return 0; }
    fi
    [[ -n $SMTP_HOST || $INTERACTIVE -eq 1 ]] || return 0
    ask        SMTP_HOST     "   SMTP host"
    [[ -n $SMTP_HOST ]] || { info "SMTP off."; return 0; }
    [[ -z $SMTP_PORT ]] && SMTP_PORT="587"
    ask        SMTP_PORT     "   SMTP port"
    ask        SMTP_USER     "   SMTP username"
    ask_secret SMTP_PASSWORD "   SMTP password"
    [[ -z $SMTP_SECURE ]] && SMTP_SECURE="true"
    ask        SMTP_SECURE   "   Use TLS (true/false)"
    [[ -z $SMTP_FROM ]] && SMTP_FROM="$SMTP_USER"
    ask        SMTP_FROM     "   From address"
}
configure_backups() {
    step "Off-box backups (S3) — optional"
    BACKUP_S3_BUCKET="${BACKUP_S3_BUCKET:-$(existing_val BACKUP_S3_BUCKET)}"
    if [[ -z $BACKUP_S3_BUCKET && $INTERACTIVE -eq 1 ]]; then
        local yn=no; ask_yn yn "Configure nightly DB backups to an S3-compatible bucket?" no
        [[ $yn == yes ]] || { info "No off-box backups — snapshot the host yourself."; return 0; }
    fi
    [[ -n $BACKUP_S3_BUCKET || $INTERACTIVE -eq 1 ]] || return 0
    ask        BACKUP_S3_BUCKET     "   S3 bucket"
    [[ -n $BACKUP_S3_BUCKET ]] || { info "No off-box backups."; return 0; }
    ask        BACKUP_S3_REGION     "   S3 region"
    ask        BACKUP_S3_ACCESS_KEY "   S3 access key"
    ask_secret BACKUP_S3_SECRET_KEY "   S3 secret key"
}

# =============================================================================
# Phase 7 — write operator.env
# =============================================================================
render_operator_env() {
    # Emits the full operator.env to stdout (used for both write and dry-run).
    echo "# Optional operator values — generated by setup.sh v$SETUP_VERSION."
    echo "# Sign-in providers, mail, backups, login policy. Safe to hand-edit."
    echo "# Apply changes with:  cd $APP_DIR && docker compose up -d"
    echo
    if [[ -n $GOOGLE_CLIENT_ID ]]; then
        echo "GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID"
        echo "GOOGLE_CLIENT_SECRET=$GOOGLE_CLIENT_SECRET"
        echo
    fi
    if [[ -n $MICROSOFT_CLIENT_ID ]]; then
        echo "MICROSOFT_CLIENT_ID=$MICROSOFT_CLIENT_ID"
        echo "MICROSOFT_CLIENT_SECRET=$MICROSOFT_CLIENT_SECRET"
        echo "MICROSOFT_TENANT_ID=${MICROSOFT_TENANT_ID:-common}"
        echo
    fi
    if [[ -n $GITHUB_CLIENT_ID ]]; then
        echo "GITHUB_CLIENT_ID=$GITHUB_CLIENT_ID"
        echo "GITHUB_CLIENT_SECRET=$GITHUB_CLIENT_SECRET"
        echo
    fi
    if [[ -n $OIDC_ISSUER_URL ]]; then
        echo "OIDC_ISSUER_URL=$OIDC_ISSUER_URL"
        echo "OIDC_CLIENT_ID=$OIDC_CLIENT_ID"
        echo "OIDC_CLIENT_SECRET=$OIDC_CLIENT_SECRET"
        [[ -n $OIDC_SCOPES && $OIDC_SCOPES != "openid profile email" ]] && echo "OIDC_SCOPES=$OIDC_SCOPES"
        [[ -n $OIDC_DISPLAY_NAME ]] && echo "OIDC_DISPLAY_NAME=$OIDC_DISPLAY_NAME"
        echo
    fi
    echo "# Login policy"
    echo "PASSWORD_LOGIN=${PASSWORD_LOGIN:-true}"
    echo "OPEN_REGISTRATION=${OPEN_REGISTRATION:-false}"
    echo
    if [[ -n $SMTP_HOST ]]; then
        echo "# Email (SMTP)"
        echo "SMTP_HOST=$SMTP_HOST"
        echo "SMTP_PORT=${SMTP_PORT:-587}"
        echo "SMTP_USER=$SMTP_USER"
        echo "SMTP_PASSWORD=$SMTP_PASSWORD"
        echo "SMTP_SECURE=${SMTP_SECURE:-true}"
        echo "SMTP_FROM=${SMTP_FROM:-$SMTP_USER}"
        echo
    fi
    if [[ -n $BACKUP_S3_BUCKET ]]; then
        echo "# Off-box backups (S3)"
        echo "BACKUP_S3_ACCESS_KEY=$BACKUP_S3_ACCESS_KEY"
        echo "BACKUP_S3_SECRET_KEY=$BACKUP_S3_SECRET_KEY"
        echo "BACKUP_S3_BUCKET=$BACKUP_S3_BUCKET"
        echo "BACKUP_S3_REGION=$BACKUP_S3_REGION"
        echo
    fi
}

write_operator_env() {
    mkdir -p "$(dirname "$OPERATOR_ENV")"
    chmod 700 "$(dirname "$OPERATOR_ENV")" 2>/dev/null || true
    if [[ -f $OPERATOR_ENV ]]; then
        local bak
        bak="$OPERATOR_ENV.bak.$(date -u +%Y%m%dT%H%M%SZ)"
        cp -a "$OPERATOR_ENV" "$bak"
        info "backed up existing operator.env -> $bak"
    fi
    umask 077
    render_operator_env > "$OPERATOR_ENV"
    chmod 600 "$OPERATOR_ENV"
    log "wrote $OPERATOR_ENV"
}

# =============================================================================
# Summary + confirmation
# =============================================================================
print_summary() {
    step "Summary"
    local providers=""
    [[ -n $GOOGLE_CLIENT_ID ]]    && providers+="google "
    [[ -n $MICROSOFT_CLIENT_ID ]] && providers+="microsoft "
    [[ -n $GITHUB_CLIENT_ID ]]    && providers+="github "
    [[ -n $OIDC_ISSUER_URL ]]     && providers+="oidc "
    [[ -z $providers ]] && providers="(none — email+password)"
    printf "    %-22s %s\n" "Mode:"            "$MODE"
    [[ $MODE != reconfigure ]] && {
    printf "    %-22s %s\n" "Authority:"       "$AUTHORITY_URL"
    printf "    %-22s %s\n" "Role:"            "$ROLE${SERVE_MIRROR:+ (+registry mirror)}"
    printf "    %-22s %s\n" "Sandbox images:"  "$SANDBOX_IMAGES"; }
    printf "    %-22s %s\n" "Hostname:"        "$SITE_HOST"
    printf "    %-22s %s\n" "SSO providers:"   "$providers"
    printf "    %-22s %s\n" "Password login:"  "${PASSWORD_LOGIN:-true}"
    printf "    %-22s %s\n" "Open registration:" "${OPEN_REGISTRATION:-false}"
    printf "    %-22s %s\n" "SMTP:"            "$([[ -n $SMTP_HOST ]] && echo "$SMTP_HOST" || echo off)"
    printf "    %-22s %s\n" "S3 backups:"      "$([[ -n $BACKUP_S3_BUCKET ]] && echo "$BACKUP_S3_BUCKET" || echo off)"
    echo
}

# =============================================================================
# Phase 8 — run the Central installer
# =============================================================================
build_installer_args() {
    INSTALLER_ARGS=(--token="$TOKEN")
    [[ -n $HOSTNAME_OVERRIDE ]] && INSTALLER_ARGS+=(--hostname="$HOSTNAME_OVERRIDE")
    [[ -n $ROLE ]]              && INSTALLER_ARGS+=(--role="$ROLE")
    [[ -n $SERVE_MIRROR ]]      && INSTALLER_ARGS+=(--serve-mirror)
    [[ -n $AUTHORITY_IP ]]      && INSTALLER_ARGS+=(--authority-ip="$AUTHORITY_IP")
    [[ -n $SANDBOX_IMAGES ]]    && INSTALLER_ARGS+=(--sandbox-images="$SANDBOX_IMAGES")
}

run_installer() {
    step "Installing (via the Central installer)"
    build_installer_args
    log "curl -fsSL $AUTHORITY_URL/install.sh | bash -s -- ${INSTALLER_ARGS[*]}"
    curl -fsSL "$AUTHORITY_URL/install.sh" | bash -s -- "${INSTALLER_ARGS[@]}"
}

# =============================================================================
# Phase 9 — verify + next steps
# =============================================================================
apply_reconfigure() {
    step "Applying configuration"
    ( cd "$APP_DIR" && docker compose up -d )
    log "applied — the sign-in page reflects the new configuration within a few seconds."
}

verify_and_finish() {
    step "Verify"
    if command -v docker >/dev/null 2>&1; then
        info "Enrolment / heartbeat (backend logs):"
        docker logs clowd-backend-server 2>&1 | grep -i federation | tail -5 || info "(no federation lines yet — give it a minute)"
    fi
    if [[ $SITE_HOST != "<your-appliance-host>" ]]; then
        info "Advertised sign-in providers:"
        if command -v jq >/dev/null 2>&1; then
            curl -s "https://$SITE_HOST/api/public-config" 2>/dev/null | jq -r '.authProviders' 2>/dev/null || info "(couldn't read yet — TLS may still be provisioning)"
        else
            info "  curl -s https://$SITE_HOST/api/public-config | jq .authProviders"
        fi
    fi

    step "Next steps"
    cat <<EOF
    1. Watch the Deployments page: the row flips registered -> enrolled -> active.

    2. Claim the founding admin. If the portal shows a set-password link, use it.
       Otherwise create it on the box:
         cd $APP_DIR
         docker compose --profile bootstrap run --rm admin-init \\
             --email you@example.com --first-name You --last-name Admin
       Log in and rotate the printed password immediately.

    3. BACK UP OFF-BOX NOW (irreplaceable):
         $SECRETS_DIR/keys         (master encryption key)
         $SECRETS_DIR/federation   (deployment keypair + signed licence)
         the caddy-data Docker volume (TLS certificates)

    4. Verify SSO end-to-end before disabling password login. To go SSO-only later:
         sudo ./setup.sh --reconfigure
EOF
    log "Done. Reach the box at: https://$SITE_HOST"
}

# =============================================================================
# Main
# =============================================================================
main() {
    parse_args "$@"
    printf "${c_b}ClowdOps private deployment — guided setup v%s${c_0}\n" "$SETUP_VERSION"

    preflight

    if [[ $MODE == reconfigure ]]; then
        configure_sso
        configure_login_policy
        configure_smtp
        configure_backups
        print_summary
        confirm "Write this configuration and apply it?" yes || die "Aborted — nothing changed."
        write_operator_env
        apply_reconfigure
        [[ $SITE_HOST != "<your-appliance-host>" ]] && info "Check the buttons at: https://$SITE_HOST"
        exit 0
    fi

    resolve_role
    resolve_hostname
    resolve_sandbox_images
    configure_sso
    configure_login_policy
    configure_smtp
    configure_backups
    print_summary

    if [[ $MODE == dryrun ]]; then
        step "Dry run — operator.env that would be written to $OPERATOR_ENV"
        render_operator_env
        step "Dry run — install command that would run"
        build_installer_args
        echo "    curl -fsSL $AUTHORITY_URL/install.sh | bash -s -- ${INSTALLER_ARGS[*]}"
        echo
        log "Dry run complete — nothing was written or executed."
        exit 0
    fi

    confirm "Proceed with install?" yes || die "Aborted — nothing was written or executed."
    write_operator_env      # pre-seed BEFORE bring-up so SSO is live on first boot
    run_installer
    verify_and_finish
}

main "$@"
