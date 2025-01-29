variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}

variable "execution_role_policy_arn" {
  description = "IAM policy ARN for ECS execution role"
  type        = string
}

variable "patient_service_image" {
  description = "ECR image URL for the patient service"
  type        = string
}

variable "appointment_service_image" {
  description = "ECR image URL for the appointment service"
  type        = string
}
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
