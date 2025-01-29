variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type = string
}

variable "availability_zones" {
  description = "Availability zone for the subnets"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
