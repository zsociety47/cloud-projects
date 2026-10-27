# One GitHub repository's identity in Azure.
# Call this module once per project from terraform/azure/pipeline-foundation.
# This module lives in terraform/azure/modules/github-oidc.
# The project's resource group must already exist. This module
# does not create resource groups. GitHub is Contributor on that
# group only. Each project gets its own Entra app.

variable "github_repository" {
  description = "GitHub repository that runs the pipeline, as owner/name."
  type        = string
}

variable "github_owner_id" {
  description = "Numeric GitHub owner id. OpenID Connect subjects include this id, not only the owner name."
  type        = string
}

variable "github_repository_id" {
  description = "Numeric GitHub repository id. OpenID Connect subjects include this id, not only the repository name."
  type        = string
}

variable "pipeline_resource_group_name" {
  description = "Resource group this project's GitHub principal may change. The group must already exist."
  type        = string
}

variable "state_resource_group_name" {
  description = "Shared resource group that holds the state storage account."
  type        = string
  default     = "rg-tfstate-zeon01"
}

variable "storage_account_name" {
  description = "Shared storage account that holds Terraform state blobs."
  type        = string
  default     = "sttfstatezeon01"
}

variable "application_display_name" {
  description = "Display name of this project's Entra app registration. Defaults to github-actions- plus the repository name."
  type        = string
  default     = ""
}

variable "pull_request_credential_name" {
  description = "Name of the federated credential that allows a pull request to plan and test."
  type        = string
  default     = "github-pull-request"
}

variable "main_credential_name" {
  description = "Name of the federated credential that allows the main branch to apply."
  type        = string
  default     = "github-main"
}

variable "main_branch_name" {
  description = "Git branch that is allowed to apply."
  type        = string
  default     = "main"
}
