# 08 - DevOps

## Objetivo

El proyecto se trabaja con prácticas DevOps básicas para mantener orden, trazabilidad y calidad.

## Flujo de trabajo

Se utiliza Git con ramas separadas por tarea.

Ejemplos:

```text
tarea/estructura-inicial
infra/red-vpc-subredes-nat
infra/rds-mysql-privado
infra/eks-cluster-nodegroup
k8s/app-manifests
ci/validaciones-devops
docs/infra-arquitectura
docs/app-devops-runbook
```

## Pull Requests

Cada cambio importante se entrega mediante Pull Request.

Esto permite:

- Separar responsabilidades.
- Revisar cambios antes de mergear.
- Dejar evidencia de trabajo colaborativo.
- Mantener historial claro.

## Revisión cruzada

El trabajo se divide entre:

- Fferreira.
- JRecalde.

Cada integrante revisa PRs del otro antes de mergear a `main`.

## Validaciones locales

Script principal:

```bash
./scripts/validar-estructura.sh
```

Este script valida:

- Estructura esperada del repositorio.
- Archivos obligatorios.
- Archivos de aplicación.
- Archivos Terraform.
- Manifiestos Kubernetes.
- Documentación.
- Ausencia de archivos sensibles trackeados.

## GitHub Actions

Se define el workflow:

```text
.github/workflows/validaciones.yml
```

El workflow ejecuta validaciones en Pull Requests y pushes a `main`.

Incluye:

- Validación de estructura del repositorio.
- Control de archivos sensibles.
- Terraform fmt.
- Terraform init sin backend remoto.
- Terraform validate.
- Instalación de dependencias Node.js.
- Validación de sintaxis de `server.js`.
- Build Docker de la aplicación.

## Seguridad en CI

No se ejecuta `terraform apply` en GitHub Actions.

No se cargan credenciales AWS en el pipeline.

No se publican imágenes automáticamente.

El objetivo del CI es validar calidad y estructura, no desplegar infraestructura.
