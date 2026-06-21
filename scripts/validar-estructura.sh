#!/usr/bin/env bash
set -euo pipefail

echo "======================================"
echo "Validando estructura del repositorio"
echo "======================================"

required_dirs=(
  "aplicacion/nodejs-app"
  "infraestructura/ambientes/academy"
  "infraestructura/modulos/red"
  "infraestructura/modulos/seguridad"
  "infraestructura/modulos/rds"
  "infraestructura/modulos/eks"
  "infraestructura/modulos/monitoreo"
  "kubernetes/namespace"
  "kubernetes/config"
  "kubernetes/app"
  "docs/decisiones"
  "scripts"
  ".github/workflows"
)

required_files=(
  "README.md"
  ".gitignore"
  "terraform.tfvars.example"

  "aplicacion/nodejs-app/package.json"
  "aplicacion/nodejs-app/package-lock.json"
  "aplicacion/nodejs-app/server.js"
  "aplicacion/nodejs-app/Dockerfile"
  "aplicacion/nodejs-app/.dockerignore"
  "aplicacion/nodejs-app/.env.example"
  "aplicacion/nodejs-app/db.sql"

  "infraestructura/ambientes/academy/main.tf"
  "infraestructura/ambientes/academy/variables.tf"
  "infraestructura/ambientes/academy/outputs.tf"
  "infraestructura/ambientes/academy/providers.tf"
  "infraestructura/ambientes/academy/versions.tf"

  "infraestructura/modulos/red/main.tf"
  "infraestructura/modulos/red/variables.tf"
  "infraestructura/modulos/red/outputs.tf"
  "infraestructura/modulos/rds/main.tf"
  "infraestructura/modulos/rds/variables.tf"
  "infraestructura/modulos/rds/outputs.tf"
  "infraestructura/modulos/eks/main.tf"
  "infraestructura/modulos/eks/variables.tf"
  "infraestructura/modulos/eks/outputs.tf"
  "infraestructura/modulos/monitoreo/main.tf"
  "infraestructura/modulos/monitoreo/variables.tf"
  "infraestructura/modulos/monitoreo/outputs.tf"

  "kubernetes/namespace/namespace.yaml"
  "kubernetes/config/configmap.yaml"
  "kubernetes/config/secret.example.yaml"
  "kubernetes/app/deployment.yaml"
  "kubernetes/app/service.yaml"
  "kubernetes/app/ingress.yaml"
  "kubernetes/app/hpa.yaml"

  "docs/01-alcance.md"
  "docs/02-arquitectura.md"
  "docs/03-red-seguridad.md"
  "docs/04-rds-mysql.md"
  "docs/05-docker.md"
  "docs/06-kubernetes.md"
  "docs/07-monitoreo-logs.md"
  "docs/08-devops.md"
  "docs/09-runbook.md"
  "docs/10-uso-ia.md"
  "docs/11-checklist-entrega.md"
  "docs/12-diagrama-arquitectura.md"
  "docs/decisiones/README.md"
)

for dir in "${required_dirs[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "ERROR: falta el directorio $dir"
    exit 1
  fi
done

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: falta el archivo $file"
    exit 1
  fi
done

if git ls-files | grep -E '(^|/)\.env$|(^|/)terraform\.tfvars$|\.pem$|\.key$|(^|/)kubeconfig$|\.kubeconfig$|(^|/)secret\.yaml$' >/dev/null; then
  echo "ERROR: hay archivos sensibles trackeados"
  git ls-files | grep -E '(^|/)\.env$|(^|/)terraform\.tfvars$|\.pem$|\.key$|(^|/)kubeconfig$|\.kubeconfig$|(^|/)secret\.yaml$'
  exit 1
fi

echo "OK: estructura válida"
