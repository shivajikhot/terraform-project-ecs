variable "patient_service_image" {
  description = "Docker image URL for the patient service"
  type = string
}

variable "public_subnet_id" {
  description = "The public subnet ID"
  type = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
