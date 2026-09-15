data "aws_cognito_user_pools" "main" {
  name = "${local.prefix}-user-pool"
}
