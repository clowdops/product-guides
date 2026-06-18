---
title: "One prompt, every region: I had an AI agent audit my AWS account for risk and waste"
subtitle: "Two critical exposures, six stale access keys, and ~$96/month of quiet waste — ranked, with the exact fix commands, and it changed nothing."
tags: [Security, FinOps, AWS, Cloud Audit, AI Agents, ClowdOps, IAM, Cost Optimization]
audience: LinkedIn / Medium / company blog
status: draft
source_session: redacted
anonymized: true
note: "Cost findings are illustrative — composited from common real-world waste patterns to show the report format."
---

# One prompt, every region: I had an AI agent audit my AWS account for risk and waste

Most cloud audits are a calendar event. You book a window, someone clicks through the
console region by region, copies findings into a spreadsheet, and two days later you have
a list that's already stale.

I did it in one sentence. I gave a **ClowdOps** agent — with a read-only AWS credential —
a single prompt and let it work.

> **Me:** Audit this AWS account for the top public-exposure and cost risks: security
> groups open to `0.0.0.0/0` on sensitive ports, unattached EBS volumes, idle Elastic
> IPs, IAM access keys older than 90 days, and S3 buckets without encryption or with
> public access. Rank by risk and estimated monthly waste, and for the top 5 give me the
> exact remediation commands — **but don't apply anything yet.**

Three minutes later I had a ranked report. Here's what happened, lightly anonymized.

---

## It planned, then swept every region

The agent didn't just start firing commands. It laid out a **5-step plan** —
EC2/networking, IAM, S3, idle compute, then synthesis — and worked the list, streaming
each step as it went. The actual scanning was a multi-region `boto3` sweep (it wrote and
ran its own Python), not a single-region console click. Every AWS region, in one pass.

And it respected the boundary I set: **"don't apply anything yet."** It read everything
and changed nothing. Every finding came with a remediation command *for me to run*, not
one it executed.

---

## What it found

### 🔴 Critical — a message broker open to the whole internet

The headline finding, in **two regions**:

| Security group | Region | Open to `0.0.0.0/0` |
|---|---|---|
| `acme-app-sg-us-east-1` (`sg-0a1b…0718`) | us-east-1 | **5672** (AMQP) · **15672** (RabbitMQ admin UI) |
| `acme-app-sg-eu-central-1` (`sg-0f1e…9788`) | eu-central-1 | **5672** · **15672** |

A RabbitMQ broker *and its management console* reachable from anywhere on earth. That's
not a cost problem — it's a "someone is going to find this with a port scanner" problem.
The agent flagged both as Critical and gave me the exact revoke commands.

### 🟠 High — six access keys way past their expiry

It enumerated every IAM access key and sorted by age. Six were over 90 days; the oldest
was **446 days**:

| User | Key | Age |
|---|---|---|
| `app-prod` | `AKIAEXAMPLE1A2B3C4D5` | 446 days |
| `app-prod` | `AKIAEXAMPLE6E7F8G9H0` | 444 days |
| `ci-deployer` | `AKIAEXAMPLE2B3C4D5E6` | 421 days |
| `backup-svc` | `AKIAEXAMPLE3C4D5E6F7` | 379 days |
| `logs-svc` | `AKIAEXAMPLE4D5E6F7G8` | 235 days |
| `backup-svc` | `AKIAEXAMPLE5E6F7G8H9` | 119 days |

Long-lived static keys are how breaches turn into *persistent* breaches. Each one came
with a `update-access-key … --status Inactive` command, staged but not run.

### 💰 Cost — ~$96/month of quiet waste

This is where an audit earns its keep. Ranked by estimated monthly waste:

| # | Finding | Monthly waste |
|---|---|---|
| 1 | Orphaned **NAT Gateway** in an unused dev VPC (≈ 0 traffic, still billing hourly) | **$32.40** |
| 2 | **612 GB of orphaned EBS snapshots** from volumes deleted months ago | **$30.60** |
| 3 | **3 unattached EBS volumes** (180 GB `gp3`) left by terminated instances | **$14.40** |
| 4 | **`gp2` → `gp3` migration** opportunity on 460 GB of attached volumes | **$11.50** |
| 5 | **2 idle Elastic IPs** (allocated, unassociated) | **$7.20** |
| | **Total** | **≈ $96 / month (~$1,150 / year)** |

None of it is huge on its own — which is exactly why it survives. A forgotten NAT gateway
and a pile of orphaned snapshots don't show up on anyone's dashboard until someone goes
looking. The agent went looking.

### ✅ What was actually clean

Worth stating, because a good audit also tells you where you're fine: **all S3 buckets**
were encrypted and blocked from public access, and there were **no public-read buckets**.
No false alarms.

---

## The part I keep coming back to

Every finding shipped with the fix — copy-paste ready:

```bash
# Close the broker to the world (us-east-1)
aws ec2 revoke-security-group-ingress --region us-east-1 \
  --group-id sg-0a1b2c3d4e5f60718 --protocol tcp --port 5672  --cidr 0.0.0.0/0
aws ec2 revoke-security-group-ingress --region us-east-1 \
  --group-id sg-0a1b2c3d4e5f60718 --protocol tcp --port 15672 --cidr 0.0.0.0/0

# Retire the oldest access key
aws iam update-access-key --user-name app-prod \
  --access-key-id AKIAEXAMPLE1A2B3C4D5 --status Inactive
```

…and the agent **stopped there**, because I told it to. The audit and the remediation are
two separate decisions: it surfaced the truth, ranked it, wrote the fix, and handed me the
trigger. Reviewing five precise commands beats clicking through forty console screens —
and I'm still the one who decides what runs.

---

## Run the audit on your own account

It's one prompt against a read-only key:

> *"Audit this account for public-exposure and cost risks, rank by severity and monthly
> waste, give me the top fixes — and don't change anything."*

Security and FinOps in the same pass, every region, in the time it takes to get coffee.
**ClowdOps** does the looking; you keep the decisions. → [clowdops.ai](https://clowdops.ai)

---

*Based on a real agent session. Account identifiers, security-group IDs, IAM user names,
and access-key IDs have been anonymized. The security findings and remediation flow are
from the real run; the cost figures are illustrative, composited from common real-world
waste patterns to show the report format.*
