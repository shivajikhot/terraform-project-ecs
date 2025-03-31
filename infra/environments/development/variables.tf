variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  default     = ["us-west-1b", "us-west-1c"]  # Update with the zones you want to use
}


variable "execution_role_policy_arn" {
  description = "IAM policy ARN for ECS execution role"
  type        = string
}


variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}
variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "region" {
  description = "was logsgroup region name"
  type        = string
}
#############################
variable "cluster_identifier" {
  description = "Unique name for the Aurora PostgreSQL cluster"
  type        = string
}

variable "engine_version" {
  description = "Aurora PostgreSQL engine version"
  type        = string
  default     = "15.3"
}

variable "database_name" {
  description = "Name of the initial database to be created"
  type        = string
}

variable "master_username" {
  description = "Username for the master DB user"
  type        = string
}

variable "master_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "Daily time range for taking backups (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}


variable "instance_class" {
  description = "Instance type for Aurora PostgreSQL instances"
  type        = string
  default     = "db.t3.medium"
}
#############################
variable "cluster_id" {
  description = "The unique identifier for the ElastiCache cluster."
  type        = string
}

variable "node_type" {
  description = "The compute and memory capacity of the cache nodes (e.g., cache.t3.micro, cache.t3.small, etc.)."
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "The number of cache nodes in the ElastiCache cluster. Must be greater than 0."
  type        = number
  default     = 1
}

variable "parameter_group_name" {
  description = "The name of the parameter group for the ElastiCache cluster."
  type        = string
  default     = "default.memcached1.6"
}

variable "subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}
