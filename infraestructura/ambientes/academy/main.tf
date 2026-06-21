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


