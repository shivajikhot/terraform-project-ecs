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

variable "db_security_group_id" {
  description = "Security group ID for Aurora cluster"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "db_subnet_ids" {
  description = "List of private subnet IDs where the Aurora cluster will be deployed"
  type        = list(string)
}

variable "instance_class" {
  description = "Instance type for Aurora PostgreSQL instances"
  type        = string
  default     = "db.t3.medium"
}
