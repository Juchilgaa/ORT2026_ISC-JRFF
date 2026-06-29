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
  "infraestructura/modulos/ecr"
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
  ".github/workflows/validaciones.yml"

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

  "infraestructura/modulos/ecr/main.tf"
  "infraestructura/modulos/ecr/variables.tf"
  "infraestructura/modulos/ecr/outputs.tf"

  "kubernetes/namespace/namespace.yaml"
  "kubernetes/config/configmap.yaml"
  "kubernetes/config/secret.example.yaml"
  "kubernetes/app/deployment.yaml"
  "kubernetes/app/service.yaml"
  "kubernetes/app/ingress.yaml"
  "kubernetes/app/hpa.yaml"

  "scripts/validar-estructura.sh"
  "scripts/desplegar.sh"

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
    echo "ERROR: falta directorio $dir"
    exit 1
  fi
done

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: falta archivo $file"
    exit 1
  fi
done

sensitive_files="$(git ls-files | grep -E '(^|/)\.env$|(^|/)terraform\.tfvars$|(^|/)secret\.yaml$|(^|/)kubeconfig$|\.kubeconfig$|\.pem$|\.key$' || true)"

if [ -n "$sensitive_files" ]; then
  echo "ERROR: se encontraron archivos sensibles versionados:"
  echo "$sensitive_files"
  exit 1
fi

generated_files="$(git ls-files | grep -E '(^evidencias/|\.bak$|\.bkp$|\.bkp\.sh$|~$)' || true)"

if [ -n "$generated_files" ]; then
  echo "ERROR: se encontraron archivos temporales o de evidencia versionados:"
  echo "$generated_files"
  exit 1
fi

for script in scripts/validar-estructura.sh scripts/desplegar.sh; do
  if ! bash -n "$script"; then
    echo "ERROR: el script $script tiene errores de sintaxis"
    exit 1
  fi
done

if [ ! -x "scripts/desplegar.sh" ]; then
  echo "ERROR: scripts/desplegar.sh no tiene permisos de ejecución"
  echo "Solución:"
  echo "  chmod +x scripts/desplegar.sh"
  exit 1
fi

echo "OK: estructura válida"
