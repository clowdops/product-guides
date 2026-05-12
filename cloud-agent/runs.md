[← Cloud Agent](README.md) · [← Schedules](schedules.md) · [Resources →](resources.md)

# Runs & History

**On this page:** [Columns](#columns) · [Source types](#source-types) · [Run statuses](#run-statuses) · [Inspecting a run](#inspecting-a-run)

The **Runs** tab gives you a unified audit log of every agent execution in the sandbox — whether it was triggered by a chat message, a template run, or a scheduled task.

<!-- Screenshot: ![Runs tab — source filter, status badges, token count, and cost columns](./images/cloud-agent-runs-list.png) -->

## Columns

| Column | Description |
| --- | --- |
| **Timestamp** | When the run was triggered |
| **Source** | How the run was initiated (see below) |
| **Name / Prompt** | Template name, or a snippet of the user's prompt for chat runs |
| **Status** | Outcome of the run |
| **Tokens** | Total tokens consumed (prompt + completion), shown as `k` or `M` |
| **Cost** | Estimated cost in USD for the AI calls in this run |

## Source types

| Badge | Meaning |
| --- | --- |
| **Chat** | Triggered by a message in the chat interface |
| **Template** | Triggered by clicking **Run** on a template |
| **Scheduled** | Triggered automatically by a cron schedule |

Use the **Source** filter at the top of the list to narrow results to a specific trigger type.

## Run statuses

| Status | Meaning |
| --- | --- |
| **Running** | Currently in progress |
| **Completed** | Finished successfully |
| **Failed** | Terminated with an error |
| **Canceled** | Stopped before completion |

## Inspecting a run

Click any row to open the debug view. This shows the full step-by-step execution trace: each step's inputs, outputs, tool calls, model used, token count, and error details for failed steps.

> [!TIP]
> The debug view is the primary tool for understanding why a run produced unexpected results or failed partway through.

The list paginates 50 rows at a time. Use the **Refresh** button to pull the latest data if you are watching an in-progress run.
