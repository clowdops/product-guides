---
icon: calendar-clock
---

# Scheduled Runs

Scheduled runs execute a template automatically on a recurring cron schedule. They are useful for regular audits, daily reports, or any repeating task you would otherwise trigger manually.

Open the **Schedules** tab inside any sandbox to manage schedules.

{% hint style="warning" %}
You need at least one template in the sandbox before you can create a schedule.
{% endhint %}

## Creating a schedule

<figure><img src="../.gitbook/assets/cloud-agent-schedules-create-form.png" alt=""><figcaption>Create schedule form — frequency presets and custom cron option</figcaption></figure>

{% stepper %}
{% step %}
### Click "New schedule"

This opens the create dialog.
{% endstep %}

{% step %}
### Name your schedule

Enter a display name (e.g., `Daily S3 Audit — Prod`). This name appears in the schedule list and in run history.
{% endstep %}

{% step %}
### Select a template

Choose the template to execute. Only templates from the current sandbox are available.
{% endstep %}

{% step %}
### Set the frequency

Choose a preset or enter a custom cron expression:

| Preset | Example |
|---|---|
| **Hourly** | At a specific minute past every hour |
| **Daily** | At a specific hour and minute each day |
| **Weekly** | On specific days of the week at a given time |
| **Monthly** | On specific days of the month at a given time |
| **Custom** | Any valid 5-field cron expression (e.g., `0 9 * * 1-5`) |

The UI shows a human-readable preview of the cron expression before you save.
{% endstep %}

{% step %}
### Save

Click **Create**. The schedule is active immediately.
{% endstep %}
{% endstepper %}

## Managing schedules

| Action | How |
|---|---|
| **Pause** | Toggle the enable/disable switch on any schedule row |
| **Resume** | Toggle it back on |
| **Delete** | Click the delete icon — this also removes the cron trigger, but preserves past run history |

## Viewing scheduled run output

Each time a schedule fires, a new run is created and tagged with source **Scheduled** in the [Runs & History](runs.md) tab. Click the row to open the debug view and inspect step-by-step output.

{% hint style="info" %}
If a scheduled run is already in progress when the next tick fires, it is skipped automatically to prevent overlapping executions.
{% endhint %}
