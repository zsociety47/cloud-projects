# Reads groups and the state account that already exist.
# The pipeline resource group is created on the laptop before
# this module runs. The state account comes from terraform/azure/modules/tfstate.

data "azurerm_resource_group" "state" {
  name = var.state_resource_group_name
}

data "azurerm_resource_group" "pipeline" {
  name = var.pipeline_resource_group_name
}

data "azurerm_storage_account" "state" {
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.state.name
}
