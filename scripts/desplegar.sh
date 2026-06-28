#!/usr/bin/env bash

# Script de despliegue del obligatorio.
#
# La idea es ordenar en un solo archivo los comandos que haríamos manualmente:
# 1. Validar el repositorio.
# 2. Aplicar Terraform.
# 3. Leer outputs de Terraform.
# 4. Construir la imagen Docker.
# 5. Subir la imagen a ECR.
# 6. Configurar kubectl contra EKS.
# 7. Crear ConfigMap, Secret y aplicar los manifiestos de Kubernetes.
#
# No se guardan passwords ni secretos en el repositorio.
# El password de la base se pasa por variable de entorno DB_PASSWORD.

set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$ROOT_DIR/infraestructura/ambientes/academy"
APP_DIR="$ROOT_DIR/aplicacion/nodejs-app"
K8S_DIR="$ROOT_DIR/kubernetes"

AWS_REGION="${AWS_REGION:-us-east-1}"
NAMESPACE="${NAMESPACE:-obligatorio-isc}"
IMAGE_TAG="${IMAGE_TAG:-$(git -C "$ROOT_DIR" rev-parse --short HEAD)}"

DB_USER="${DB_USER:-adminisc}"
DB_NAME="${DB_NAME:-obligatorio}"

echo
echo "======================================"
echo "Despliegue obligatorio cloud"
echo "======================================"
echo "Region AWS: $AWS_REGION"
echo "Namespace Kubernetes: $NAMESPACE"
echo "Tag imagen: $IMAGE_TAG"

echo
echo "======================================"
echo "1 - Validaciones iniciales"
echo "======================================"

if [ -z "$DB_PASSWORD" ]; then
  echo "ERROR: falta definir DB_PASSWORD."
  echo
  echo "Ejemplo:"
  echo "  export DB_PASSWORD='password_de_la_base'"
  echo "  ./scripts/desplegar.sh"
  exit 1
fi

for cmd in aws terraform docker kubectl sed grep awk curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: falta instalar o configurar: $cmd"
    exit 1
  fi
done

echo "Herramientas básicas: OK"

aws sts get-caller-identity >/dev/null
echo "Credenciales AWS: OK"

"$ROOT_DIR/scripts/validar-estructura.sh"

echo
echo "======================================"
echo "2 - Terraform init / fmt / validate"
echo "======================================"

export TF_VAR_db_password="$DB_PASSWORD"
export TF_VAR_db_username="$DB_USER"
export TF_VAR_db_name="$DB_NAME"

terraform -chdir="$TF_DIR" init -backend=false
terraform fmt -check -recursive "$ROOT_DIR/infraestructura"
terraform -chdir="$TF_DIR" validate

echo
echo "======================================"
echo "3 - Terraform apply"
echo "======================================"

echo "Se va a ejecutar terraform apply."
echo "Revisar el plan antes de confirmar."
terraform -chdir="$TF_DIR" apply

echo
echo "======================================"
echo "4 - Leyendo datos generados por Terraform"
echo "======================================"

CLUSTER_NAME="$(terraform -chdir="$TF_DIR" output -raw cluster_name)"
ECR_URL="$(terraform -chdir="$TF_DIR" output -raw ecr_repository_url)"
DB_ENDPOINT="$(terraform -chdir="$TF_DIR" output -raw db_endpoint)"
DB_HOST="$(echo "$DB_ENDPOINT" | cut -d ':' -f 1)"

echo "Cluster EKS: $CLUSTER_NAME"
echo "Repositorio ECR: $ECR_URL"
echo "Endpoint RDS: $DB_HOST"

echo
echo "======================================"
echo "5 - Build de imagen Docker"
echo "======================================"

docker build -t "$ECR_URL:$IMAGE_TAG" "$APP_DIR"

echo
echo "======================================"
echo "6 - Login y push a ECR"
echo "======================================"

ECR_REGISTRY="$(echo "$ECR_URL" | cut -d '/' -f 1)"

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ECR_REGISTRY"

docker push "$ECR_URL:$IMAGE_TAG"

echo
echo "======================================"
echo "7 - Configurando acceso a EKS"
echo "======================================"

aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

kubectl get nodes

echo
echo "======================================"
echo "8 - Preparando manifiestos Kubernetes"
echo "======================================"

TMP_DIR="$(mktemp -d)"
mkdir -p "$TMP_DIR/namespace" "$TMP_DIR/config" "$TMP_DIR/app"

cp "$K8S_DIR/namespace/namespace.yaml" "$TMP_DIR/namespace/namespace.yaml"

sed "s|REEMPLAZAR_ENDPOINT_RDS|$DB_HOST|g" \
  "$K8S_DIR/config/configmap.yaml" \
  > "$TMP_DIR/config/configmap.yaml"

sed "s|REEMPLAZAR_IMAGEN_ECR/nodejs-obligatorio:latest|$ECR_URL:$IMAGE_TAG|g" \
  "$K8S_DIR/app/deployment.yaml" \
  > "$TMP_DIR/app/deployment.yaml"

cp "$K8S_DIR/app/service.yaml" "$TMP_DIR/app/service.yaml"
cp "$K8S_DIR/app/ingress.yaml" "$TMP_DIR/app/ingress.yaml"
cp "$K8S_DIR/app/hpa.yaml" "$TMP_DIR/app/hpa.yaml"

echo "Manifiestos temporales generados en: $TMP_DIR"

echo
echo "======================================"
echo "9 - Aplicando Kubernetes"
echo "======================================"

kubectl apply -f "$TMP_DIR/namespace/namespace.yaml"

kubectl create secret generic nodejs-secret \
  -n "$NAMESPACE" \
  --from-literal=DB_USER="$DB_USER" \
  --from-literal=DB_PASSWORD="$DB_PASSWORD" \
  --dry-run=client -o yaml \
  | kubectl apply -f -

kubectl apply -f "$TMP_DIR/config/configmap.yaml"
kubectl apply -f "$TMP_DIR/app/deployment.yaml"
kubectl apply -f "$TMP_DIR/app/service.yaml"
kubectl apply -f "$TMP_DIR/app/ingress.yaml"
kubectl apply -f "$TMP_DIR/app/hpa.yaml"

echo
echo "======================================"
echo "10 - Verificando estado"
echo "======================================"

kubectl rollout status deployment/nodejs-app -n "$NAMESPACE" --timeout=300s

kubectl get pods -n "$NAMESPACE"
kubectl get svc -n "$NAMESPACE"
kubectl get ingress -n "$NAMESPACE"
kubectl get hpa -n "$NAMESPACE"

echo
echo "======================================"
echo "Despliegue terminado"
echo "======================================"
echo
echo "Para ver logs:"
echo "  kubectl logs -n $NAMESPACE deploy/nodejs-app"
echo
echo "Para ver el endpoint del Ingress:"
echo "  kubectl get ingress -n $NAMESPACE"
echo
echo "Si el Ingress queda sin ADDRESS, revisar que esté instalado el AWS Load Balancer Controller."
