[← Cloud Agent](README.md) · [← Templates](templates.md) · [Runs →](runs.md)

# Scheduled Runs

**On this page:** [Creating a schedule](#creating-a-schedule) · [Managing schedules](#managing-schedules) · [Viewing scheduled run output](#viewing-scheduled-run-output)

Scheduled runs execute a template automatically on a recurring cron schedule. They are useful for regular audits, daily reports, or any repeating task you would otherwise trigger manually.

Open the **Schedules** tab inside any sandbox to manage schedules.

> [!WARNING]
> You need at least one template in the sandbox before you can create a schedule.

## Creating a schedule

<!-- Screenshot: ![Create schedule form — frequency presets and custom cron option](./images/cloud-agent-schedules-create-form.png) -->

### Step 1: Open the dialog

Click **New schedule**. This opens the create dialog.

### Step 2: Name your schedule

Enter a display name (for example `Daily S3 Audit — Prod`). This name appears in the schedule list and in run history.

### Step 3: Select a template

Choose the template to execute. Only templates from the current sandbox are available.

### Step 4: Set the frequency

Choose a preset or enter a custom cron expression:

| Preset | Example |
| --- | --- |
| **Hourly** | At a specific minute past every hour |
| **Daily** | At a specific hour and minute each day |
| **Weekly** | On specific days of the week at a given time |
| **Monthly** | On specific days of the month at a given time |
| **Custom** | Any valid 5-field cron expression (for example `0 9 * * 1-5`) |

The UI shows a human-readable preview of the cron expression before you save.

### Step 5: Save

Click **Create**. The schedule is active immediately.

## Managing schedules

| Action | How |
| --- | --- |
| **Pause** | Toggle the enable/disable switch on any schedule row |
| **Resume** | Toggle it back on |
| **Delete** | Click the delete icon — this also removes the cron trigger, but preserves past run history |

## Viewing scheduled run output

Each time a schedule fires, a new run is created and tagged with source **Scheduled** in the [Runs & History](runs.md) tab. Click the row to open the debug view and inspect step-by-step output.

> [!NOTE]
> If a scheduled run is already in progress when the next tick fires, it is skipped automatically to prevent overlapping executions.
