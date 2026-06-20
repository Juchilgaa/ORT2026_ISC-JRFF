# Obligatorio Implementación de Soluciones Cloud

Repositorio del obligatorio de la materia Implementación de Soluciones Cloud de ORT.

## Objetivo

Implementar una aplicación Node.js con base de datos MySQL sobre una arquitectura cloud en AWS, utilizando Terraform, Docker, Kubernetes, Amazon RDS y prácticas DevOps.

## Arquitectura resumida

```text
Internet
  -> Ingress / Load Balancer
  -> Service Kubernetes
  -> Pod Node.js
  -> RDS MySQL privado
```

## Tecnologías principales

- AWS Academy Learner Lab
- Terraform
- Docker
- Kubernetes / Amazon EKS
- Amazon RDS MySQL
- CloudWatch
- GitHub Actions

## Estructura del repositorio

```text
aplicacion/        Código fuente y Dockerfile de la aplicación
infraestructura/   Terraform para AWS
kubernetes/        Manifiestos Kubernetes
docs/              Documentación detallada
scripts/           Scripts de validación y apoyo
.github/           Workflows de CI
```

## Documentación

El detalle técnico del proyecto se encuentra en la carpeta `/docs`.

## Estado del proyecto

Proyecto iniciado. La implementación se realizará mediante ramas, commits y Pull Requests separados.

