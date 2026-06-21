locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/${local.name_prefix}/app/nodejs"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.name_prefix}-app-logs"
  }
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${local.name_prefix}-eks/cluster"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${local.name_prefix}-eks-logs"
  }
}
