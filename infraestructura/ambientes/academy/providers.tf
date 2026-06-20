provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Proyecto    = var.project_name
      Ambiente    = var.environment
      Universidad = "ORT"
      Gestionado  = "Terraform"
    }
  }
}
