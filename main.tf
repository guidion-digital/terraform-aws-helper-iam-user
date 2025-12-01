locals {
  iam_path = var.namespace != null ? "/${var.namespace}/" : null
}

resource "aws_iam_user" "this" {
  name = var.username
  path = local.iam_path
}

resource "aws_iam_user_policy_attachment" "given_policy_arn" {
  for_each = toset(var.policy_arns)

  user       = aws_iam_user.this.name
  policy_arn = each.value
}

resource "aws_iam_policy" "this" {
  for_each = var.policies

  name = each.key
  path = local.iam_path

  policy = jsonencode(each.value)
}

resource "aws_iam_user_policy_attachment" "given_policy" {
  for_each = aws_iam_policy.this

  user       = aws_iam_user.this.name
  policy_arn = each.value.id
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

locals {
  access_key = {
    aws_access_key_id     = aws_iam_access_key.this.id
    aws_secret_access_key = aws_iam_access_key.this.secret
  }
}

resource "aws_secretsmanager_secret" "workspace_access_key" {
  count = var.asm_storage.enabled == true ? 1 : 0

  name                    = "${var.namespace}/${aws_iam_user.this.name}/access-key"
  recovery_window_in_days = var.asm_storage.recovery_window
}

resource "aws_secretsmanager_secret_version" "workspace_access_key" {
  count = var.asm_storage.enabled == true ? 1 : 0

  secret_id     = one(aws_secretsmanager_secret.workspace_access_key).id
  secret_string = jsonencode(local.access_key)
}

# Store IAM details in a Github environment, because var.github.environment was passed
resource "github_actions_environment_variable" "region" {
  count = var.github.repository != null && var.github.environment != null ? 1 : 0

  variable_name = "AWS_REGION"
  repository    = var.github.repository
  environment   = var.github.environment
  value         = var.region
}
resource "github_actions_environment_secret" "aws_access_key_id" {
  count = var.github.repository != null && var.github.environment != null ? 1 : 0

  secret_name     = "AWS_ACCESS_KEY_ID"
  repository      = var.github.repository
  environment     = var.github.environment
  plaintext_value = aws_iam_access_key.this.id
}
# TODO: Can be removed in next major version
moved {
  from = github_actions_environment_secret.region
  to   = github_actions_environment_secret.aws_secret_access_key
}
resource "github_actions_environment_secret" "aws_secret_access_key" {
  count = var.github.repository != null && var.github.environment != null ? 1 : 0

  secret_name     = "AWS_SECRET_ACCESS_KEY"
  repository      = var.github.repository
  environment     = var.github.environment
  plaintext_value = aws_iam_access_key.this.secret
}

# Store IAM details as repo secrets and variables, because var.github was passed
# without an environment
resource "github_actions_variable" "region" {
  count = var.github.repository != null && var.github.environment == null ? 1 : 0

  variable_name = "AWS_REGION"
  repository    = var.github.repository
  value         = var.region
}
resource "github_actions_secret" "aws_access_key_id" {
  count = var.github.repository != null && var.github.environment == null ? 1 : 0

  secret_name     = "AWS_ACCESS_KEY_ID"
  repository      = var.github.repository
  plaintext_value = aws_iam_access_key.this.id
}
resource "github_actions_secret" "region" {
  count = var.github.repository != null && var.github.environment == null ? 1 : 0

  secret_name     = "AWS_SECRET_ACCESS_KEY"
  repository      = var.github.repository
  plaintext_value = aws_iam_access_key.this.secret
}
