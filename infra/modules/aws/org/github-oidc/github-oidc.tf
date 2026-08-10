resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions" {
  for_each = var.github_deploy_repos

  name                 = "github-actions-${each.key}"
  assume_role_policy   = data.aws_iam_policy_document.github_actions[each.key].json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  for_each = var.github_deploy_repos

  role       = aws_iam_role.github_actions[each.key].name
  policy_arn = data.aws_iam_policy.admin_access.arn
}
