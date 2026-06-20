variable "project_name" {
  description = "Nombre del proyecto usado para nombrar recursos."
  type        = string
}

variable "environment" {
  description = "Nombre del ambiente."
  type        = string
}

variable "vpc_cidr" {
  description = "Bloque CIDR principal de la VPC."
  type        = string
}

variable "azs" {
  description = "Zonas de disponibilidad a utilizar."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR de subredes públicas."
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR de subredes privadas para aplicación/EKS."
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDR de subredes privadas para RDS."
  type        = list(string)
}
