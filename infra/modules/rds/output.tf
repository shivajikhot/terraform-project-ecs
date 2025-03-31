output "aurora_cluster_endpoint" {
  value = aws_rds_cluster.openproject.endpoint
}

output "aurora_writer_endpoint" {
  value = aws_rds_cluster.openproject.writer_endpoint
}

output "aurora_reader_endpoint" {
  value = aws_rds_cluster.openproject.reader_endpoint
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.openproject.name
}
