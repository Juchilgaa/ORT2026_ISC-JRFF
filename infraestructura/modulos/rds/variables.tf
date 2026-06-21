variable "project_name" {
  description = "Nombre del proyecto usado para nombrar recursos."
  type        = string
}

variable "environment" {
  description = "Nombre del ambiente."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se creará RDS."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "IDs de las subredes privadas para RDS."
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "Bloques CIDR autorizados a conectarse a MySQL."
  type        = list(string)
}

variable "db_name" {
  description = "Nombre de la base de datos inicial."
  type        = string
}

variable "db_username" {
  description = "Usuario administrador de la base de datos."
  type        = string
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

variable "allocated_storage" {
  description = "Almacenamiento inicial de RDS en GB."
  type        = number
  default     = 20
}

variable "backup_retention_period" {
  description = "Cantidad de días de retención de backups automáticos."
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Indica si RDS se despliega en modo Multi-AZ."
  type        = bool
  default     = false
}
