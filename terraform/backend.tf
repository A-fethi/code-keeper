terraform {
  backend "s3" {
    bucket       = "cloud-design-dev-terraform-state-XXXXXXXXXXXXXXXX"
    key          = "terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
  }
}