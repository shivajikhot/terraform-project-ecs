environment = "dev"
repository_name = "openproject"
vpc_cidr            = "10.2.0.0/16"
public_subnet_cidr = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidr = ["10.2.3.0/24", "10.2.4.0/24"]
availability_zones = ["us-west-1a", "us-west-1c"]
execution_role_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
region   = "us-west-1"
#############################
cluster_identifier      = "openproject-cluster"
engine_version         = "15.3"
database_name          = "openproject"
master_username        = "postgres"
master_password        = "p4ssw0rd"
backup_retention_period = 7
preferred_backup_window = "03:00-04:00"
db_subnet_group_name   = "openproject-db-subnet-group"
instance_class         = "db.t3.medium"
#################################################
cluster_id           = "openproject-cache"
node_type           = "cache.t3.micro"
num_cache_nodes     = 1
parameter_group_name = "default.memcached1.6"
subnet_group_name = "openproject-elasticache-subnet-group"
