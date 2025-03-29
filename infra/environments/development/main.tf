module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zones   = var.availability_zones
  environment         = var.environment
}
module "ecs" {
  source                  = "../../modules/ecs"
  privet_subnet_ids       = module.vpc.privet_subnet_ids
  ecs_security_group_id   = module.iam.ecs_security_group_id
  environment             = var.environment
  execution_role_arn      = module.iam.ecs_execution_role_arn
  task_role_arn           = module.iam.ecs_task_role_arn
  ecr_openproject_repo_url = module.ecr_openproject_repo_url
  patient_tg_arn          = module.alb.patient_tg_arn
  region                  = var.region
  alb_dns_name            = module.alb.alb_dns_name
}

module "iam" {
  source                      = "../../modules/iam"
  execution_role_policy_arn   = var.execution_role_policy_arn
  vpc_id                      = module.vpc.vpc_id
  environment                 = var.environment
}

module "ecr" {
  source      = "../../modules/ecr"
  repository_name = "${var.environment}"
  environment = var.environment
}

module "alb" {
  source                = "../../modules/alb"
  alb_security_group_id     = module.iam.alb_security_group_id
  public_subnet_ids      = module.vpc.public_subnet_ids
  vpc_id                = module.vpc.vpc_id
  environment           = var.environment
}
