terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source             = "./modules/vpc"
  project            = var.project
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
}

module "security_groups" {
  source      = "./modules/security_groups"
  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  your_ip     = var.your_ip
}

module "ecr" {
  source      = "./modules/ecr"
  project     = var.project
  environment = var.environment
}

module "ec2" {
  source                = "./modules/ec2"
  project               = var.project
  environment           = var.environment
  subnet_id             = module.vpc.public_subnet_id
  jenkins_sg_id         = module.security_groups.jenkins_sg_id
  app_sg_id             = module.security_groups.app_sg_id
  key_name              = var.key_name
  jenkins_instance_type = var.jenkins_instance_type
  app_instance_type     = var.app_instance_type
  ecr_repository_url    = module.ecr.repository_url
  aws_region            = var.aws_region
}
