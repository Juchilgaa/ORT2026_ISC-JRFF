# 01 - Alcance

## Objetivo del proyecto

El objetivo del obligatorio es diseñar e implementar una arquitectura en AWS para una aplicación de e-commerce, contemplando componentes equivalentes a la solución original: balanceo de carga, servidores de aplicación, base de datos y respaldos.

La solución propuesta busca mejorar la arquitectura inicial mediante infraestructura automatizada con Terraform, contenedores Docker, Kubernetes sobre Amazon EKS, base de datos administrada con Amazon RDS MySQL, logs centralizados en CloudWatch y prácticas DevOps mediante ramas, Pull Requests y validaciones automáticas.

## Alcance incluido

El repositorio incluye:

- Código de aplicación Node.js / Express.
- Dockerfile para construir la imagen de la aplicación.
- Infraestructura como código con Terraform.
- VPC, subredes públicas y privadas, Internet Gateway y NAT Gateway.
- Amazon RDS MySQL privado.
- Amazon EKS y node group administrado.
- Manifiestos Kubernetes para la aplicación.
- CloudWatch Logs para aplicación y EKS.
- Scripts de validación.
- Workflow de GitHub Actions.
- Documentación técnica en Markdown.

## Alcance no incluido

No se incluyen en el repositorio:

- Credenciales reales.
- Archivos `.env` reales.
- `terraform.tfvars` real.
- Kubeconfig.
- Secret real de Kubernetes.
- Ejecución automática de `terraform apply`.
- Deploy automático en GitHub Actions.

## Integrantes

- Fferreira
- JRecalde
