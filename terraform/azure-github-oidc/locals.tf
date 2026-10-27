# Builds the OpenID Connect subjects GitHub actually sends.
# A name-only subject (repo:owner/name) will not match.

locals {
  repository_owner = split("/", var.github_repository)[0]
  repository_name  = split("/", var.github_repository)[1]

  application_display_name = (
    var.application_display_name != ""
    ? var.application_display_name
    : "github-actions-${local.repository_name}"
  )

  pull_request_subject = "repo:${local.repository_owner}@${var.github_owner_id}/${local.repository_name}@${var.github_repository_id}:pull_request"
  main_subject         = "repo:${local.repository_owner}@${var.github_owner_id}/${local.repository_name}@${var.github_repository_id}:ref:refs/heads/${var.main_branch_name}"
}
