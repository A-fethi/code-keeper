output "repository_urls" {
  value = {
    for name, repository in aws_ecr_repository.service :
    name => repository.repository_url
  }
}