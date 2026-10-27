# Names for backend.tf in later projects. Client ids are sensitive.

output "state_resource_group_name" {
  description = "Keep resource group that holds the state account."
  value       = module.tfstate.resource_group_name
}

output "storage_account_name" {
  description = "Storage account later projects put in backend.tf."
  value       = module.tfstate.storage_account_name
}

output "container_name" {
  description = "Blob container later projects put in backend.tf."
  value       = module.tfstate.container_name
}

output "application_client_ids" {
  description = "Map of project key to Entra client id. Pipe into GitHub secrets. Do not print."
  value       = { for key, mod in module.oidc : key => mod.application_client_id }
  sensitive   = true
}
