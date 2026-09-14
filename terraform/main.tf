# Networking module (VPC, subnets, NAT gateway, route tables)


module "cognito" {
  source = "./modules/cognito"

  project_name = var.project_name
  environment  = var.environment
}

module "amazon_api_gateway" {
  source = "./modules/amazon_api_gateway"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.networking.private_subnet_ids

  vpc_link_security_group_id = module.security.api_gateway_vpc_link_security_group_id

  load_balancer_listener_arn = module.ecs.load_balancer_listener_arn

  cognito_issuer = module.cognito.user_pool_endpoint

  cognito_client_id   = module.cognito.client_id
  certificate_arn     = var.certificate_arn
  backend_server_name = var.backend_server_name
}

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  availability_zones = data.aws_availability_zones.available.names
}

# Security module (security groups, IAM roles, CloudWatch log groups, service discovery)
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id
  gateway_port = var.apigateway_port
  # alb_security_group_id = module.security.alb_security_group_id
}

# iam Module

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment

  dockerhub_username = var.dockerhub_username
  dockerhub_password = var.dockerhub_password

  application_secrets = {
    rabbitmq_user         = var.rabbitmq_user
    rabbitmq_password     = var.rabbitmq_password
    inventory_db_user     = var.inventory_db_user
    inventory_db_password = var.inventory_db_password
    inventory_db_name     = var.inventory_db_name
    billing_db_user       = var.billing_db_user
    billing_db_password   = var.billing_db_password
    billing_db_name       = var.billing_db_name
  }
}

module "ecs" {
  source = "./modules/ecs"

  project_name    = var.project_name
  environment     = var.environment
  aws_region      = var.aws_region
  certificate_arn = var.certificate_arn

  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_subnet_ids        = module.networking.private_subnet_ids
  security_group_id         = module.security.ecs_security_group_id
  alb_security_group_id     = module.security.alb_security_group_id
  execution_role_arn        = module.iam.ecs_execution_role_arn
  dockerhub_credentials_arn = module.iam.dockerhub_secret_arn
  services = {
    for name, service in var.services : name => merge(service, {
      secrets = merge(service.secrets, lookup(local.service_secrets, name, {}))
    })
  }
}

module "rds" {
  source = "./modules/rds"

  vpc_id               = module.networking.vpc_id
  private_subnet_cidrs = module.networking.private_subnet_ids
  aws_security_group    = module.security.db_security_group_id

}


module "autoscaling" {
  source = "./modules/autoscaling"

  project_name = var.project_name
  environment  = var.environment

  services = var.services

  ecs_cluster_name  = module.ecs.cluster_name
  ecs_service_names = module.ecs.service_names
}

resource "aws_route53_record" "api" {
  zone_id = "Z040559436IOBPJHJZO69"
  name    = var.backend_server_name
  type    = "A"

  alias {
    name                   = module.amazon_api_gateway.custom_domain_target
    zone_id                = module.amazon_api_gateway.custom_domain_hosted_zone_id
    evaluate_target_health = true
  }
}

# module "S3" {
#   source = "./modules/S3"

#   bucket_name  = "${var.project_name}-${var.environment}-terraform-state"
#   project_name = var.project_name
#   environment  = var.environment
# }
