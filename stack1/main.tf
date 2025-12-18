provider "aws" {
  region = "us-east-1"  # Change this to your desired region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "bedrock-poc-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "aurora_serverless" {
  source = "../modules/database"

  cluster_identifier = "my-aurora-serverless"
  vpc_id             = module.vpc.vpc_id 
  subnet_ids         = module.vpc.private_subnets

  # Optionally override other defaults
  database_name    = "myapp"
  master_username  = "dbadmin"
  max_capacity     = 1
  min_capacity     = 0.5
  allowed_cidr_blocks = ["10.0.0.0/16"]   
}

data "aws_caller_identity" "current" {}

locals {
  bucket_name = "bedrock-kb-${data.aws_caller_identity.current.account_id}"
}

