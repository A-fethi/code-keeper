terraform {
  backend "s3" {
    bucket       = "code-keeper-dev-terraform-state-XXXXXXXXXXXXXXXX"
    key          = "terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
  }
}