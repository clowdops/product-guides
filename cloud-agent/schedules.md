[← ClowdOps](README.md) · [← Chat](chat.md) · [Chats & history →](chats.md)

# Scheduled Runs

**On this page:** [What a schedule is](#what-a-schedule-is) · [Creating a schedule](#creating-a-schedule) · [Allowed actions](#allowed-actions) · [Managing schedules](#managing-schedules) · [Viewing scheduled run output](#viewing-scheduled-run-output) · [Failure handling](#failure-handling) · [Post-run digest](#step-6-post-run-digest)

Scheduled runs execute a prompt automatically on a recurring cron schedule. They are useful for regular audits, daily reports, or any repeating task you would otherwise trigger manually.

Open the **Schedules** tab inside any sandbox to manage schedules.

## What a schedule is

A schedule is a saved prompt that fires on a cron cadence. Each firing creates an **unattended chat session** — same capabilities, same audit trail as an interactive chat, with two differences:

- There is no human to answer questions, so the agent cannot ask clarifying questions.
- There is no human to approve confirmations, so any action that would normally prompt for confirmation is **denied** unless its category is explicitly pre-approved on the schedule.

## Creating a schedule

<!-- Screenshot: ![Create schedule form — prompt, cron builder, allowed categories](./images/cloud-agent-schedules-create-form.png) -->

Click **New schedule** to open the editor.

### Step 1: Name and prompt

- **Name** — a short display label (for example `Daily S3 Audit — Prod`). Appears in the schedule list and in run history.
- **Prompt** — the full instruction for the agent, exactly as you would write it in chat.

### Step 2: Frequency

Pick a preset or enter a custom cron expression:

| Preset | Example |
| --- | --- |
| **Hourly** | At a specific minute past every hour |
| **Daily** | At a specific hour and minute each day |
| **Weekly** | On selected days of the week at a given time |
| **Monthly** | On selected days of the month at a given time |
| **Custom** | Any valid 5-field cron expression (for example `0 9 * * 1-5`) |

### Step 3: Timezone

Choose the timezone the cron expression should be interpreted in. The editor pre-fills with your browser's timezone and shows the current UTC offset alongside each option (for example `Europe/Madrid (UTC+1)`).

### Step 4: Allowed actions

Tick the [action categories](guardrails.md#categorical-grants) this schedule is pre-approved to perform. Anything outside this allowlist is denied at runtime — even if the sandbox's standing grant would permit it interactively.

Categories the sandbox itself isn't granted are disabled in the picker (you can't pre-approve something the parent scope hasn't allowed).

> [!TIP]
> Keep allowed actions to the minimum the prompt needs. A read-only audit schedule should leave the list empty — read access is always allowed.

### Step 5: Max runtime

Set a per-firing runtime cap (default 15 minutes). If the agent hasn't finished by then, the run is terminated and marked failed.

### Step 6: Post-run digest

Optionally send a summary to a notification channel after each firing.

- **Channel** — choose from the notify credentials attached to this sandbox (Slack, Teams, PagerDuty, or SMTP). Select *Off — no digest* to skip. If no channels are attached yet, the picker is empty — add one under Credentials → Notifications first.
- **Send on** — filter which outcomes trigger the digest: *Always* · *On success* · *On failure* · *On blocked*.

For the full explanation of how digests work alongside mid-run notifications, see [Notifications](notifications.md#schedule-digests).

### Step 7: Save

Click **Create**. The schedule is active immediately. Toggle the **Enabled** switch off if you want to keep it but not have it fire.

## Allowed actions

When the agent is running a scheduled session and reaches for a mutating tool call, the system enforces, in order:

1. The org → project → sandbox grant chain (same as for interactive chat).
2. **AND** the schedule's own allowlist from Step 4.

Both must permit the category. If either denies, the call is blocked and the agent receives a denial back. See [Guardrails & cost caps](guardrails.md) for the full model.

## Managing schedules

| Action | How |
| --- | --- |
| **Pause** | Toggle the enable switch on any schedule row |
| **Resume** | Toggle it back on |
| **Edit** | Click the pencil icon to change prompt, cron, timezone, allowed actions, runtime cap, or digest channel |
| **Delete** | Click the trash icon — this also removes the cron trigger, but preserves past run history |

## Viewing scheduled run output

Each time a schedule fires, a new chat session is created tagged with source **Scheduled** in the [Chats & History](chats.md) tab. The schedules row also shows the **last fire**, **next fire**, and a status pill for the most recent run:

| Pill | Meaning |
| --- | --- |
| **Success** | The agent finished cleanly |
| **Blocked** | The agent stopped because policy denied a step it needed |
| **Failed** | The agent crashed, hit the runtime cap, or exceeded budget |
| **Running** | A firing is currently in progress |

Click the row's **Runs** action to see the latest firings; click a firing to open the full chat-session viewer (read-only, with a "Scheduled run" ribbon at the top).

> [!NOTE]
> If a scheduled run is still in progress when the next tick fires, the next tick is **skipped** automatically to prevent overlapping executions.

## Failure handling

Scheduled runs do **not** retry. If a firing fails (budget exceeded, policy denied a critical step, sandbox crash, …) the schedule waits for the next cron tick.

If consecutive failures pile up, the schedule **auto-disables itself** to avoid burning budget on something that's clearly broken. The threshold is inheritable: you can set a per-schedule override, otherwise it falls back to the sandbox / project / org's max-consecutive-failures setting, otherwise to the platform default (5).

A re-enabled schedule resets the consecutive-failure counter.
