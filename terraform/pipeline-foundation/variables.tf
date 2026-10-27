# Optional map of later Azure projects that should get their own
# Entra app. Empty means only the shared state account is created.
# Add a project after its resource group exists on the laptop.

variable "projects" {
  description = "Map of GitHub repositories to onboard. Each key is a short name. Each value has github_repository, github_owner_id, github_repository_id, and pipeline_resource_group_name."
  type = map(object({
    github_repository            = string
    github_owner_id              = string
    github_repository_id         = string
    pipeline_resource_group_name = string
  }))
  default = {}
}
