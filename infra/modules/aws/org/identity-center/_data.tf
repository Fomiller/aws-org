data "aws_caller_identity" "current" {}

# Instance has been active since 2022. Identity source is the built-in
# directory, which is what makes the identitystore resources in groups.tf
# writable — under an external IdP with SCIM the store is read-only.
data "aws_ssoadmin_instances" "this" {}

# Users are created in the console (it mails them a password and MFA setup
# link), so this module only reads them. A username that doesn't exist fails
# the plan rather than half-creating a login.
data "aws_identitystore_user" "this" {
  for_each = var.sso_users

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.key
    }
  }
}
