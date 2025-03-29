output "ecr_openproject_repo_url" {
  value = aws_ecr_repository.openproject_service_repo.repository_url
}
