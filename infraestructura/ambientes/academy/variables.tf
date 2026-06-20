variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto usado para nombrar recursos."
  type        = string
  default     = "obligatorio-isc"
}

variable "environment" {
  description = "Nombre del ambiente."
  type        = string
  default     = "academy"
}

variable "vpc_cidr" {
  description = "Bloque CIDR principal de la VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Zonas de disponibilidad a utilizar."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR de subredes públicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR de subredes privadas para aplicación/EKS."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR de subredes privadas para base de datos."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}
