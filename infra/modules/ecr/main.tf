resource "aws_ecr_repository" "openproject_service_repo" {
  name = "${var.environment}-openproject_service
}
