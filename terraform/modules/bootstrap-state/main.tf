provider "aws" {
  region = "eu-west-3"
}

data "aws_caller_identity" "current" {}

module "S3" {
  source = "../S3"

  bucket_name = "code-keeper-dev-terraform-state-${data.aws_caller_identity.current.account_id}"

  project_name = "code-keeper"
  environment  = "dev"
}