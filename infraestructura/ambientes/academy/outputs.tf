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
