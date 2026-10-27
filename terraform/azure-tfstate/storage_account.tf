# The account that holds one state blob per project.
# Shared keys are off. Sign-in is Azure role-based access control.

resource "azurerm_storage_account" "state" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  local_user_enabled              = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [tags["created"]]
  }
}
