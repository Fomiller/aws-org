# Doppler (project aws-org, config org): ACCOUNT_ID_DEV, ACCOUNT_ID_PROD. The
# management account isn't a variable — it's the account this module applies
# into, so it comes from the caller identity.
variable "account_id_dev" {
  type = string
}

variable "account_id_prod" {
  type = string
}
