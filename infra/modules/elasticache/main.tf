resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = var.cluster_id
  engine              = "memcached"
  node_type           = var.node_type
  num_cache_nodes     = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  subnet_group_name   = aws_elasticache_subnet_group.openproject
  security_group_ids  = [var.security_group_id]
}
resource "aws_elasticache_subnet_group" "openproject" {
  name       = var.subnet_group_name
  subnet_ids = var.elasticache_subnet_ids
}
