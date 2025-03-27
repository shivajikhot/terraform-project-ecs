terraform {
  backend "s3" {
    bucket         = "terraform-backend-statefi"  
    key            = "ecs/development/terraform.tfstate"
    region         = "us-east-1"            
    encrypt        = true
  }
}
