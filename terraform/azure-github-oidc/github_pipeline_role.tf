# Lets this project's GitHub principal change resources inside its
# own group. Contributor cannot create other resource groups, because
# the scope is this group, not the subscription.

resource "azurerm_role_assignment" "github_pipeline_contributor" {
  scope                = data.azurerm_resource_group.pipeline.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github.object_id
}
