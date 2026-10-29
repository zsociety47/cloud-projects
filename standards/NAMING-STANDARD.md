# Naming standard: Azure resources and code variables

Cheat sheet. Every name should read like a short sentence: **what it is, what it is for, which environment, whose.** The abbreviations are the ones Microsoft publishes in the Cloud Adoption Framework, so a hiring manager or another engineer reads them the same way you do.

Google Cloud has its own section at the end (section 9). Sections 1 to 8 are the Azure rules. Google publishes no abbreviation list, so section 9 keeps a short set of stems that read the same way in this portfolio.

Source: [Abbreviation recommendations for Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) and [Define your naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming). Checked October 2026.

---

## 1. The sentence

```
<type> - <project or role> - <environment> - <owner and number>
```

Read it left to right, as words.

| Name | Reads as |
|---|---|
| `rg-tf-poc-zeon01` | **R**esource **g**roup for the **T**erraform **p**roof of **c**oncept, owned by zeon, number 1 |
| `kv-paas-zeon01` | **K**ey **v**ault for the managed-database (platform as a service) project, zeon, number 1 |
| `vnet-tf-poc` | **V**irtual **net**work for the Terraform proof of concept |
| `snet-backend` | **S**ubnet for the back end |
| `nsg-web` | **N**etwork **s**ecurity **g**roup (firewall) for the web tier |
| `vm-web-01` | **V**irtual **m**achine, web tier, number 1 |

Two kinds of names, two patterns:

| Kind | Pattern | Why | Examples |
|---|---|---|---|
| **Top level.** Must be unique across all of Azure, or is the thing you delete | `<type>-<project>-<env>-zeon01`, or `<type>-<project>-zeon01` | The `zeon01` suffix keeps it from colliding with someone else's | `rg-tf-poc-zeon01`, `kv-paas-zeon01`, `sql-paas-zeon01` |
| **Inside a group.** Only has to be unique in its group | `<type>-<role>` or `<type>-<role>-<nn>` | The group name already says which project | `snet-backend`, `nsg-web`, `vm-web-01`, `pip-web-01` |

Use a number (`-01`) only when a second one could exist. A subnet or firewall that is the only one of its kind does not need it.

---

## 2. Abbreviations

Left column is what goes in the name. "Say it as" is how to read it out loud. **Bold** rows are used in the projects so far.

| Abbreviation | Say it as | Azure resource | Example |
|---|---|---|---|
| **`rg`** | resource group | Resource group | `rg-tf-poc-zeon01` |
| **`vnet`** | virtual network | Virtual network | `vnet-tf-poc` |
| **`snet`** | subnet | Subnet | `snet-backend` |
| **`nsg`** | network security group | Network security group (firewall rules on a subnet or network card) | `nsg-web` |
| **`pip`** | public IP | Public Internet Protocol (IP) address | `pip-web-01` |
| **`nic`** | network card | Network interface | `nic-web-01` |
| **`vm`** | virtual machine | Virtual machine | `vm-web-01` |
| **`kv`** | key vault | Key Vault | `kv-paas-zeon01` |
| **`sql`** | SQL server | Azure SQL logical server | `sql-paas-zeon01` |
| **`sqldb`** | SQL database | Azure SQL database | `sqldb-app` |
| **`ng`** | NAT gateway | Network Address Translation (NAT) gateway | `ng-twotier-poc` |
| `osdisk` | operating system disk | Managed disk (operating system) | `osdisk-web-01` |
| `id` | identity | User-assigned managed identity | `id-web-01` |
| `st` | storage | Storage account. No hyphens, see section 4 | `stfileszeon01` |
| `stapp` | static web app | Static Web Apps | `stapp-portfolio-zeon01` |
| `app` | web app | App Service web app | `app-portfolio-zeon01` |
| `asp` | app service plan | App Service plan | `asp-portfolio-zeon01` |
| `log` | log workspace | Log Analytics workspace | `log-tf-poc-zeon01` |
| `appi` | app insights | Application Insights | `appi-portfolio-zeon01` |
| `rt` | route table | Route table | `rt-backend` |
| `lbe` / `lbi` | external / internal load balancer | Load balancer | `lbe-web` |
| `agw` | application gateway | Application Gateway | `agw-web` |
| `afw` | firewall | Azure Firewall (the paid service, not a network security group) | `afw-hub` |
| `bas` | bastion | Azure Bastion | `bas-hub` |
| `pep` | private endpoint | Private endpoint | `pep-sql-app` |
| `mg` | management group | Management group | `mg-sandbox` |

**One mismatch to fix.** Project 2 uses `nat-twotier-poc` for its NAT gateway. Microsoft's abbreviation is `ng`, so the standard name is `ng-twotier-poc`. Leave the published project alone. Use `ng-` from the next project on.

---

## 3. The words in the middle

Keep these short and boring. The same word means the same thing in every project.

| Slot | Words used so far | Rule |
|---|---|---|
| Project | `tf` (Terraform), `paas` (managed database), `twotier`, `staticweb` | One short word, no hyphens inside it. Matches the project folder |
| Environment | `poc` (proof of concept) | Always `poc` until there is a real second environment. Then `dev`, `test`, `prod` |
| Role | `web`, `db`, `backend`, `app` | What it does, not what it is. `web`, not `server1` |
| Owner and number | `zeon01` | Only on top-level names |
| Region | not in the name | Everything is East US. Add a region code (`eastus`, `eastus2`) only when a project spans regions. Put the region in a tag until then |

Do not put these in a name: dates, the subscription, the word `lab`, "test" when it is not a test, or anything that could change. A name cannot be changed after creation. Changing it means deleting and rebuilding. Put changeable facts in tags.

---

## 4. Character rules

- Lowercase letters, numbers, and hyphens. No spaces, no underscores in Azure names.
- Storage account: 3 to 24 characters, lowercase letters and numbers only, no hyphens, unique across Azure.
- Key vault: 3 to 24 characters, letters, numbers, and hyphens, starts with a letter, no two hyphens in a row, unique across Azure. A deleted vault keeps its name until it is purged, so the teardown script purges it.
- Check the current limits for any resource type you have not used before: [resource name rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules).

---

## 5. Variables in Terraform

Same idea: a variable name is a noun phrase that says what the value is. Write whole words. The abbreviation belongs in the Azure name, not in the code.

```
<thing>_<attribute>
```

| Variable | Reads as | Holds |
|---|---|---|
| `location` | the location | `East US` |
| `resource_group_name` | the resource group's name | `rg-tf-poc-zeon01` |
| `virtual_network_name` | the virtual network's name | `vnet-tf-poc` |
| `subnet_name` | the subnet's name | `snet-backend` |
| `network_security_group_name` | the network security group's name | `nsg-web` |
| `address_space` | the address space | `["10.2.0.0/16"]` |
| `subnet_address_prefixes` | the subnet's address prefixes | `["10.2.1.0/24"]` |
| `tags` | the tags | the tag map |

Rules:

- `snake_case`: lowercase words joined by underscores.
- End with the attribute: `_name`, `_id`, `_prefixes`, `_count`, `_enabled`.
- A list or map gets a plural or collective noun: `address_prefixes`, `tags`.
- A yes-or-no value reads as a question: `public_access_enabled`, not `public_access`.
- Resource labels (the second word in `azurerm_subnet.subnet`) are the short role: `rg`, `vnet`, `subnet`, `nsg`. Use `this` only if a file has exactly one of that type and the role is obvious.
- Every variable has a `description` written as a sentence.
- File names say what is inside: `vnet.tf`, `subnet.tf`, `nsg.tf`, `nsg_association.tf`.

## 6. Other code

| Where | Style | Example |
|---|---|---|
| Environment variables | `UPPER_SNAKE_CASE`. Keep the provider's own prefix | `ARM_SUBSCRIPTION_ID` |
| Python variables and functions | `snake_case`, verb first for functions | `read_secret()`, `vault_url` |
| Python constants | `UPPER_SNAKE_CASE` | `SECRET_NAME = "SqlAdminPassword"` |
| Shell scripts | `UPPER_SNAKE_CASE` for values, `snake_case` for functions | `VAULT_URL`, `check_group_exists` |
| Tag keys | lowercase, hyphen between words | `managed-by` |
| Tag values | lowercase | `terraform`, `poc`, `zeon` |
| Files and folders | lowercase, hyphens, project number first | `04-azure-terraform-iac-poc` |

Standard tag set on every resource group, starting with project 7 (required, no exceptions):

| Tag | Value | Why |
|---|---|---|
| `lifetime` | `1d` (or `keep` to exempt it from the nightly delete) | Consent for `envctl.sh` to delete the group |
| `owner` | `zeon` | Who to ask |
| `project` | the project folder name, for example `07-azure-terraform-pipeline-poc` | Which project made it |
| `created` | UTC time written by Terraform, ISO format | Lets the sweep skip groups under one hour old |

`environment` and `managed-by` may still be added, but the four above must always be there. Projects 1 to 5 carry the older set (`project`, `environment`, `managed-by`, `owner`) and are NOT swept at night, so tear them down with `terraform destroy`. The Terraform snippet with `ignore_changes = [tags["created"]]` is in `cloud-projects/environment-control/README.md`. Each project's verify script must check that all four tags exist.

---

## 7. Someone else running this

The names in a published repository stay this proof (`zeon01`, `owner = zeon`). A later operator does not rename those committed values. They open the files the README **Run this as yourself** table links, and they replace only the owner slot, which is their short name plus a number.

| This proof | Their copy |
|---|---|
| `rg-tf-poc-zeon01` | `rg-tf-poc-ada01` |
| `kv-paas-zeon01` | `kv-paas-ada01` |
| `sttfpipepoczeon01` | `sttfpipepocada01` (storage accounts: no hyphens) |
| `owner = zeon` | `owner = ada` |

Inside-the-group names (`snet-backend`, `nsg-web`) stay. They only have to be unique in the group, and the group name already has the owner.

Every new project ships that table. Azure projects 1 through 6 already have it. The README shape is in [DOCUMENTATION-STANDARD.md](DOCUMENTATION-STANDARD.md) section 4a.

## 8. Before you add a name

- [ ] Does it start with the Microsoft abbreviation for that resource type?
- [ ] Can you read it out loud as a sentence?
- [ ] Is it the shortest name that is still unique where it has to be?
- [ ] Top-level and globally unique? Add `zeon01` in this proof; a later operator replaces that slot only.
- [ ] No dates, no "lab", nothing that will change?
- [ ] Does every new resource group carry `lifetime`, `owner`, `project`, and `created`?
- [ ] Variable written in whole words, ending in its attribute?
- [ ] Does **Run this as yourself** link the file that holds this name?
- [ ] On Google Cloud, does the name follow section 9, including the 6-character minimum for a service account id?

---

## 9. Google Cloud

Checked October 27, 2026 against the `gcloud projects create` reference, the Resource Manager page "Create projects", and the Identity and Access Management discovery document for `CreateServiceAccountRequest`. Cloud SQL instance ids, secret ids, database names, and the Private Services Access range were checked October 28, 2026 against the Cloud SQL for PostgreSQL instance settings page, the delete-instance page, the users page, the databases page, the Secret Manager `projects.secrets.create` reference, and the Virtual Private Cloud page "Configure private services access".

Google Cloud publishes no abbreviation list. This portfolio keeps these stems so a name reads the same way from one cloud to the next:

| Stem | Say it as | Google Cloud resource | Example |
|---|---|---|---|
| `vpc` | Virtual Private Cloud | VPC network | `vpc-twotier-poc` |
| `snet` | subnet | Subnet | `snet-web` |
| `vm` | virtual machine | Compute Engine instance | `vm-web-01` |
| `sa` | service account | Service account | `sa-web` |
| `ip` | Internet Protocol address | Reserved address. External, or a global range for Private Services Access | `ip-web-01`, `ip-sql-range` |
| `router` | Cloud Router | Cloud Router | `router-paas-poc` |
| `nat` | Network Address Translation | Cloud NAT gateway | `nat-paas-poc` |
| `sql` | Cloud SQL | Cloud SQL instance | `sql-paas-zeon01-b1` |

Azure's network stem is `vnet`. On Google Cloud the same idea uses `vpc`, because that is the product name. The other stems match Azure.

Two kinds of names, same split as Azure:

| Kind | Pattern | Examples |
|---|---|---|
| **Top level.** Unique across Google Cloud, or the thing you delete | short project word, then `poc`, then the owner and a number | Project id `twotier-poc-zeon01`. A later operator replaces `zeon01` only |
| **Inside a project.** Unique in that project | stem, then role, then a number only when a second one could exist | `snet-web`, `vm-web-01`, `ip-nat-01` |

Project id rules, from the Create projects page:

- 6 to 30 characters.
- Lowercase letters, digits, and hyphens.
- Starts with a letter. Does not end with a hyphen.
- Cannot contain `google`, `ssl`, `null`, or `undefined`.
- A deleted id cannot be reused until deletion finishes, which can take 30 days. The picture's id is a placeholder. Pick a fresh one in `.env` at build time.

Display name (the human name, not the id): 4 to 30 characters. Letters, digits, spaces, hyphens, single quotes, and exclamation points. Ends with a letter or a digit. Example: `02 two tier network poc`.

Service account id, from the Identity and Access Management API: 6 to 30 characters, starting with a lowercase letter. `sa-web` fits. `sa-db` is 5 characters and does not. Do not shorten a stem to sneak under a limit. Lengthen the role (`sa-db-01`) and say so before the first create.

Labels, not tags. The same four keys as every other cloud: `lifetime`, `owner`, `project`, `created`. A label value cannot contain a colon, so `created` looks like `2026-10-26t23-45-00z`. Keys start with a lowercase letter. Values are lowercase letters, digits, hyphens, and underscores. The nightly sweep reads `lifetime=1d`.

Cloud SQL instance id, from the instance settings page: lowercase letters, digits, and hyphens, starts with a letter, 98 characters or fewer. Unique inside the project, not across Google Cloud. The PostgreSQL delete page read the same day says a deleted name can be reused immediately. The example `sql-paas-zeon01-b1` still carries an owner slot and a build number because an older rule held the name for about a week. That owner slot is not the usual "top level only" pattern. Leave it until the proof decides the name.

Secret id, from `projects.secrets.create`: unique inside the project, at most 255 characters, letters, digits, hyphens, and underscores. Example: `paas-db-password`.

Database name, from the Cloud SQL for PostgreSQL databases page: at most 64 characters. This portfolio also keeps it a plain PostgreSQL identifier, so no hyphen. Example: `appdb`. User names follow the same idea. Example: `webapp`. A built-in user created without other database roles is granted `cloudsqlsuperuser`. Assign other roles when the user must not be that.

`nat` is the product word on Google Cloud. Azure's abbreviation `ng` is not used here.

`ip-sql-range` is a global allocated range for Private Services Access, not an external address. The smallest prefix Google documents is `/24`. `/16` is the size they recommend. A one-instance proof uses `/24`. The range must not overlap a subnet.
