# Signs in to Azure before any module runs.
# The subscription id is read from ARM_SUBSCRIPTION_ID.
# Do not apply this root from GitHub.

provider "azurerm" {
  resource_provider_registrations = "none"
  storage_use_azuread             = true
  features {}
}

provider "azuread" {
}
