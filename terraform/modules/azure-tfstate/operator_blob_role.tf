# Lets the signed-in operator create and read blobs.
# Shared keys are off, so this role is the only way in.
# On a GitHub runner current is the GitHub principal, so
# ignore principal_id and do not apply this module from GitHub.

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "operator_blob_owner" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id

  lifecycle {
    ignore_changes = [principal_id]
  }
}
