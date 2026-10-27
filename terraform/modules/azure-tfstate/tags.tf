# Standard tag contract: lifetime, owner, project, created.
# This group is keep so the nightly sweep never deletes the ledger.

locals {
  created = formatdate("YYYY-MM-DD'T'hh:mm:ss'Z'", timestamp())
  tags = merge(var.tags, {
    lifetime = "keep"
    created  = local.created
  })
}
