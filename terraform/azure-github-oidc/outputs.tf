# Values the operator pipes into GitHub secrets.
# Do not print these from a workflow log.

output "application_display_name" {
  description = "Display name of the Entra app registration."
  value       = azuread_application_registration.github.display_name
}

output "application_client_id" {
  description = "Client id to store as GitHub secret AZURE_CLIENT_ID. Do not print it."
  value       = azuread_application_registration.github.client_id
  sensitive   = true
}

output "pull_request_subject" {
  description = "OpenID Connect subject for pull requests. Safe to print. Contains GitHub numeric ids, not Azure ids."
  value       = local.pull_request_subject
}

output "main_subject" {
  description = "OpenID Connect subject for the main branch. Safe to print. Contains GitHub numeric ids, not Azure ids."
  value       = local.main_subject
}
