[← ClowdOps](README.md) · [← Chat](chat.md) · [Schedules →](schedules.md)

# Templates

**On this page:** [System vs custom templates](#system-templates-vs-custom-templates) · [Creating a template](#creating-a-template) · [Running a template manually](#running-a-template-manually)

Templates are saved, reusable prompts. Instead of typing the same request in chat each time, you define it once as a template, then run it on demand or schedule it to run automatically.

Open the **Templates** tab inside any sandbox to manage templates.

<!-- Screenshot: ![Templates tab — system templates (read-only) and custom templates](./images/cloud-agent-templates-list.png) -->

## System templates vs custom templates

| Type | Created by | Editable | Deletable |
| --- | --- | --- | --- |
| **System templates** | The platform | No | No |
| **Custom templates** | You | Yes | Yes |

System templates are pre-built workflows provided by the platform. They appear at the top of the list and can be run but not modified. Custom templates are ones you create for your own use cases.

## Creating a template

<!-- Screenshot: ![Create template dialog](./images/cloud-agent-templates-create-form.png) -->

### Step 1: Open the create dialog

Click **New template** in the Templates tab.

### Step 2: Fill in the details

- **Name** — a short, descriptive label (for example `S3 Public Access Audit`)
- **Description** — optional. Explains what the template does; shown in the list.
- **System prompt** — the full instruction for the agent. Write it exactly as you would in chat, but in a reusable form.

### Step 3: Save

Click **Create**. The template appears in your custom templates list.

## Running a template manually

Click **Run** next to any template. This opens a new chat session and immediately submits the template prompt to the agent, exactly as if you had typed it. The resulting run appears in the [Runs & History](runs.md) list with source **Template**.

> [!TIP]
> To schedule a template to run automatically on a recurring basis, see [Scheduled Runs](schedules.md).
