
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  environment         = "development"
}

module "ecs" {
  source                  = "../../modules/ecs"
  patient_service_image   = var.patient_service_image
  appointment_service_image = var.appointment_service_image
  public_subnet_id        = module.vpc.public_subnet_id
  ecs_security_group_id   = module.iam.ecs_security_group_id
  environment             = "development"
}

module "iam" {
  source                      = "../../modules/iam"
  execution_role_policy_arn   = var.execution_role_policy_arn
  environment                 = "development"
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = "development"
}

module "alb" {
  source                = "../../modules/alb"
  security_group_id     = module.iam.alb_security_group_id
  public_subnet_id      = module.vpc.public_subnet_id
  vpc_id                = module.vpc.vpc_id
  environment           = "development"
}

