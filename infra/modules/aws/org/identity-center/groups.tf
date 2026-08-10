resource "aws_identitystore_group" "admins" {
  identity_store_id = local.identity_store_id
  display_name      = "aws-admins"
  description       = "AdministratorAccess on org, dev and prod."
}

resource "aws_identitystore_group" "readonly" {
  identity_store_id = local.identity_store_id
  display_name      = "aws-readonly"
  description       = "ReadOnlyAccess on org, dev and prod."
}

resource "aws_identitystore_group_membership" "readonly" {
  for_each = var.sso_users

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.readonly.group_id
  member_id         = data.aws_identitystore_user.this[each.key].user_id
}

resource "aws_identitystore_group_membership" "admins" {
  for_each = toset([for username, user in var.sso_users : username if user.admin])

  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.admins.group_id
  member_id         = data.aws_identitystore_user.this[each.key].user_id
}
