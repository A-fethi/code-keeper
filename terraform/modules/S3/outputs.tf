output "bucket_id" {
  description = "Terraform state S3 bucket ID"
  value       = aws_s3_bucket.terraform_state.id
}

output "bucket_arn" {
  description = "Terraform state S3 bucket ARN"
  value       = aws_s3_bucket.terraform_state.arn
}

output "bucket_name" {
  description = "Terraform state S3 bucket name"
  value       = aws_s3_bucket.terraform_state.bucket
}