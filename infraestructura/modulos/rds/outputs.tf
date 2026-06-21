output "db_instance_id" {
  description = "ID de la instancia RDS."
  value       = aws_db_instance.this.id
}

output "db_endpoint" {
  description = "Endpoint de conexión a RDS."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Puerto de conexión a RDS."
  value       = aws_db_instance.this.port
}

output "db_security_group_id" {
  description = "ID del Security Group de RDS."
  value       = aws_security_group.rds.id
}

output "db_subnet_group_name" {
  description = "Nombre del DB Subnet Group."
  value       = aws_db_subnet_group.this.name
}
