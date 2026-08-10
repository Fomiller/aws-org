# Keyed by GitHub repo name. environments lists the GitHub environments allowed
# to assume that repo's role in this account. repo_id is the numeric repo ID,
# needed for the immutable sub claim. Set in env-config.
variable "github_deploy_repos" {
  type = map(object({
    repo_id      = number
    environments = list(string)
  }))
  default = {}
}
