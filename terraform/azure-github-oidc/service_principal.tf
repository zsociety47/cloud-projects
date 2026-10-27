# The identity Azure checks when this application is assigned a role.
# client_id comes from the registration, so the application is created first.

resource "azuread_service_principal" "github" {
  client_id   = azuread_application_registration.github.client_id
  description = "Service principal for ${var.github_repository}."

  account_enabled              = true
  app_role_assignment_required = false
}
