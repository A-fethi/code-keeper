provider "aws" {
  region = "eu-west-3"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "code-keeper-dev-terraform-state-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name        = "code-keeper-dev-terraform-state-${data.aws_caller_identity.current.account_id}"
    Project     = "code-keeper"
    Environment = "dev"
    Purpose     = "Terraform State"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# provider "aws" {
#   region = "eu-west-3"
# }

# data "aws_caller_identity" "current" {}

# module "S3" {
#   source = "../S3"

#   bucket_name = "code-keeper-dev-terraform-state-${data.aws_caller_identity.current.account_id}"

#   project_name = "code-keeper"
#   environment  = "dev"
# }
