output "app_log_group_name" {
  description = "Nombre del log group de la aplicación."
  value       = aws_cloudwatch_log_group.app.name
}

output "eks_log_group_name" {
  description = "Nombre del log group del cluster EKS."
  value       = aws_cloudwatch_log_group.eks.name
}
