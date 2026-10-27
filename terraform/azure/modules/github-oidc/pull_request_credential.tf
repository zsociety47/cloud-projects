# Trusts a GitHub Actions token from a pull request on this repository.
# The subject has to match GitHub exactly, including the owner id and
# the repository id.

resource "azuread_application_federated_identity_credential" "pull_request" {
  application_id = azuread_application_registration.github.id
  display_name   = var.pull_request_credential_name
  description    = "Pull requests can plan and test. They cannot apply."
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = local.pull_request_subject
}
