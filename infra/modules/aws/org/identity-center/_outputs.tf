output "identity_store_id" {
  value = local.identity_store_id
}

output "permission_set_arns" {
  value = {
    admin    = aws_ssoadmin_permission_set.admin.arn
    readonly = aws_ssoadmin_permission_set.readonly.arn
  }
}

output "group_ids" {
  value = {
    admins   = aws_identitystore_group.admins.group_id
    readonly = aws_identitystore_group.readonly.group_id
  }
}
