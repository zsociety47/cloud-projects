# Roadmap

Where this work is going. It changes as the work does.

Every project here is a proof of concept (PoC): a stated hypothesis, success criteria, working infrastructure, automated deployment, and a recorded walkthrough. The projects are built on Azure first. Google Cloud and Amazon Web Services (AWS) follow as second and third passes that rebuild the same projects. The rule for a rebuild is simple: the same idea, done again, has to be better than the last time.

## How a rebuild improves

1. Build the project in one cloud and write down what went wrong and what was learned.
2. Before building the same project in another cloud, read those lessons and apply them first.
3. After finishing, add what changed. Sort each lesson as general (true in any cloud) or specific to one provider.
4. Check the result: faster, safer, simpler, and easier to explain than the last version.

By the third cloud, the project is the most complete and adaptable version of the idea.

## Core series: six projects per cloud

The same six ideas, in the same order and with the same tools, in every cloud.

| # | Idea | Tool | Azure | Google Cloud | AWS |
|---|------|------|-------|--------------|-----|
| 1 | Host a static site and deploy it with no stored credentials | Bash and the cloud command line | [Complete](https://github.com/zsociety47/azure-static-website-poc) | Planned | Planned |
| 2 | A database with no public address, reachable only from the web tier | Python and the cloud SDK | [Complete](https://github.com/zsociety47/azure-two-tier-network-poc) | Planned | Planned |
| 3 | A managed database whose password lives in a secret store, read by the VM's own identity | Python and the cloud SDK | [Complete](https://github.com/zsociety47/azure-sql-keyvault-poc) | Planned | Planned |
| 4 | A network described in Terraform, with a firewall added to it after it is running | Terraform | [Complete](https://github.com/zsociety47/azure-terraform-iac-poc) | Planned | Planned |
| 5 | Governance guardrails: allowed machine sizes, a read-only user, a budget | Terraform | In progress | Planned | Planned |
| 6 | A Terraform pipeline from GitHub with remote state and checks | Terraform in a pipeline | In progress | Planned | Planned |
| 6.5 | A migration that runs through that pipeline | Terraform in a pipeline | In progress | Planned | Planned |

Projects 6 and 6.5 work off each other. The pipeline tests and applies. The migration is the workload it delivers. Each cloud's migration brings in a different cloud: the Azure set brings in AWS, the Google Cloud set brings in Azure, and the AWS set brings in Google Cloud. Together the three sets cover each other.

Tools by project: Bash first, then Python for projects 2 and 3, then Terraform for 4 to 6.5. The point of the order is to feel what each tool does well before moving to the next.

## More series

| Series | What it is | Status |
|---|---|---|
| **Landing zone** | Projects that stack on each other into one environment: network, identity, policy, logging, and shared services. One per cloud: Azure landing zone, Google Cloud landing zone, AWS landing zone | Planned |
| **Kubernetes** | Two parts. Part 1 is a basic event ticketing platform as a small first version, deployed with Helm on a managed cluster. Part 2 splits it into services (forecasting, fraud detection, an organizer assistant, notifications, search) with a Helm chart each, and moves one service to a second cloud | Planned |
| **More Azure projects** | Further Azure proofs of concept beyond the first six | Planned |

## How each project is recorded

Each project gets a recorded walkthrough, on camera: what it is, the business problem it solves, the build or the finished architecture, and what I would change. Azure projects get four posts each. The second and third clouds get two: the video and repository together, then the architecture and tool together.

*Last updated October 22, 2026.*
