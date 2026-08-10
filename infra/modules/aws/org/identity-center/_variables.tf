# Doppler (project aws-org, config org): ACCOUNT_ID_DEV, ACCOUNT_ID_PROD. The
# management account isn't a variable — it's the account this module applies
# into, so it comes from the caller identity.
variable "account_id_dev" {
  type = string
}

variable "account_id_prod" {
  type = string
}

# The groups are created by authentik's SCIM sync, not here, so the lookups
# below 400 with "GROUP not found" until that has run once. Permission sets
# don't depend on them and are created either way. Flip this to true (via
# Doppler: SSO_GROUPS_PROVISIONED) after the first sync to hand out access.
variable "sso_groups_provisioned" {
  type    = bool
  default = false
}
