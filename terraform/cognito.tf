resource "aws_cognito_user_pool" "main" {
  name = "cloud-design-user-pool"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  tags = {
    Name = "cloud-design-user-pool"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "cloud-design-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}

data "aws_caller_identity" "current" {}

resource "aws_cognito_user_pool_client" "gateway" {
  name         = "cloud-design-gateway-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true

  allowed_oauth_flows                 = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email"]

  callback_urls = ["https://cloud-design-alb-862025879.us-east-1.elb.amazonaws.com/oauth2/idpresponse"]
  logout_urls   = ["https://cloud-design-alb-862025879.us-east-1.elb.amazonaws.com/"]

  supported_identity_providers = ["COGNITO"]
}