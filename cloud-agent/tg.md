[← ClowdOps](README.md) · [← Notifications](notifications.md) · [External agents (MCP) →](mcp.md)

# Telegram

**On this page:** [What this is](#what-this-is) · [Outbound — agent → Telegram](#outbound--agent--telegram) · [Inbound — Telegram → agent](#inbound--telegram--agent) · [Create the bot](#1-create-the-bot) · [Link a chat](#2-link-a-chat) · [Driving the agent](#driving-the-agent) · [Confirmations & guardrails](#confirmations--guardrails) · [Where Telegram chats appear](#where-telegram-chats-appear) · [Security notes](#security-notes)

ClowdOps integrates with **Telegram** in two complementary directions. Outbound, a Telegram chat is just another notification channel — the agent posts findings and digests to it like Slack or Teams. Inbound, a Telegram chat becomes a **control surface**: you message the bot and it drives your sandbox's agent, the same way [external coding agents drive it over MCP](mcp.md) — same credentials, same guardrails, same budget.

| Direction | What it does | Built on |
| --- | --- | --- |
| **Outbound** | The agent posts messages to a Telegram chat (findings, schedule digests, platform alerts) | A `TELEGRAM` [notification channel](notifications.md) |
| **Inbound** | You drive the sandbox's agent by messaging the bot — prompts, approvals, answers | A per-chat **link** to a sandbox |

Both use a single **Telegram bot** credential. One bot serves a whole project; each chat is linked to a specific sandbox.

## What this is

You create one Telegram **bot** (via Telegram's @BotFather) and add it to ClowdOps as a notification credential — the bot token is encrypted at rest and **never enters the sandbox or leaves the server**. From there:

- **Outbound** works immediately: attach the channel to a sandbox and the agent can post to your chat.
- **Inbound** is opt-in per sandbox: you enable it, generate a one-time code, and send `/link <code>` to the bot from the chat you want to connect. After that, messages in that chat drive the agent.

> [!NOTE]
> **One bot per project, one chat per sandbox.** The bot credential lives at the project level (so two projects stay isolated). Linking a Telegram chat binds it to a single sandbox — the analog of an MCP token's one-token-one-sandbox rule.

---

## Outbound — agent → Telegram

A Telegram channel is a notification credential like any other. Once attached to a sandbox, the agent can post to it:

- **In-chat `notify`** — *"post a Slack-style summary to Telegram when you're done."*
- **Schedule digests** — a Telegram channel set on a schedule receives an end-of-run summary.
- **Platform notifications** — route org-level budget / guardrail-denial / run-failure events to a Telegram chat.

Everything in [Notifications](notifications.md) applies unchanged — Telegram is simply another provider in the **Notifications** tab. See [Create the bot](#1-create-the-bot) for the token + chat-id setup.

---

## Inbound — Telegram → agent

Inbound turns a Telegram chat into a remote for your agent. You message the bot in plain language; it plans and executes against your cloud and replies in the chat. Guarded actions pause for an **Allow / Deny** tap right in Telegram, and clarifying questions are answered with buttons or a reply.

### 1. Create the bot

1. In Telegram, open **@BotFather** → `/newbot` → follow the prompts → copy the **bot token** (`123456789:AAE…`).
2. **Connect the bot to the destination chat, then read its chat ID.** A bot can't post anywhere until it's a participant. (BotFather gave you a `t.me/<botusername>` link and the bot's `@username` — tap the link, or search the `@username` in Telegram, to open/add the bot.)
   - **Direct message:** open the bot and tap **Start**.
   - **Group:** add the bot as a member (and, so it can see messages, either mention it once or disable its privacy mode via @BotFather → `/setprivacy`).
   - **Channel:** add the bot as an admin with **Post messages** permission.
   In ClowdOps you don't hunt for the chat ID: paste the bot token, click the **Open @yourbot** link it shows, press **Start**, and the chat appears automatically. See [Notification channel setup → Telegram](credentials/notify.md#telegram) for the full walkthrough.
3. In ClowdOps, open **Project → Credentials → Notifications → Add notification channel**, choose **Telegram**, and fill in:

| Field | Value |
| --- | --- |
| **Bot Token** | The token from @BotFather. Encrypted at rest; never injected into the sandbox. |
| **Chat ID** | The default outbound destination — auto-detected after you open the bot (step 2), or entered manually. **Optional**: leave blank for inbound-only, since inbound replies go to whoever messages the bot. |
| **Topic / Thread ID** | *(optional)* For forum-style groups, the topic to post into. |

4. Open the sandbox → **Credentials → Notifications** and **associate** the Telegram credential with it. (Outbound is now live; inbound needs the steps below.)

> [!NOTE]
> Inbound requires the bot credential to be attached to the sandbox first — that's how the engine reaches the bot to set up the webhook and reply.

### 2. Link a chat

On the sandbox's **Credentials → Notifications** tab, the **Telegram inbound control** card drives enrolment:

1. **Enable inbound** — registers the bot's webhook with Telegram so it can receive messages.
2. **Generate link code** — produces a single-use code (shown once, expires in ~15 minutes).
3. In Telegram, send `/link <code>` to the bot **from the chat you want to connect**. The bot replies *"✅ Linked"* and that chat is now bound to this sandbox.

The card also lists active linked chats and lets you **revoke** any of them — a revoked chat stops driving the agent immediately.

> [!TIP]
> You never paste a token or secret into Telegram. The `/link` code is a throwaway handle; the binding that authorises the chat is created server-side and is revocable from this card.

### Driving the agent

Once linked, just message the bot:

- **Send a prompt** — *"list S3 buckets in prod and flag any with public access."* The bot streams a short "working…" note and replies with the result.
- **Continue the conversation** — messages reuse the same session, so context carries across turns.
- **`/new`** — start a fresh session (clears the running conversation).
- **`/help`** — show the available commands.

In a **group chat**, only the user who linked the chat can drive the agent and approve actions — other members' messages and taps are ignored.

---

## Confirmations & guardrails

Telegram changes *how you reach* the agent, not *what it's allowed to do*. Every guardrail still applies:

- Mutating actions (run command on host, modify IAM, delete data, …) are gated by the same **action-category permissions** at org → project → sandbox.
- When the agent reaches for a guarded action, the turn **pauses** and the bot posts the pending action (tool, args preview, category, why) with **✅ Allow / 🚫 Deny** buttons. Nothing runs until you tap — there is no auto-approve.
- **Clarifying questions** appear as option buttons; free-text questions are answered by replying with your message.
- Credential scope and **USD budgets** are unchanged, and a per-chat rate limit smooths bursts.

See [Guardrails & cost caps](guardrails.md) for the full permission and budget model.

---

## Where Telegram chats appear

Sessions started from Telegram are first-class chats. They show up in the sandbox's **Chats** tab with a **Telegram** badge in the **Source** column — alongside **Chat**, **Scheduled**, and **MCP** runs — with the same status, token, and cost columns and the same Debug trace. Every inbound turn is attributed to the user who linked the chat, for audit and billing.

See [Chats & History](chats.md) for the audit view.

---

## Security notes

- **Bot token never leaves the server.** It is encrypted at rest and read only by the engine to talk to Telegram; it is never injected into the sandbox or shown in chat. The backend on its own cannot decrypt it.
- **Inbound is opt-in and bound.** A chat drives a sandbox only after an authenticated user enables inbound and the chat is linked with a single-use code. Unlinked chats get a "not linked" reply and reach nothing.
- **Per-project isolation.** One bot per project; a chat is bound to one sandbox — the same isolation model as a per-sandbox MCP token.
- **Instant revocation.** Revoking a binding (or disabling inbound) stops that chat immediately.
- **Guardrails enforced.** Destructive actions require an Allow tap; action-category grants, confirmations, and budgets are the same as the web app.
- **Group safety.** In a shared chat, only the linking user can drive or approve.
