locals {
  name_prefix            = "${var.project_name}-${var.environment}"
  application_secret_arn = module.iam.application_secret_arn

  service_secrets = {
    gateway = {
      RABBITMQ_USER     = "${local.application_secret_arn}:rabbitmq_user::"
      RABBITMQ_PASSWORD = "${local.application_secret_arn}:rabbitmq_password::"
    }
    inventory = {
      INVENTORY_DB_USER     = "${local.application_secret_arn}:inventory_db_user::"
      INVENTORY_DB_PASSWORD = "${local.application_secret_arn}:inventory_db_password::"
      INVENTORY_DB_NAME     = "${local.application_secret_arn}:inventory_db_name::"
    }
    billing = {
      BILLING_DB_USER     = "${local.application_secret_arn}:billing_db_user::"
      BILLING_DB_PASSWORD = "${local.application_secret_arn}:billing_db_password::"
      BILLING_DB_NAME     = "${local.application_secret_arn}:billing_db_name::"
      RABBITMQ_USER       = "${local.application_secret_arn}:rabbitmq_user::"
      RABBITMQ_PASSWORD   = "${local.application_secret_arn}:rabbitmq_password::"
    }
    rabbitmq = {
      RABBITMQ_DEFAULT_USER = "${local.application_secret_arn}:rabbitmq_user::"
      RABBITMQ_DEFAULT_PASS = "${local.application_secret_arn}:rabbitmq_password::"
    }
    "inventory-db" = {
      POSTGRES_USER     = "${local.application_secret_arn}:inventory_db_user::"
      POSTGRES_PASSWORD = "${local.application_secret_arn}:inventory_db_password::"
      POSTGRES_DB       = "${local.application_secret_arn}:inventory_db_name::"
    }
    "billing-db" = {
      POSTGRES_USER     = "${local.application_secret_arn}:billing_db_user::"
      POSTGRES_PASSWORD = "${local.application_secret_arn}:billing_db_password::"
      POSTGRES_DB       = "${local.application_secret_arn}:billing_db_name::"
    }
  }
}
