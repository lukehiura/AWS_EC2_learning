# IAM role for THIS repo's GitHub Actions (OIDC). Reuses the account-wide GitHub OIDC
# identity provider URL (one provider per account). Create that provider once (e.g. from
# AWS_IAM_learning) before enabling this role.

data "aws_caller_identity" "current" {}

data "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_github_actions_ci_role ? 1 : 0
  arn   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_ci_assume" {
  count = var.create_github_actions_ci_role ? 1 : 0

  statement {
    sid     = "GitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_actions[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_actions_repository}:*"]
    }
  }
}

resource "aws_iam_role" "github_ci" {
  count = var.create_github_actions_ci_role ? 1 : 0

  name                 = var.github_actions_role_name
  description          = "GitHub Actions OIDC for ${var.github_actions_repository}"
  assume_role_policy   = data.aws_iam_policy_document.github_ci_assume[0].json
  max_session_duration = 3600

  tags = merge(var.tags, { Name = "github-actions-ec2" })
}

resource "aws_iam_role_policy_attachment" "github_ci" {
  count = var.create_github_actions_ci_role ? 1 : 0

  role       = aws_iam_role.github_ci[0].name
  policy_arn = var.github_actions_role_policy_arn
}
