
variable "privet_subnet_ids" {
  description = "The public subnet ID"
  type = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "ecr_openproject_repo_url" {}
variable "region" {}
variable "alb_dns_name" {}

variable "patient_tg_arn" {
  description = "ARN of the patient service target group"
  type        = string
}

