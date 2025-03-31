output "aurora_cluster_endpoint" {
  value = aws_rds_cluster.openproject.endpoint
}


output "db_subnet_group_name" {
  value = aws_db_subnet_group.openproject.name
}
output "cluster_master_username" {
  description = "Aurora PostgreSQL master username"
  value       = aws_rds_cluster.openproject.master_username
}

output "cluster_master_password" {
  description = "Aurora PostgreSQL master password"
  value       = aws_rds_cluster.openproject.master_password
  sensitive   = true
}
