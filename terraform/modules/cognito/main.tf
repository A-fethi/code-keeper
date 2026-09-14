locals {
  name_prefix = "${var.project_name}-${var.environment}"
}


resource "aws_cognito_user_pool" "this" {
  name = "${local.name_prefix}-users"

  # lifecycle {
  #   prevent_destroy = true
  # }
  username_attributes = ["email"]
  #   username_attributes = ["email"]

  auto_verified_attributes = ["email"]
  #   auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cognito_user" "test" {
  user_pool_id = aws_cognito_user_pool.this.id
  # lifecycle {
  #   prevent_destroy = true

  #   ignore_changes = [
  #     password
  #   ]
  # }
  username = "iichi@example.com"

  attributes = {
    email          = "iichi@example.com"
    email_verified = "true"
  }

  password = "Password123!"
}

# resource "aws_cognito_user_pool_client" "this" {
#   name = "${local.name_prefix}-client"
#   lifecycle {
#     prevent_destroy = true
#   }
#   user_pool_id = aws_cognito_user_pool.this.id

#   generate_secret = false

#   prevent_user_existence_errors = "ENABLED"
#   explicit_auth_flows = [
#     "ALLOW_USER_PASSWORD_AUTH",
#     "ALLOW_REFRESH_TOKEN_AUTH"
#   ]
# }

resource "aws_cognito_user_pool_client" "this" {
  name = "${local.name_prefix}-client"

  # lifecycle {
  #   prevent_destroy = true

  #   ignore_changes = [
  #     generate_secret
  #   ]
  # }

  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "this" {
  domain = "${local.name_prefix}-auth"
  # lifecycle {
  #   prevent_destroy = true
  # }
  user_pool_id = aws_cognito_user_pool.this.id
}
