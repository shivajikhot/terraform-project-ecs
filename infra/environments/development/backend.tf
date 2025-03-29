terraform {
  backend "s3" {
    bucket         = "terraform-backend-statefi"  
    key            = "ecs/openproject/terraform.tfstate"
    region         = "us-west-1"            
    encrypt        = true
  }
}
