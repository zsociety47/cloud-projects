# Pins provider names for callers. The bootstrap root pins the
# exact version. This module only names the source.

terraform {
  required_version = "~> 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.10.0"
    }
  }
}
