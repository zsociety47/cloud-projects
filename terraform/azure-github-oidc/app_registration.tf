# This project's Entra application. There is no client secret.
# A later file attaches federated credentials. AzureADMyOrg means
# only this tenant can use the application.

resource "azuread_application_registration" "github" {
  display_name     = local.application_display_name
  description      = "GitHub Actions signs in with OpenID Connect. No client secret. Repository ${var.github_repository}."
  sign_in_audience = "AzureADMyOrg"
}
