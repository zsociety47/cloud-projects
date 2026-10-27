# Pins provider names for callers. azuread manages the app
# registration. azurerm manages the role assignments.

terraform {
  required_version = "~> 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.10.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.10.0"
    }
  }
}
