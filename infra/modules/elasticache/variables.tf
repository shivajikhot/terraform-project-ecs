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
  description = "The name of the subnet group associated with the ElastiCache cluster."
  type        = string
}

variable "security_group_id" {
  description = "The security group ID(s) to associate with the ElastiCache cluster."
  type        = string
}
