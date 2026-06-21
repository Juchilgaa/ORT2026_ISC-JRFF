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

variable "db_name" {
  description = "Nombre de la base de datos inicial."
  type        = string
  default     = "obligatorio"
}

variable "db_username" {
  description = "Usuario administrador de la base de datos."
  type        = string
  default     = "adminisc"
}

variable "db_password" {
  description = "Password administrador de la base de datos."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Tipo de instancia RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Indica si RDS se despliega en modo Multi-AZ."
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para EKS."
  type        = string
  default     = "1.30"
}

variable "eks_node_instance_types" {
  description = "Tipos de instancia para el node group de EKS."
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_node_desired_size" {
  description = "Cantidad deseada de nodos EKS."
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Cantidad mínima de nodos EKS."
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Cantidad máxima de nodos EKS."
  type        = number
  default     = 3
}
