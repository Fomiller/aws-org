environment = "prod"

# homelab and google-cloud-infra deploy to dev only — their workflows hardcode
# the environment instead of picking it off the branch.
github_deploy_repos = {
  aws-org = {
    repo_id      = 481284531
    environments = ["prod"]
  }
  aws-infra-shared-services = {
    repo_id      = 460241853
    environments = ["prod"]
  }
  chat-stat = {
    repo_id      = 580159451
    environments = ["prod"]
  }
  congocoon-lambda = {
    repo_id      = 722685911
    environments = ["prod"]
  }
  dungeons-and-llamas = {
    repo_id      = 863131364
    environments = ["prod"]
  }
}
