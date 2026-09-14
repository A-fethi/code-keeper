provider "aws" {
  region = "eu-west-3"
}

data "aws_caller_identity" "current" {}

module "S3" {
  source = "../S3"

  bucket_name = "cloud-design-dev-terraform-state-${data.aws_caller_identity.current.account_id}"

  project_name = "cloud-design"
  environment  = "dev"
}