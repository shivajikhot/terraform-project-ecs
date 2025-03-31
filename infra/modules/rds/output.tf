output "aurora_cluster_endpoint" {
  value = aws_rds_cluster.openproject.endpoint
}


output "db_subnet_group_name" {
  value = aws_db_subnet_group.openproject.name
}
