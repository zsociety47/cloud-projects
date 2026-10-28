# Names a later operator can change without editing the modules.
# The defaults are the names from my own proof of concept. Copy
# terraform.tfvars.example and use your short name in the names.

variable "owner" {
  description = "Owner tag, and the short name that goes into Azure names that have to be unique. Change this if you are not zeon."
  type        = string
  default     = "zeon"
}

variable "state_resource_group_name" {
  description = "Keep resource group that holds the shared state account. Swap in your own short name if you fork this."
  type        = string
  default     = "rg-tfstate-zeon01"
}

variable "state_storage_account_name" {
  description = "Shared storage account for Terraform state blobs. Lowercase letters and digits only. Must be unique across Azure."
  type        = string
  default     = "sttfstatezeon01"
}

# Optional map of later Azure projects that should get their own
# Entra app. Empty means only the shared state account is created.
# Add a project after its resource group exists on the laptop.

variable "projects" {
  description = "Map of GitHub repositories to onboard. Each key is a short name. Each value has github_repository, github_owner_id, github_repository_id, and pipeline_resource_group_name."
  type = map(object({
    github_repository            = string
    github_owner_id              = string
    github_repository_id         = string
    pipeline_resource_group_name = string
  }))
  default = {}
}
