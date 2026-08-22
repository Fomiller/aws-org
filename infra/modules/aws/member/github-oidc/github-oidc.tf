resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions" {
  name                 = "github-actions"
  assume_role_policy   = data.aws_iam_policy_document.github_actions.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = data.aws_iam_policy.admin_access.arn
}

# One role for every repo that publishes an image or a chart, so a new service
# repo only has to point github.roleToAssume at this ARN. Deliberately not the
# admin role above: a publish needs ECR and nothing else.
resource "aws_iam_role" "github_actions_ecr" {
  name                 = "github-actions-ecr"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_ecr.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "github_actions_ecr" {
  name   = "ecr-publish"
  role   = aws_iam_role.github_actions_ecr.id
  policy = data.aws_iam_policy_document.ecr_publish.json
}
