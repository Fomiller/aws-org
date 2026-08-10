locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  accounts = {
    org  = data.aws_caller_identity.current.account_id
    dev  = var.account_id_dev
    prod = var.account_id_prod
  }

  roles = {
    admin = {
      permission_set_arn = aws_ssoadmin_permission_set.admin.arn
      group_id           = data.aws_identitystore_group.admins.group_id
    }
    readonly = {
      permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
      group_id           = data.aws_identitystore_group.readonly.group_id
    }
  }

  assignments = merge([
    for account, account_id in local.accounts : {
      for role, cfg in local.roles : "${account}-${role}" => merge(cfg, { account_id = account_id })
    }
  ]...)
}
