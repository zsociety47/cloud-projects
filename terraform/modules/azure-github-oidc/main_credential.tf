# Trusts a GitHub Actions token from a push to the main branch.
# A pull request badge does not match this subject.

resource "azuread_application_federated_identity_credential" "main" {
  application_id = azuread_application_registration.github.id
  display_name   = var.main_credential_name
  description    = "The main branch can apply. Pull requests cannot."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = local.main_subject
}
