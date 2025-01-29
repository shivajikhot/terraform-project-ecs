variable "patient_service_image" {
  description = "Docker image for the patient service"
  type = string
}

variable "public_subnet_id" {
  description = "The public subnet ID"
  type = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
