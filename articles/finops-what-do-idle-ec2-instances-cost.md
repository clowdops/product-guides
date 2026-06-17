---
title: "Your stopped EC2 instances aren't free — I asked an AI agent to find the bill"
subtitle: "A two-question conversation that turned 'we have some old VMs somewhere' into an itemized monthly cost sheet — and a plan to make it zero."
tags: [FinOps, AWS, Cloud Cost, AI Agents, ClowdOps, EC2, EBS]
audience: LinkedIn / Medium / company blog
status: draft
source_session: redacted
anonymized: true
---

# Your stopped EC2 instances aren't free — I asked an AI agent to find the bill

Every cloud account has them: a couple of servers somebody spun up "just to test something," stopped, and never thought about again. They're not running, so they feel free. They aren't.

Instead of clicking through five console tabs in two regions, I had a plain-language conversation with a **ClowdOps** agent that has read-only access to our AWS tenant. Two questions. Under a minute of agent work. A full answer with a number I could act on.

Here's how it went — lightly anonymized, but otherwise exactly what happened.

---

## Question 1 — "What do I even have out there?"

> **Me:** List the EC2 VMs in the AWS tenant, both running and stopped. For each, show the instance ID, name tag, state, type, and region.

The interesting part isn't the answer — it's *how the agent got there*.

It first reached for the efficient move: fan out across every region in parallel. That command failed (`NoRegion: You must specify a region`). A script would have stopped there. The agent **read the error, understood it, and rewrote its own approach** — fetch the region list first, then loop through each one explicitly:

```bash
REGIONS=$(aws ec2 describe-regions --region us-east-1 \
  --query 'Regions[*].RegionName' --output json | jq -r '.[]')

for region in $REGIONS; do
  aws ec2 describe-instances --region "$region" \
    --filters "Name=instance-state-name,Values=running,stopped" \
    --query "Reservations[*].Instances[*].{InstanceId:InstanceId, \
      Name:Tags[?Key=='Name']|[0].Value, State:State.Name, \
      Type:InstanceType, AZ:Placement.AvailabilityZone}" \
    --output json
done
```

Seconds later, a clean inventory across **all 17 regions**:

| Instance ID | Name | State | Type | Region |
|---|---|---|---|---|
| `i-0a1b2c3d4e5f60718` | acme-eu-central-1 | 🔴 stopped | t3.small | eu-central-1 |
| `i-09f8e7d6c5b4a3210` | acme-us-east-1 | 🔴 stopped | t3.small | us-east-1 |

> **2 instances total — 0 running, 2 stopped.** Both `t3.small`, both idle. Nothing else anywhere.

Two forgotten machines, exactly the kind everyone assumes cost nothing because they're switched off.

---

## Question 2 — "OK, so what are they actually costing me?"

A few days later I came back to the same conversation and asked the obvious follow-up:

> **Me:** Tell me about the cost of the resources attached to these 2 stopped VM instances (disks, networks, IPs…).

This is where an agent beats a dashboard. A stopped instance doesn't cost compute — but the **things hanging off it** still bill quietly. The agent knew exactly what to chase, and went after each one:

- **Attached storage** — it pulled the block device mappings, found one EBS volume per instance, then read each volume's full spec (size, type, IOPS, throughput).
- **Network interfaces** — it inspected every ENI and confirmed they only carry private IPs.
- **Elastic IPs** — it checked both regions for allocated EIPs, because an *unattached* Elastic IP is the classic silent charge. There were none.
- **Real billing data** — it didn't just guess from price lists. It queried AWS Cost Explorer directly (by service, then by region) to ground the estimate in what the account is actually being charged.

What it found:

### `acme-eu-central-1` (eu-central-1)
| Resource | Details | Monthly cost |
|---|---|---|
| EBS volume `vol-0a1b2c3d4e5f6a7b8` | 8 GB · **gp2** · 100 IOPS · unencrypted | ~$0.88 |
| ENI `eni-0a1b2c3d4e5f6a7b8` | Private IP only (`10.0.2.17`) | $0.00 |
| Elastic IP | None | $0.00 |
| Compute (t3.small) | Stopped — not billed | $0.00 |

### `acme-us-east-1` (us-east-1)
| Resource | Details | Monthly cost |
|---|---|---|
| EBS volume `vol-0b9c8d7e6f5a4b3c2` | 15 GB · **gp3** · 3000 IOPS · 125 MB/s · unencrypted | ~$1.20 |
| ENI `eni-0f1e2d3c4b5a69788` | Private IP only (`10.0.2.43`) | $0.00 |
| Elastic IP | None | $0.00 |
| Compute (t3.small) | Stopped — not billed | $0.00 |

### The bottom line

> **~$2.08/month** — and every cent of it is **EBS storage for disks sitting idle.**

Tiny in this example. But this is the exact pattern that, multiplied across a real org, becomes the line item nobody can explain. And the agent didn't stop at the number — it handed me the actions:

- ✅ **No idle Elastic IPs** — good, those are the expensive surprise ($0.005/hr each when unattached).
- 💡 **Migrate the gp2 volume to gp3** — same performance tier, ~25% cheaper per GB.
- 🗑️ **If these are dead, terminate them** — both volumes are `DeleteOnTermination: true`, so termination zeroes the bill instantly. No orphaned disks left behind.

---

## Why this is different from a cost dashboard

A FinOps dashboard tells you *that* you spent money. It rarely tells you **which forgotten thing to go delete, and what happens if you do.**

In this session the agent:

1. **Self-corrected** when its first command failed — no human in the loop.
2. **Reasoned across regions and services** the way an engineer would, not as a fixed report.
3. **Grounded its numbers in real billing data**, not a generic price list.
4. **Ended on an action**, not a chart — including the safety detail (`DeleteOnTermination: true`) that tells you it's safe to clean up.

All from two sentences typed in plain English, against a read-only credential.

---

## Try the question on your own account

Pick the laziest version of this you can think of and just ask it:

> *"List every stopped EC2 instance across all regions and tell me what their attached storage and IPs cost per month."*

If the answer surprises you, that's the point.

**ClowdOps** runs AI agents against your cloud infrastructure — describe the task in plain language, the agent plans and executes it, you keep the receipts. → [clowdops.ai](https://clowdops.ai)

---

*This article is based on a real agent session. Account identifiers, resource IDs, instance names, and IP addresses have been anonymized; the agent's reasoning, commands, and cost figures are unchanged.*
