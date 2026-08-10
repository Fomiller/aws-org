data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy" "admin_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Every deploy job sets a GitHub environment, so the sub claim is
# repo:owner/name:environment:env and not a branch ref. Pinning on it keeps a
# workflow on some other branch from assuming the role.
data "aws_iam_policy_document" "github_actions" {
  for_each = var.github_deploy_repos

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Repos created, renamed or transferred after 2026-07-15 get the immutable
    # sub format, which folds the owner and repo IDs into the repo segment.
    # Accept both so a rename or an opt-in doesn't lock CI out.
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = flatten([
        for env in each.value.environments : [
          "repo:${local.github_owner}/${each.key}:environment:${env}",
          "repo:${local.github_owner}@${local.github_owner_id}/${each.key}@${each.value.repo_id}:environment:${env}",
        ]
      ])
    }
  }
}
