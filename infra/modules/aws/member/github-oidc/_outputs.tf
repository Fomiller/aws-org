output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "github_actions_role_arns" {
  value = { for repo, role in aws_iam_role.github_actions : repo => role.arn }
}
