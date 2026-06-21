variable "project_name" {
  description = "Nombre del proyecto usado para nombrar recursos."
  type        = string
}

variable "environment" {
  description = "Nombre del ambiente."
  type        = string
}

variable "log_retention_days" {
  description = "Cantidad de días de retención de logs en CloudWatch."
  type        = number
  default     = 7
}
