variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type = string
}

variable "public_subnet_ids" {
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
