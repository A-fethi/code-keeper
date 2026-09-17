locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# the API Gateway is configured to use the HTTP protocol 
# and is associated with a VPC Link that connects to an existing Application Load Balancer (ALB). The API Gateway is secured using a Cognito JWT authorizer,
# which validates incoming requests based on the Cognito User Pool configuration.

resource "aws_apigatewayv2_api" "main" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"

  description = "API Gateway for ${var.project_name}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# The Cognito JWT authorizer is used to secure the API Gateway endpoints.

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id = aws_apigatewayv2_api.main.id

  authorizer_type = "JWT"
  name            = "cognito-authorizer"

  identity_sources = [
    "$request.header.Authorization"
  ]

  jwt_configuration {
    issuer = var.cognito_issuer

    audience = [
      var.cognito_client_id
    ]
  }
}

# The VPC Link allows the API Gateway to connect to resources within a VPC, 
# such as an Application Load Balancer (ALB).

resource "aws_apigatewayv2_vpc_link" "main" {
  name = "${var.project_name}-${var.environment}-vpc-link"

  security_group_ids = [
    var.vpc_link_security_group_id
  ]

  subnet_ids = var.private_subnet_ids

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# The integration connects the API Gateway to 
# the existing Application Load Balancer (ALB) using a VPC Link.

resource "aws_apigatewayv2_integration" "alb" {
  api_id = aws_apigatewayv2_api.main.id

  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"

  connection_type = "VPC_LINK"
  connection_id   = aws_apigatewayv2_vpc_link.main.id

  integration_uri = var.load_balancer_listener_arn

  payload_format_version = "1.0"

  tls_config {
    server_name_to_verify = var.backend_server_name
  }
}


resource "aws_apigatewayv2_route" "proxy" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.alb.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "health" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "GET /health"

  target = "integrations/${aws_apigatewayv2_integration.alb.id}"

  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "root" {
  api_id = aws_apigatewayv2_api.main.id

  route_key = "ANY /"

  target = "integrations/${aws_apigatewayv2_integration.alb.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}


# The default stage is required for the API Gateway to be accessible. 
# It is automatically created and deployed when the API is created.
resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.main.id

  name = "$default"

  auto_deploy = true
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_domain_name" "main" {

  count = var.environment == "prod" ? 1 : 0

  domain_name = var.backend_server_name

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "main" {
  count = var.environment == "prod" ? 1 : 0

  api_id      = aws_apigatewayv2_api.main.id
  # domain_name = aws_apigatewayv2_domain_name.main.id
  domain_name = aws_apigatewayv2_domain_name.main[0].id
  stage       = aws_apigatewayv2_stage.default.id
}

