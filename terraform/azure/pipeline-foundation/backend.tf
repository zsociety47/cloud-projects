# Remote state after the first laptop apply created the account.
# Key is this root's blob. Later Azure projects use a different key.

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-zeon01"
    storage_account_name = "sttfstatezeon01"
    container_name       = "tfstate"
    key                  = "pipeline-foundation.tfstate"
    use_azuread_auth     = true
  }
}
