# Member accounts whose github-actions role may assume this account's, for
# stacks that run in a member account but manage resources here. Set in
# env-config.
variable "assuming_account_ids" {
  type    = list(string)
  default = []
}
