locals {
  name_prefix            = "${var.project_name}-${var.environment}"
  application_secret_arn = module.iam.application_secret_arn
  //inventory creds
  invntory_db_username      = module.rds.inventory_db_user
  inventory_db_password_arn = module.rds.inventory_db_password_arn
  inventory_db_host         = module.rds.inventory_db_host
  # invntory_db_password = module.rds.inventory_db_password
  // billing creds
  billing_db_username     = module.rds.billing_db_user
  billing_db_password     = module.rds.billing_db_password
  billing_db_password_arn = module.rds.billing_db_password_arn
  billing_db_host         = module.rds.billing_db_host
  service_secrets = {
    gateway = {
      RABBITMQ_USER     = "${local.application_secret_arn}:rabbitmq_user::"
      RABBITMQ_PASSWORD = "${local.application_secret_arn}:rabbitmq_password::"
    }
    inventory = {
      INVENTORY_DB_PASSWORD = local.inventory_db_password_arn
      # INVENTORY_DB_HOST     = local.inventory_db_host

      # INVENTORY_DB_USER     = "${local.application_secret_arn}:inventory_db_user::"
      # INVENTORY_DB_PASSWORD = "${local.application_secret_arn}:inventory_db_password::"
      INVENTORY_DB_NAME = "${local.application_secret_arn}:inventory_db_name::"
    }
    billing = {
      # BILLING_DB_USER     = local.billing_db_username
      BILLING_DB_PASSWORD = local.billing_db_password_arn
      # BILLING_DB_HOST     = local.billing_db_host
      # BILLING_DB_USER     = "${local.application_secret_arn}:billing_db_user::"
      # BILLING_DB_PASSWORD = "${local.application_secret_arn}:billing_db_password::"
      BILLING_DB_NAME   = "${local.application_secret_arn}:billing_db_name::"
      RABBITMQ_USER     = "${local.application_secret_arn}:rabbitmq_user::"
      RABBITMQ_PASSWORD = "${local.application_secret_arn}:rabbitmq_password::"
    }
    rabbitmq = {
      RABBITMQ_DEFAULT_USER = "${local.application_secret_arn}:rabbitmq_user::"
      RABBITMQ_DEFAULT_PASS = "${local.application_secret_arn}:rabbitmq_password::"
    }
    "inventory-db" = {
      # POSTGRES_USER     = "${local.application_secret_arn}:inventory_db_user::"
      # POSTGRES_PASSWORD = "${local.application_secret_arn}:inventory_db_password::"
      POSTGRES_USER     = local.invntory_db_username
      POSTGRES_PASSWORD = local.inventory_db_password_arn
      POSTGRES_DB       = "${local.application_secret_arn}:inventory_db_name::"
    }
    "billing-db" = {
      POSTGRES_USER     = local.billing_db_username
      POSTGRES_PASSWORD = local.billing_db_password_arn
      # POSTGRES_PASSWORD = "${local.application_secret_arn}:billing_db_password::"
      POSTGRES_DB = "${local.application_secret_arn}:billing_db_name::"
    }
  }
  service_environment = {
    inventory = {
      INVENTORY_DB_USER = local.invntory_db_username
      INVENTORY_DB_HOST = local.inventory_db_host
    }
    billing = {
      BILLING_DB_USER = local.billing_db_username
      BILLING_DB_HOST = local.billing_db_host
    }
  }
}
