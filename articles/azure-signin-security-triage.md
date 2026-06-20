---
title: "Five consoles, one answer: I let an AI agent triage my Azure sign-in alerts"
subtitle: "Brute-force, MFA rejections, a hybrid-identity gotcha — pulled from three different Azure log sources and handed back as one ranked list, in plain English."
tags: [Security, SecOps, Azure, Entra ID, Identity, AI Agents, ClowdOps, Incident Triage]
audience: LinkedIn / Medium / company blog
status: draft
source_session: redacted
anonymized: true
---

# Five consoles, one answer: I let an AI agent triage my Azure sign-in alerts

Ask any SecOps engineer what the job actually feels like and you'll hear some version of
the same thing: *it's not the analysis, it's the tab-switching.* Sign-in logs in one blade,
Identity Protection in another, the subscription activity log somewhere else, and the
on-prem AD that feeds half of it living in a different console entirely. The signal is
there — it's just smeared across five tools, none of which rank anything for you.

So I tried the lazy version. I gave a **ClowdOps** agent a read-only credential and one
sentence:

> **Me:** Check the Azure tenant for suspicious logins or accesses. Don't be too
> exhaustive — just do a pass to find evident problems in the last 7 days.

What came back wasn't a log dump. It was a **triage**.

---

## It read every source, then ranked what mattered

Under the hood the agent didn't look in one place. It pulled from three, in a single pass:

- **Azure Monitor** — the subscription activity log (was anyone changing resources?).
- **Microsoft Graph** — the Entra ID sign-in logs, filtered to failures and risk.
- **Graph Identity Protection** — the risky-users feed.

Then it correlated them and gave me a ranked list — worst first.

### 🔴 Critical — an active password-spray, and one account already locked

> The subnet `203.0.113.0/24` (a hosting provider in the Netherlands) is actively
> attacking the tenant.
> - **`e.ruiz@acme.com`** was hit repeatedly and is now locked out — *Error 50053:
>   account locked due to too many incorrect sign-in attempts.*
> - **`j.perez@acme.com`** got invalid-password attempts (*Error 50126*) from the same
>   subnet.
> - **Zero successful logins** from these IPs — the attack didn't get past the password
>   phase.

That last line is the one a raw log won't hand you. The agent checked whether any of the
malicious IPs *ever* succeeded, and told me they didn't — turning "we're under attack" into
"we're under attack and it's being held."

### 🟠 High — MFA doing its job, loudly

> A few users are failing MFA prompts — which can mean a password was guessed, but
> Conditional Access is stopping the attacker:
> - **`j.soto@acme.com`** — hard MFA failure (*500121*) from `198.51.100.192`.
> - **`c.alonso@acme.com`**, **`r.prieto@acme.com`** — Conditional Access "strong
>   authentication required" blocks (*50074*).

### 🟡 Watch — one odd IPv6 attempt

> - **`m.vidal@acme.com`** — invalid sign-in (*50126*) from the IPv6 address
>   `2001:db8:47:1016::159e`. Worth a glance, not an alarm.

### ✅ And what was clean

> Subscription / admin activity logs: nothing. No resource tampering, no privilege
> changes — the noise was all at the identity edge.

Then it closed with **actions, ranked**: reset and notify `e.ruiz` first, verify `j.soto`
and `j.perez` weren't just travelling, and — if you don't do business in the Netherlands —
drop a Conditional Access policy blocking `203.0.113.0/24`.

One prompt. Three data sources. A page I could act on without opening a single blade.

---

## The follow-up is where it earned its keep

The locked account worried me for a specific reason, so I asked:

> **Me:** Confirm `e.ruiz@acme.com` is actually locked. This tenant is connected to a local
> domain controller via AD Connect — I'm afraid the on-prem controller may "re-activate"
> the Entra account based on the domain status.

This is the kind of hybrid-identity question that usually means a call to whoever owns the
on-prem AD. The agent just went and checked — user profile, sync status, and the account's
own recent sign-ins — and explained the mechanism:

> - **Entra status:** the account is natively **Enabled** (`accountEnabled: true`), and yes
>   — it's actively syncing from your on-prem domain (`acme.local`).
> - **The actual "lock":** the `50053` is **Smart Lockout** — a *cloud-side* protection
>   that throttles auth when it sees a barrage of bad passwords. It **does not touch the
>   `accountEnabled` flag.**
> - **So AD Connect won't fight it.** Smart Lockout lives above the directory state your
>   on-prem controller syncs, so the next sync won't "undo" the protection.

And it caught the nuance that actually matters operationally:

> If you ever want to *hard-disable* this account, do it in **on-prem AD** — disabling it in
> the Azure portal gets reverted on the next AD Connect sync (~30 min), because on-prem is
> the source of truth. Also worth noting: `e.ruiz` had **legitimate** logins from a Spanish
> IP earlier in the day; the brute-force and lockout came from the Dutch IP at 20:00. Smart
> Lockout is IP-aware, so the user may still be able to sign in from their known location.

That's not log parsing. That's a junior analyst's afternoon of cross-referencing, returned
in two sentences — including the one trap (portal-disable getting reverted by sync) that
bites people in hybrid setups.

---

## Why this is the SecOps use case

The agent didn't find anything a skilled engineer *couldn't* have found. It found it
**across tools, correlated, and ranked — in one place, in plain language** — which is
exactly the part that doesn't scale when you're staring at five consoles at 9pm.

- It **read sources you'd normally open separately** (sign-in logs, Identity Protection,
  activity logs) and merged them.
- It **prioritized** — critical vs. high vs. watch vs. clean — instead of handing back rows.
- It **reasoned about hybrid identity**, not just the cloud half.
- It **ended on actions**, ordered by urgency, against a read-only credential — it told me
  what to do, and changed nothing itself.

A dashboard shows you everything. An engineer wants the three things that matter, in order.

---

## Try it on your own tenant

Point it at a read-only credential and ask the tired-Friday version of the question:

> *"Anything sketchy in our sign-ins this week? Don't be exhaustive — just the evident
> problems, ranked, with what I should do first."*

**ClowdOps** reads across your security sources and hands back the short, ranked list — so
the triage is done before you've finished opening the tabs. → [clowdops.ai](https://clowdops.ai)

---

*Based on a real agent session. Email addresses, display names, domains, and IP addresses
have been anonymized; the Azure error codes, the agent's reasoning, and the triage flow are
from the real run.*
