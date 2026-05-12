---
icon: diagram-project
---

# Cloud Resources

The **Resources** tab gives you a live inventory of the cloud resources the agent has discovered in your sandbox. It is read-only from the UI — the agent populates it automatically as it explores your infrastructure.

<figure><img src="../.gitbook/assets/cloud-agent-resources-tree.png" alt=""><figcaption>Resource tree — hierarchical view grouped by provider and account</figcaption></figure>

## Resource tree

Resources are organised in a hierarchy:

```
Provider (AWS / GCP / Azure)
└── Account / Project / Subscription
    └── Region / Zone
        └── Resource type
            └── Individual resource
```

Expand any node to drill down. Active resources are shown with a solid indicator; inactive or unknown ones are dimmed.

## Searching

Use the search box at the top of the Resources tab to filter the tree by resource name, ID, or type. Search results highlight matching nodes while collapsing unrelated branches.

## Inspecting a resource

Click any resource in the tree to open the detail panel on the right. It shows:

* **Metadata** — raw JSON properties as returned by the cloud provider
* **Dependencies** — inbound (what depends on this resource) and outbound (what this resource depends on)

Use the **Pivot** button on any dependency to jump directly to that resource's detail view.

## Dependency graph

<figure><img src="../.gitbook/assets/cloud-agent-resources-dependency-graph.png" alt=""><figcaption>Dependency subgraph for a selected resource</figcaption></figure>

The dependency graph visualises the relationships around a selected resource — useful for understanding blast radius before making changes or for troubleshooting connectivity issues.

## Show default network resources

Toggle **Show default network resources** at the top of the panel to include or exclude automatically-created provider resources (default VPCs, default subnets, etc.). These are hidden by default to reduce noise.

{% hint style="info" %}
The resource inventory grows over time as the agent runs more queries. If you expect to see a resource that is not yet listed, run a discovery-oriented prompt in chat (e.g., _"Discover all resources in my AWS us-east-1 account"_) to populate it.
{% endhint %}
