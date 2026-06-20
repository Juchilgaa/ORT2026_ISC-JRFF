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
  "docs/01-alcance.md"
  "docs/02-arquitectura.md"
  "docs/03-red-seguridad.md"
  "docs/04-rds-mysql.md"
  "docs/05-docker.md"
  "docs/06-kubernetes.md"
  "docs/07-monitoreo-logs.md"
  "docs/08-devops.md"
  "docs/09-runbook.md"
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

if git ls-files | grep -E '(^|/)\.env$|(^|/)terraform\.tfvars$|\.pem$|\.key$|(^|/)kubeconfig$|\.kubeconfig$' >/dev/null; then
  echo "ERROR: hay archivos sensibles trackeados"
  git ls-files | grep -E '(^|/)\.env$|(^|/)terraform\.tfvars$|\.pem$|\.key$|(^|/)kubeconfig$|\.kubeconfig$'
  exit 1
fi

echo "OK: estructura válida"
