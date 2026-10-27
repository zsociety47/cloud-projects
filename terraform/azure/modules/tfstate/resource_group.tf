# The container for the remote state storage account.
# The storage account file references this block, so Terraform
# creates the group first.

resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags

  lifecycle {
    ignore_changes = [tags["created"]]
  }
}
