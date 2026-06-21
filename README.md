# Obligatorio Implementación de Soluciones Cloud

Repositorio del obligatorio de la materia **Implementación de Soluciones Cloud** de ORT.

## Objetivo

Implementar una solución cloud en AWS para una aplicación Node.js con base de datos MySQL, utilizando infraestructura como código, contenedores, Kubernetes y buenas prácticas DevOps.

## Arquitectura resumida

```text
Internet
  -> Application Load Balancer / Ingress
  -> Service Kubernetes
  -> Pods Node.js en Amazon EKS
  -> Amazon RDS MySQL privado
```

## Tecnologías principales

- AWS Academy Learner Lab
- Terraform
- Docker
- Kubernetes / Amazon EKS
- Amazon RDS MySQL
- CloudWatch Logs
- GitHub Actions

## Estructura del repositorio

```text
aplicacion/        Código fuente y Dockerfile de la aplicación
infraestructura/   Terraform para AWS
kubernetes/        Manifiestos Kubernetes
docs/              Documentación técnica detallada
scripts/           Scripts de validación
.github/           Workflows de CI
```

## Documentación

La documentación técnica se encuentra en `/docs`:

- `01-alcance.md`
- `02-arquitectura.md`
- `03-red-seguridad.md`
- `04-rds-mysql.md`
- `05-docker.md`
- `06-kubernetes.md`
- `07-monitoreo-logs.md`
- `08-devops.md`
- `09-runbook.md`
- `10-uso-ia.md`
- `11-checklist-entrega.md`
- `decisiones/README.md`

## Validaciones principales

```bash
./scripts/validar-estructura.sh
terraform -chdir=infraestructura/ambientes/academy init -backend=false
terraform -chdir=infraestructura/ambientes/academy fmt -recursive
terraform -chdir=infraestructura/ambientes/academy validate
```

## Seguridad

No se versionan credenciales reales ni secretos.

Se utilizan archivos de ejemplo:

- `.env.example`
- `terraform.tfvars.example`
- `secret.example.yaml`

No se deben subir:

- `.env`
- `terraform.tfvars`
- `secret.yaml`
- kubeconfig
- claves `.pem` o `.key`

## Integrantes

- Fferreira
- JRecalde
