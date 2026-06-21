output "cluster_name" {
  description = "Nombre del cluster EKS."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint del cluster EKS."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security Group creado por EKS para el cluster."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "node_group_name" {
  description = "Nombre del node group de aplicación."
  value       = aws_eks_node_group.app.node_group_name
}
