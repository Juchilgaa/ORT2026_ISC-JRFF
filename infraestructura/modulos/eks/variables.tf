variable "project_name" {
  description = "Nombre del proyecto usado para nombrar recursos."
  type        = string
}

variable "environment" {
  description = "Nombre del ambiente."
  type        = string
}

variable "private_app_subnet_ids" {
  description = "IDs de subredes privadas donde se desplegarán los nodos de EKS."
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "ARN del rol IAM utilizado por el cluster EKS."
  type        = string
}

variable "node_role_arn" {
  description = "ARN del rol IAM utilizado por el node group de EKS."
  type        = string
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes para el cluster EKS."
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Tipos de instancia para los nodos del node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  description = "Cantidad deseada de nodos."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Cantidad mínima de nodos."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Cantidad máxima de nodos."
  type        = number
  default     = 3
}
