# Lets this project's GitHub principal read the state group during
# terraform plan. Reader cannot change it.

resource "azurerm_role_assignment" "github_state_reader" {
  scope                = data.azurerm_resource_group.state.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.github.object_id
}
