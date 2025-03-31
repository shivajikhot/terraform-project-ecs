output "elasticache_endpoint" {
  description = "The primary endpoint of the ElastiCache cluster."
  value       = aws_elasticache_cluster.memcached.cache_nodes[0].address
}
