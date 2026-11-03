# Roadmap

Where this work is going. It changes as the work does.

Every project here is a proof of concept (PoC): a stated hypothesis, success criteria, working infrastructure, automated deployment, and a recorded walkthrough. The projects are built on Azure first. Google Cloud and Amazon Web Services (AWS) follow as second and third passes that rebuild the same ideas. The rule for a rebuild is simple: the same idea, done again, has to be better than the last time.

## Where we stand (November 2026)

Azure projects 1 through 6 are complete, each with a recorded walkthrough. The shared Azure Terraform modules and the laptop pipeline foundation exist under `terraform/azure/`. The nightly environment sweep is in use.

**Azure 6 — Migrate a Windows Server from AWS to Azure** is complete. Walkthrough: https://www.loom.com/share/8d2fbd4ae33b4ac6af3cfb42c0a76eee. Nothing is running.

- Discovery, Variant A replication, a test migration, cutover, Complete migration, and teardown all ran. Protected / Healthy on 2026-11-01. Complete and teardown on 2026-11-02. Quota `L-1216C47A` was 8 at first apply, 16 when the appliance started, and 24.0 on 2026-11-02. Do not file another request.
- Azure Site Recovery counts Windows cores, not vCPUs. `c5.2xlarge` and the Azure appliance sizes showed 4 cores and failed. `c5.4xlarge` showed 8 and passed. Variant B (`vm-repl`) failed that check and never copied a disk.
- Do not rebuild for recording. Do not invent a login to the migrated server.

**Azure 7 — Terraform from GitHub to Azure** is in progress in parallel. Shared modules and the foundation root are in this hub; the walkthrough repo is separate.

**Azure 8 and 9** (cost dashboard, backup system) are started as repos and are not the current recording focus.

**Google Cloud 1–2** and **AWS 1** are in progress as second-cloud rebuilds of earlier ideas. They are not blocking Azure 7.

Standards now require: on the first running pass of every project, capture every screenshot that pass can prove before teardown; replace shots a later change makes wrong. Do not tear down a first pass only to rebuild for pictures.

## How a rebuild improves

1. Build the project in one cloud and write down what went wrong and what was learned.
2. Before building the same project in another cloud, read those lessons and apply them first.
3. After finishing, add what changed. Sort each lesson as general (true in any cloud) or specific to one provider.
4. Check the result: faster, safer, simpler, and easier to explain than the last version.

By the third cloud, the project is the most complete and adaptable version of the idea.

## Core series: six ideas per cloud

The same ideas, in the same order and with the same tools, in every cloud. Numbering matches the [project index](README.md).

| # | Idea | Tool | Azure | Google Cloud | AWS |
|---|------|------|-------|--------------|-----|
| 1 | Host a static site and deploy it with no stored credentials | Bash and the cloud command line | [Complete](https://github.com/zsociety47/azure-static-website-poc) | [In progress](https://github.com/zsociety47/gcp-static-website-poc) | [In progress](https://github.com/zsociety47/aws-static-website-poc) |
| 2 | A database with no public address, reachable only from the web tier | Python and the cloud SDK | [Complete](https://github.com/zsociety47/azure-two-tier-network-poc) | [In progress](https://github.com/zsociety47/gcp-two-tier-network-poc) | Planned |
| 3 | A managed database whose password lives in a secret store, read by the VM's own identity | Python and the cloud SDK | [Complete](https://github.com/zsociety47/azure-sql-keyvault-poc) | Planned | Planned |
| 4 | A network described in Terraform, with a firewall added to it after it is running | Terraform | [Complete](https://github.com/zsociety47/azure-terraform-iac-poc) | Planned | Planned |
| 5 | Governance guardrails: allowed machine sizes, a read-only user, a budget | Terraform | [Complete](https://github.com/zsociety47/azure-governance-poc) | Planned | Planned |
| 6 | Migrate a Windows Server into this cloud (Azure brings in AWS; later clouds bring in another provider) | Terraform plus the cloud migrate product | [Complete](https://github.com/zsociety47/azure-aws-migrate-poc) — [walkthrough](https://www.loom.com/share/8d2fbd4ae33b4ac6af3cfb42c0a76eee) | Planned | Planned |
| 7 | A Terraform pipeline from GitHub with remote state and checks | Terraform in a pipeline | [In progress](https://github.com/zsociety47/azure-terraform-pipeline-poc) | Planned | Planned |

Projects 6 and 7 work off each other over time. The pipeline tests and applies. The migration is a real workload that can eventually ride that pipeline. Each cloud's migration brings in a different cloud: the Azure set brings in AWS, the Google Cloud set brings in Azure, and the AWS set brings in Google Cloud. Together the three sets cover each other.

Azure also has two further proofs of concept outside the six-idea core:

| # | Idea | Azure |
|---|------|-------|
| 8 | Cost visibility dashboard | [In progress](https://github.com/zsociety47/azure-cost-dashboard) |
| 9 | Backup system with versioning, soft delete, and a no-write alert | [In progress](https://github.com/zsociety47/azure-backup-system) |

Tools by project: Bash first, then Python for projects 2 and 3, then Terraform for 4 through 7. The point of the order is to feel what each tool does well before moving to the next.

## More series

| Series | What it is | Status |
|---|---|---|
| **Landing zone** | Projects that stack on each other into one environment: network, identity, policy, logging, and shared services. One per cloud: Azure landing zone, Google Cloud landing zone, AWS landing zone | Planned |
| **Kubernetes** | Two parts. Part 1 is a basic event ticketing platform for in-person and virtual events, as a small first version, deployed with Helm on a managed cluster. Part 2 splits it into services (forecasting, fraud detection, an organizer assistant, notifications, search) with a Helm chart each, and moves one service to a second cloud | Planned |
| **More Azure projects** | Further Azure proofs of concept beyond the core six (cost dashboard and backup are already started) | In progress |

## How each project is recorded

Each project gets a recorded walkthrough, on camera: what it is, the business problem it solves, the build or the finished architecture, and what I would change. Azure projects get four posts each. The second and third clouds get two: the video and repository together, then the architecture and tool together.

On the first running pass, capture every screenshot that pass can prove before teardown. Later changes replace only the shots they make wrong. Do not destroy a first pass only to rebuild it for pictures.

*Last updated October 29, 2026.*
