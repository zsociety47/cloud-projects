# Cloud Projects

Hands-on cloud engineering projects, each built as a proof of concept: a stated hypothesis, success criteria, working infrastructure, automated deployment, and a recorded walkthrough.

Every project follows the shared standards in [`standards/`](standards/).

## What's in this repository

This repository is the hub. Project code lives in other GitHub repositories, listed in the tables below. Folders here:

```text
cloud-projects/
├── README.md                 this file: project index
├── ROADMAP.md                what comes after the current series
├── terraform/
│   ├── azure/                Azure modules, laptop root, examples
│   ├── gcp/                  Google Cloud (empty until needed)
│   └── aws/                  Amazon Web Services (empty until needed)
├── .github/workflows/        azure-terraform-plan.yml and azure-terraform-apply.yml
├── standards/                naming, documentation, diagrams, video, posts
└── environment-control/      nightly delete of short-lived resource groups
```

| Folder | Cloud | What it is |
|---|---|---|
| [`terraform/azure/modules/`](terraform/azure/modules/) | Azure | **The Azure Terraform modules.** Shared state account, then one Microsoft Entra app per GitHub repository |
| [`terraform/azure/pipeline-foundation/`](terraform/azure/pipeline-foundation/) | Azure | Laptop-only root. Applied Oct 26, 2026: keep group and state account exist. `projects = {}` |
| [`terraform/azure/examples/`](terraform/azure/examples/) | Azure | Copy-ready Plan / Apply callers and a `backend.tf` stub |
| [`terraform/gcp/`](terraform/gcp/) | Google Cloud | Empty on purpose. Shared GCP Terraform lands here later |
| [`terraform/aws/`](terraform/aws/) | Amazon Web Services | Empty on purpose. Shared AWS Terraform lands here later |
| [`.github/workflows/`](.github/workflows/) | Azure today | Reusable jobs, named `azure-*`. GCP and AWS get their own prefixes |
| [`standards/`](standards/) | all | How every project is named, documented, drawn, recorded, and posted |
| [`environment-control/`](environment-control/) | Azure, GCP, AWS | Nightly sweep. Azure is `envctl.sh`, then `envctl-gcp.sh` and `envctl-aws.sh` |

Each of those folders has its own README. The walkthrough of building the Azure pipeline by hand is [Terraform from GitHub to Azure](https://github.com/zsociety47/azure-terraform-pipeline-poc). Later Azure projects call `terraform/azure/modules/`. They don't copy that repository.

## Roadmap

Azure first, then the same ideas rebuilt on Google Cloud and Amazon Web Services (AWS), each one better than the last time. After that: a landing-zone series, a Kubernetes series, and more Azure projects. [Full roadmap](ROADMAP.md) — including **where we stand** on Azure 6 (discovery proven; replication held on the AWS virtual central processing unit quota; variant B prepared).

**Now:** Azure 1–5 complete. Azure 6 is the recording focus (path B while AWS On-Demand Standard vCPUs stay at 8). Azure 7 pipeline work continues in parallel. Shared Azure Terraform modules and the nightly environment sweep live in this hub.

---

## Azure

| # | Project | What it proves | Walkthrough | Status |
|---|---------|----------------|-------------|--------|
| 1 | [Static Website on Blob Storage](https://github.com/zsociety47/azure-static-website-poc) | A static site can be hosted on Azure Storage and deployed from GitHub Actions with no stored credentials | [Loom](https://www.loom.com/share/56b36c39bfb84152828e7ee3ad1f6cc7) | Complete |
| 2 | [Secure Two-Tier Web Application on Azure](https://github.com/zsociety47/azure-two-tier-network-poc) | A database with no public IP address is reachable only from the web tier | [Loom](https://www.loom.com/share/3627b9267eff4235b9f635ca752d191c) | Complete |
| 3 | [Managed SQL and Key Vault on Azure](https://github.com/zsociety47/azure-sql-keyvault-poc) | An app VM reads its database password from Key Vault with a managed identity, and its role can't write secrets | [Loom](https://www.loom.com/share/326b50f1396142d9848704c6918908b5) | Complete |
| 4 | [Infrastructure as Code with Terraform on Azure](https://github.com/zsociety47/azure-terraform-iac-poc) | A virtual network can be described in Terraform, gain a firewall after it already exists, and be removed with one command | [Loom](https://www.loom.com/share/b0448fef104a4bdc90a3d7c63cad2014) | Complete |
| 5 | [Governance guardrails on Azure](https://github.com/zsociety47/azure-governance-poc) | A reader is limited to one resource group, policy blocks an oversized virtual machine before it is created, and a budget alerts as spend nears the monthly limit | [Loom](https://www.loom.com/share/6f35ccb43dbb4a57b4905d501d9b9163) | Complete |
| 6 | [Migrate a Windows Server from AWS to Azure](https://github.com/zsociety47/azure-aws-migrate-poc) | A Windows Server on AWS can be discovered, assessed, replicated, and cut over to Azure | Pending | In progress — discovery proven; replication held on AWS vCPU quota (applied 8); variant B prepared |
| 7 | [Terraform from GitHub to Azure](https://github.com/zsociety47/azure-terraform-pipeline-poc) | A pull request plans and tests a Terraform change, and only the main branch can apply it, with no Azure password stored in GitHub | Pending | In progress |
| 8 | [Cost visibility dashboard](https://github.com/zsociety47/azure-cost-dashboard) | Spend by service and resource group is visible with a budget alert before the month is spent | Pending | In progress |
| 9 | [Backup system](https://github.com/zsociety47/azure-backup-system) | Geo-redundant storage keeps previous versions and a 30-day soft delete, and an alert fires if a day passes with no writes | Pending | In progress |

## Google Cloud

| # | Project | What it proves | Walkthrough | Status |
|---|---------|----------------|-------------|--------|
| 1 | [Static website on Cloud Storage](https://github.com/zsociety47/gcp-static-website-poc) | A public website can be served from a Cloud Storage bucket with no server to manage | Pending | In progress |
| 2 | [Two-tier network](https://github.com/zsociety47/gcp-two-tier-network-poc) | A database with no public address is reachable only from the web tier | Pending | In progress |
| 3 | Managed database and secrets | A virtual machine reads a database password from Secret Manager and queries Cloud SQL on a private address | Pending | In progress |

## Amazon Web Services

| # | Project | What it proves | Walkthrough | Status |
|---|---------|----------------|-------------|--------|
| 1 | [Static website on CloudFront](https://github.com/zsociety47/aws-static-website-poc) | A private Simple Storage Service (S3) bucket can serve a site through CloudFront, and the bucket stays closed to the public | Pending | In progress |

---

## Standards

- [Azure Terraform modules](terraform/azure/modules/): shared state account and one Entra app per GitHub repository. Reusable Azure Plan / Apply jobs are in [`.github/workflows/`](.github/workflows/). Google Cloud and AWS slots are [`terraform/gcp/`](terraform/gcp/) and [`terraform/aws/`](terraform/aws/). The walkthrough of building the Azure pipeline by hand is [Terraform from GitHub to Azure](https://github.com/zsociety47/azure-terraform-pipeline-poc).
- [Architecture Diagram Standard](standards/DIAGRAM-STANDARD.md): tools, colors, line styles, and checklist used for every diagram
- [Project README Template](standards/README-TEMPLATE.md): video first, then step-by-step instructions with screenshots, then the technical detail
- [Documentation Standard](standards/DOCUMENTATION-STANDARD.md): what gets written, when, and what done means
- [Video Script Template](standards/VIDEO-SCRIPT-TEMPLATE.md): intro, walkthrough, outro, and the screenshot list
- [LinkedIn post strategy](standards/LINKEDIN-POSTS.md): four posts per project (video, repository, architecture, one tool) and the video recording guide

## About

Zeon Stewart, cloud and full-stack engineer based in Brooklyn, New York.
[LinkedIn](LINKEDIN_LINK_HERE)
