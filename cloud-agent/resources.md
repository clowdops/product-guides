[← Cloud Agent](README.md) · [← Runs](runs.md) · [Team & settings →](team-and-settings.md)

# Cloud Resources

**On this page:** [Resource tree](#resource-tree) · [Searching](#searching) · [Inspecting a resource](#inspecting-a-resource) · [Dependency graph](#dependency-graph) · [Show default network resources](#show-default-network-resources)

The **Resources** tab gives you a live inventory of the cloud resources the agent has discovered in your sandbox. It is read-only from the UI — the agent populates it automatically as it explores your infrastructure.

<!-- Screenshot: ![Resource tree — hierarchical view grouped by provider and account](./images/cloud-agent-resources-tree.png) -->

## Resource tree

Resources are organised in a hierarchy:

```text
Provider (AWS / GCP / Azure)
└── Account / Project / Subscription
    └── Region / Zone
        └── Resource type
            └── Individual resource
```

```mermaid
flowchart TB
  P["Provider (AWS / GCP / Azure)"]
  A["Account / Project / Subscription"]
  R["Region / Zone"]
  T["Resource type"]
  I["Individual resource"]
  P --> A --> R --> T --> I
```

Expand any node to drill down. Active resources are shown with a solid indicator; inactive or unknown ones are dimmed.

## Searching

Use the search box at the top of the Resources tab to filter the tree by resource name, ID, or type. Search results highlight matching nodes while collapsing unrelated branches.

## Inspecting a resource

Click any resource in the tree to open the detail panel on the right. It shows:

- **Metadata** — raw JSON properties as returned by the cloud provider
- **Dependencies** — inbound (what depends on this resource) and outbound (what this resource depends on)

Use the **Pivot** button on any dependency to jump directly to that resource's detail view.

## Dependency graph

<!-- Screenshot: ![Dependency subgraph for a selected resource](./images/cloud-agent-resources-dependency-graph.png) -->

The dependency graph visualises the relationships around a selected resource — useful for understanding blast radius before making changes or for troubleshooting connectivity issues.

## Show default network resources

Toggle **Show default network resources** at the top of the panel to include or exclude automatically-created provider resources (default VPCs, default subnets, and so on). These are hidden by default to reduce noise.

> [!NOTE]
> The resource inventory grows over time as the agent runs more queries. If you expect to see a resource that is not yet listed, run a discovery-oriented prompt in chat (for example *"Discover all resources in my AWS us-east-1 account"*) to populate it.
