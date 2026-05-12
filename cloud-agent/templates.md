---
icon: rectangle-code
---

# Templates

Templates are saved, reusable prompts. Instead of typing the same request in chat each time, you define it once as a template, then run it on demand or schedule it to run automatically.

Open the **Templates** tab inside any sandbox to manage templates.

<figure><img src="../.gitbook/assets/cloud-agent-templates-list.png" alt=""><figcaption>Templates tab — system templates (read-only) and custom templates</figcaption></figure>

## System templates vs. custom templates

| Type | Created by | Editable | Deletable |
|---|---|---|---|
| **System templates** | The platform | No | No |
| **Custom templates** | You | Yes | Yes |

System templates are pre-built workflows provided by the platform. They appear at the top of the list and can be run but not modified. Custom templates are ones you create for your own use cases.

## Creating a template

<figure><img src="../.gitbook/assets/cloud-agent-templates-create-form.png" alt=""><figcaption>Create template dialog</figcaption></figure>

{% stepper %}
{% step %}
### Open the create dialog

Click **New template** in the Templates tab.
{% endstep %}

{% step %}
### Fill in the details

* **Name** — a short, descriptive label (e.g., `S3 Public Access Audit`)
* **Description** — optional. Explains what the template does; shown in the list.
* **System prompt** — the full instruction for the agent. Write it exactly as you would in chat, but in a reusable form.
{% endstep %}

{% step %}
### Save

Click **Create**. The template appears in your custom templates list.
{% endstep %}
{% endstepper %}

## Running a template manually

Click **Run** next to any template. This opens a new chat session and immediately submits the template prompt to the agent, exactly as if you had typed it. The resulting run appears in the [Runs & History](runs.md) list with source **Template**.

{% hint style="info" %}
To schedule a template to run automatically on a recurring basis, see [Scheduled Runs](schedules.md).
{% endhint %}
