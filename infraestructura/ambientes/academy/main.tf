data "aws_caller_identity" "current" {}

locals {
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}

module "red" {
  source = "../../modulos/red"

  project_name             = var.project_name
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
}

module "rds" {
  source = "../../modulos/rds"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.red.vpc_id
  private_db_subnet_ids = module.red.private_db_subnet_ids
  allowed_cidr_blocks   = var.private_app_subnet_cidrs

  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  multi_az          = var.db_multi_az
}

module "eks" {
  source = "../../modulos/eks"

  project_name           = var.project_name
  environment            = var.environment
  private_app_subnet_ids = module.red.private_app_subnet_ids

  cluster_role_arn = local.lab_role_arn
  node_role_arn    = local.lab_role_arn

  kubernetes_version  = var.kubernetes_version
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
}

module "monitoreo" {
  source = "../../modulos/monitoreo"

  project_name       = var.project_name
  environment        = var.environment
  log_retention_days = var.log_retention_days
}




module "ecr" {
  source = "../../modulos/ecr"

  project_name = var.project_name
  environment  = var.environment
}
