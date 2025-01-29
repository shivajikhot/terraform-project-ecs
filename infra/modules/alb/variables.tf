variable "security_group_id" {
  description = "Security group ID for the ALB"
  type = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the ALB"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
