variable "vpc_id" {
  description = "VPC ID for the security group"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
