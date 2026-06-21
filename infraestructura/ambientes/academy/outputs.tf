output "vpc_id" {
  description = "ID de la VPC creada."
  value       = module.red.vpc_id
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas."
  value       = module.red.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs de las subredes privadas de aplicación."
  value       = module.red.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs de las subredes privadas de base de datos."
  value       = module.red.private_db_subnet_ids
}

output "nat_gateway_id" {
  description = "ID del NAT Gateway."
  value       = module.red.nat_gateway_id
}

output "db_endpoint" {
  description = "Endpoint privado de RDS."
  value       = module.rds.db_endpoint
}

output "db_port" {
  description = "Puerto de RDS."
  value       = module.rds.db_port
}

output "db_security_group_id" {
  description = "Security Group asociado a RDS."
  value       = module.rds.db_security_group_id
}

output "eks_cluster_name" {
  description = "Nombre del cluster EKS."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint del cluster EKS."
  value       = module.eks.cluster_endpoint
}

output "eks_node_group_name" {
  description = "Nombre del node group de EKS."
  value       = module.eks.node_group_name
}

output "app_log_group_name" {
  description = "Log group de CloudWatch para la aplicación."
  value       = module.monitoreo.app_log_group_name
}

output "eks_log_group_name" {
  description = "Log group de CloudWatch para EKS."
  value       = module.monitoreo.eks_log_group_name
}
