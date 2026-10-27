# Pins the tool versions before any Azure resource is declared.
# This root calls the shared modules. It does not declare
# storage accounts itself.

terraform {
  required_version = "~> 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 5.10.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.10.0"
    }
  }
}
