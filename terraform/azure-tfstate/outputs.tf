# Names later projects put in backend.tf. Do not output
# subscription ids.

output "resource_group_name" {
  description = "Name of the keep resource group that holds the state account."
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "Name of the storage account that holds state blobs."
  value       = azurerm_storage_account.state.name
}

output "storage_account_id" {
  description = "Resource id of the state storage account. Used as a role scope. Do not print it in logs."
  value       = azurerm_storage_account.state.id
  sensitive   = true
}

output "container_name" {
  description = "Name of the blob container that holds state files."
  value       = azurerm_storage_container.state.name
}
