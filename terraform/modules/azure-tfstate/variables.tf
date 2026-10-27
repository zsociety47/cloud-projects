# Names for the shared Terraform state account.
# The bootstrap root in terraform/pipeline-foundation passes these in.
# This module does not create an Entra app. Later projects get their
# own app from terraform/modules/azure-github-oidc.

variable "location" {
  description = "Azure region for the state resource group and the storage account."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Resource group that holds the remote state storage account."
  type        = string
  default     = "rg-tfstate-zeon01"
}

variable "storage_account_name" {
  description = "Storage account for Terraform state blobs. Lowercase letters and digits only."
  type        = string
  default     = "sttfstatezeon01"
}

variable "storage_container_name" {
  description = "Blob container that holds the state files. One blob per project."
  type        = string
  default     = "tfstate"
}

variable "storage_account_tier" {
  description = "Performance tier of the state storage account."
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Replication of the state account. Locally redundant storage keeps copies in one datacenter."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Base tags. This module adds lifetime=keep and created."
  type        = map(string)
  default = {
    project = "pipeline-foundation"
    owner   = "zeon"
  }
}
