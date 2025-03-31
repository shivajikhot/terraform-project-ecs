#######################
# Aurora PostgreSQL Cluster
#######################
resource "aws_rds_cluster" "openproject" {
  cluster_identifier      = var.cluster_identifier
  engine                 = "aurora-postgresql"
  engine_version         = var.engine_version
  database_name          = var.database_name
  master_username        = var.master_username
  master_password        = var.master_password
  storage_encrypted      = true
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.openproject.name
  skip_final_snapshot    = true
}

#######################
# Aurora Writer Instance
#######################
resource "aws_rds_cluster_instance" "writer" {
  identifier          = "${var.cluster_identifier}-writer"
  cluster_identifier = aws_rds_cluster.openproject.id
  instance_class     = var.instance_class
  engine            = "aurora-postgresql"
}

#######################
# Aurora Reader Instance
#######################
resource "aws_rds_cluster_instance" "reader" {
  identifier          = "${var.cluster_identifier}-reader"
  cluster_identifier = aws_rds_cluster.openproject.id
  instance_class     = var.instance_class
  engine            = "aurora-postgresql"
  publicly_accessible = false
}

#######################
# DB Subnet Group
#######################
resource "aws_db_subnet_group" "openproject" {
  name       = var.db_subnet_group_name
  subnet_ids = var.db_subnet_ids
}
