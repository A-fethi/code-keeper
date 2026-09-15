// ssm access key for RDS encryption

data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}