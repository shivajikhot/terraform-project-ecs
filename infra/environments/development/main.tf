provider "aws" {
  region = "us-west-1"
}

module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  environment         = var.environment
}
#module "ecs" {
#  source                  = "../../modules/ecs"
#  patient_service_image   = var.patient_service_image
#  appointment_service_image = var.appointment_service_image
#  public_subnet_id        = module.vpc.public_subnet_id
#  ecs_security_group_id   = module.iam.ecs_security_group_id
#  environment             = var.environment
#}

module "iam" {
  source                      = "../../modules/iam"
  execution_role_policy_arn   = var.execution_role_policy_arn
  vpc_id                      = module.vpc.vpc_id
  environment                 = var.environment
}

module "ecr" {
  source      = "../../modules/ecr"
  repository_name = "my-ecr-repo-${var.environment}"
  environment = var.environment
}

module "alb" {
  source                = "../../modules/alb"
  alb_security_group_id     = module.iam.alb_security_group_id
  public_subnet_id      = slice(module.vpc.public_subnet_ids, 0, 2)
  vpc_id                = module.vpc.vpc_id
  environment           = var.environment
}
