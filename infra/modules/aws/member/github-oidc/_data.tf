data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy" "admin_access" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy_document" "github_actions" {
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

    # Any repo under the owner, but only from a job running in this account's
    # GitHub environment. That pin is what stops a dev deploy from assuming the
    # prod role.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for o in local.github_owner_segments : "repo:${o}/*:environment:${var.environment}"]
    }
  }
}

data "aws_iam_policy_document" "github_actions_ecr" {
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

    # No environment pin here: docker-ecr.yaml and helm-ecr.yaml set no GitHub
    # environment on their jobs, so a sub written like the role above would
    # never match.
    #
    # Any branch, not just main. Those workflows take a workflow_dispatch that
    # publishes a release candidate off a feature branch, so pinning main means
    # a candidate can never be pushed. The pin bought little: only a push to
    # main and a manual run reach this role at all, a pull request never
    # authenticates, and dispatching one needs write access to the repo. So the
    # set of people who can publish is the same either way.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for o in local.github_owner_segments : "repo:${o}/*:ref:refs/heads/*"]
    }
  }
}

data "aws_iam_policy_document" "ecr_publish" {
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
  }
}
