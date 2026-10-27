# Lets this project's GitHub principal read and write blobs in the
# shared state account. Data Contributor cannot change the account itself.

resource "azurerm_role_assignment" "github_blob_contributor" {
  scope                = data.azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github.object_id
}
