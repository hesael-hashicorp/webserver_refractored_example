provider "aws" {
  region = "us-east-1"
}


module "vpc" {
  source = "./modules/vpc"
}


module "subnets" {
  source     = "./modules/subnets"
  vpc_id     = module.vpc.vpc_id
  gateway_id = module.vpc.internet_gateway_id
}


module "security_groups" {
  source = "./modules/security-groups"
  vpc_id = module.vpc.vpc_id
}


module "ec2_lb" {
  source             = "./modules/ec2-lb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_id  = module.subnets.private_subnet_id
  ec2_security_group = module.security_groups.ec2_sg
  lb_security_group  = module.security_groups.lb_sg
}

