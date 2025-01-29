environment = "development"
repository_name = "dev-ecr-repo"
vpc_cidr            = "10.2.0.0/16"
public_subnet_cidr  = "10.2.1.0/24"
private_subnet_cidr = "10.2.2.0/24"
availability_zone   = "us-west-1b"
execution_role_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

