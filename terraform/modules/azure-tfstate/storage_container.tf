# The container that holds the state blobs.
# depends_on the operator role because Terraform cannot see
# that permission from a value. Access is private.

resource "azurerm_storage_container" "state" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"

  depends_on = [azurerm_role_assignment.operator_blob_owner]
}
