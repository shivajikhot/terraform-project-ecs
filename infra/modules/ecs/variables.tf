
variable "public_subnet_ids" {
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
variable "ecr_patient_repo_url" {}
variable "ecr_appointment_repo_url" {}
