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
    #
    # Repos created, renamed or transferred after 2026-07-15 get the immutable
    # sub format, which folds the owner and repo IDs into the repo segment.
    # Accept both so a rename or an opt-in doesn't lock CI out.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${local.github_owner}/*:environment:${var.environment}",
        "repo:${local.github_owner}@${local.github_owner_id}/*:environment:${var.environment}",
      ]
    }
  }

  # Some member-account stacks manage resources that live here — the
  # aws-infra-shared-services route53 unit owns hosted zones in this account
  # from a job running in dev. Those jobs chain into this role instead of
  # carrying a static key for it.
  #
  # The account principal covers anyone already in this account. It grants
  # nothing on its own: the caller still needs sts:AssumeRole.
  dynamic "statement" {
    for_each = length(var.assuming_account_ids) > 0 ? [1] : []

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type = "AWS"
        identifiers = concat(
          [for id in var.assuming_account_ids : "arn:aws:iam::${id}:role/github-actions"],
          ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"],
        )
      }
    }
  }

  # Same chain, but for a person. Running the same stack locally means a member
  # account profile for the default provider, so the Identity Center role has to
  # reach this one too. Identity Center names roles with a random suffix, so the
  # match is on the path it puts them under rather than a fixed ARN.
  dynamic "statement" {
    for_each = length(var.assuming_account_ids) > 0 ? [1] : []

    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type        = "AWS"
        identifiers = [for id in var.assuming_account_ids : "arn:aws:iam::${id}:root"]
      }

      condition {
        test     = "ArnLike"
        variable = "aws:PrincipalArn"
        values = flatten([
          for id in var.assuming_account_ids : [
            for ps in var.sso_permission_sets :
            "arn:aws:sts::${id}:assumed-role/AWSReservedSSO_${ps}_*/*"
          ]
        ])
      }
    }
  }
}
