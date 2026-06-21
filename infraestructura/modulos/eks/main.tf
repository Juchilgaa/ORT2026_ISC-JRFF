locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_eks_cluster" "this" {
  name     = "${local.name_prefix}-eks"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.private_app_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name = "${local.name_prefix}-eks"
  }
}

resource "aws_eks_node_group" "app" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.name_prefix}-app-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_app_subnet_ids

  instance_types = var.node_instance_types
  disk_size      = 20

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  labels = {
    rol = "app"
  }

  tags = {
    Name = "${local.name_prefix}-app-ng"
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}
