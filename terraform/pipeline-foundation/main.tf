# Shared state account first. Then one OpenID Connect identity
# per entry in var.projects. GitHub cannot run this root.

module "tfstate" {
  source = "../azure-tfstate"
}

module "oidc" {
  for_each = var.projects
  source   = "../azure-github-oidc"

  github_repository            = each.value.github_repository
  github_owner_id              = each.value.github_owner_id
  github_repository_id         = each.value.github_repository_id
  pipeline_resource_group_name = each.value.pipeline_resource_group_name
  state_resource_group_name    = module.tfstate.resource_group_name
  storage_account_name         = module.tfstate.storage_account_name
}
