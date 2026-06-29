#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$ROOT_DIR/infraestructura/ambientes/academy"
APP_DIR="$ROOT_DIR/aplicacion/nodejs-app"
K8S_DIR="$ROOT_DIR/kubernetes"
EVIDENCE_DIR="$ROOT_DIR/evidencias"

AWS_REGION="${AWS_REGION:-us-east-1}"
NAMESPACE="${NAMESPACE:-obligatorio-isc}"
IMAGE_TAG="${IMAGE_TAG:-$(git -C "$ROOT_DIR" rev-parse --short HEAD)}"

DB_USER="${DB_USER:-adminisc}"
DB_NAME="${DB_NAME:-obligatorio}"
DB_PASSWORD="${DB_PASSWORD:-}"

LOAD_SAMPLE_DATA="preguntar"
AUTO_APPROVE_TERRAFORM="${AUTO_APPROVE_TERRAFORM:-no}"
SOLO_CARGAR_DATOS="no"

CLUSTER_NAME=""
ECR_URL=""
DB_ENDPOINT=""
DB_HOST=""
VPC_ID=""
PUBLIC_SUBNETS=""
ALB_HOST=""

usage() {
  echo "Uso:"
  echo "  ./scripts/desplegar.sh [opciones]"
  echo
  echo "Opciones:"
  echo "  --cargar-datos        Carga datos de prueba al final del despliegue"
  echo "  --no-cargar-datos     No pregunta ni carga datos de prueba"
  echo "  --solo-cargar-datos   No despliega infraestructura; solo carga datos y prueba endpoints"
  echo "  --auto-approve        Ejecuta terraform apply -auto-approve"
  echo "  -h, --help            Muestra esta ayuda"
  echo
  echo "Variables necesarias:"
  echo "  DB_PASSWORD           Password de la base RDS"
  echo
  echo "Ejemplos:"
  echo "  export DB_PASSWORD='password_de_la_base'"
  echo "  ./scripts/desplegar.sh --cargar-datos"
  echo
  echo "  export DB_PASSWORD='password_de_la_base'"
  echo "  ./scripts/desplegar.sh --solo-cargar-datos"
}

for arg in "$@"; do
  case "$arg" in
    --cargar-datos)
      LOAD_SAMPLE_DATA="si"
      ;;
    --no-cargar-datos)
      LOAD_SAMPLE_DATA="no"
      ;;
    --solo-cargar-datos)
      SOLO_CARGAR_DATOS="si"
      LOAD_SAMPLE_DATA="si"
      ;;
    --auto-approve)
      AUTO_APPROVE_TERRAFORM="si"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: opción no reconocida: $arg"
      usage
      exit 1
      ;;
  esac
done

section() {
  echo
  echo "======================================"
  echo "$1"
  echo "======================================"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: falta instalar o configurar: $1"
    exit 1
  fi
}

validaciones_iniciales() {
  section "1 - Validaciones iniciales"

  if [ -z "$DB_PASSWORD" ]; then
    echo "ERROR: falta definir DB_PASSWORD."
    echo
    echo "Ejemplo:"
    echo "  export DB_PASSWORD='password_de_la_base'"
    echo "  ./scripts/desplegar.sh --cargar-datos"
    exit 1
  fi

  for cmd in aws terraform docker kubectl helm jq sed grep awk curl git; do
    require_cmd "$cmd"
  done

  echo "Herramientas básicas: OK"

  aws sts get-caller-identity >/dev/null
  echo "Credenciales AWS: OK"

  "$ROOT_DIR/scripts/validar-estructura.sh"
}

leer_outputs_terraform() {
  section "Leyendo datos generados por Terraform"

  CLUSTER_NAME="$(terraform -chdir="$TF_DIR" output -raw eks_cluster_name)"
  ECR_URL="$(terraform -chdir="$TF_DIR" output -raw ecr_repository_url)"
  DB_ENDPOINT="$(terraform -chdir="$TF_DIR" output -raw db_endpoint)"
  DB_HOST="$(echo "$DB_ENDPOINT" | cut -d ':' -f 1)"
  VPC_ID="$(terraform -chdir="$TF_DIR" output -raw vpc_id)"
  PUBLIC_SUBNETS="$(terraform -chdir="$TF_DIR" output -json public_subnet_ids | jq -r '.[]')"

  echo "Cluster EKS: $CLUSTER_NAME"
  echo "Repositorio ECR: $ECR_URL"
  echo "Endpoint RDS: $DB_HOST"
  echo "VPC: $VPC_ID"
  echo "Subredes públicas:"
  echo "$PUBLIC_SUBNETS"
}

actualizar_kubeconfig() {
  section "Configurando acceso a EKS"

  aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME"

  kubectl get nodes
}

wait_for_alb() {
  local ingress_name="$1"
  local namespace="$2"
  local host=""

  kubectl annotate ingress "$ingress_name" \
    -n "$namespace" \
    obligatorio-isc/reconcile="$(date +%s)" \
    --overwrite >/dev/null 2>&1 || true

  for i in $(seq 1 40); do
    host="$(kubectl get ingress "$ingress_name" \
      -n "$namespace" \
      -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)"

    if [ -n "$host" ]; then
      echo "$host"
      return 0
    fi

    echo "Esperando ADDRESS del Ingress... intento $i/40" >&2
    sleep 15
  done

  return 1
}

wait_for_healthcheck() {
  local host="$1"

  for i in $(seq 1 30); do
    if curl -fsS "http://$host/health" >/dev/null; then
      echo "Healthcheck público OK"
      return 0
    fi

    echo "ALB todavía no responde OK... intento $i/30"
    sleep 10
  done

  return 1
}

ensure_mysql_client_pod() {
  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    true
  else
    echo "Creando namespace $NAMESPACE..."
    kubectl create namespace "$NAMESPACE"
  fi

  if kubectl get pod mysql-client -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Pod mysql-client ya existe."
  else
    echo "Creando pod mysql-client para pruebas contra RDS..."
    kubectl run mysql-client \
      -n "$NAMESPACE" \
      --image=mysql:8 \
      --restart=Never \
      --command -- sleep 36000
  fi

  kubectl wait \
    --for=condition=Ready pod/mysql-client \
    -n "$NAMESPACE" \
    --timeout=180s
}

importar_schema_db() {
  section "Importando schema base de la base de datos"

  ensure_mysql_client_pod

  if [ ! -f "$APP_DIR/db.sql" ]; then
    echo "ERROR: no se encontró $APP_DIR/db.sql"
    exit 1
  fi

  echo "Importando db.sql en RDS..."
  echo "Si las tablas ya existen, mysql puede mostrar avisos, pero continúa."

  kubectl exec -i -n "$NAMESPACE" mysql-client -- \
    sh -c 'MYSQL_PWD="$1" mysql --force -h "$2" -u "$3" "$4"' \
    sh "$DB_PASSWORD" "$DB_HOST" "$DB_USER" "$DB_NAME" < "$APP_DIR/db.sql"

  echo "Schema importado/verificado."
}

load_sample_data() {
  section "Cargando datos de prueba"

  ensure_mysql_client_pod

  local seed_file
  seed_file="$(mktemp)"

  cat > "$seed_file" <<'SQL'
SET FOREIGN_KEY_CHECKS=0;

DELETE FROM cart;
DELETE FROM inventory;
DELETE FROM customers;
DELETE FROM products;

ALTER TABLE cart AUTO_INCREMENT = 1;
ALTER TABLE inventory AUTO_INCREMENT = 1;
ALTER TABLE customers AUTO_INCREMENT = 1;
ALTER TABLE products AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS=1;

INSERT INTO products (id, name, description, price) VALUES
  (1, 'Notebook Demo Cloud', 'Producto de prueba para validar la app desplegada en AWS', 1250.00),
  (2, 'Mouse Demo Cloud', 'Accesorio de prueba para validar el catalogo', 25.50);

INSERT INTO inventory (id, name, description, price, stock) VALUES
  (1, 'Notebook Demo Cloud', 'Stock de prueba en inventario', 1250.00, 10),
  (2, 'Mouse Demo Cloud', 'Stock de prueba en inventario', 25.50, 50);

INSERT INTO customers (id, name, email, password) VALUES
  (1, 'Cliente Demo', 'cliente.demo@example.com', 'demo123');

INSERT INTO cart (id, user_id, product_id, quantity) VALUES
  (1, 1, 1, 1);

SELECT COUNT(*) AS products FROM products;
SELECT COUNT(*) AS inventory FROM inventory;
SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS cart FROM cart;
SQL

  echo "Importando datos de prueba en RDS..."

  kubectl exec -i -n "$NAMESPACE" mysql-client -- \
    sh -c 'MYSQL_PWD="$1" mysql -h "$2" -u "$3" "$4"' \
    sh "$DB_PASSWORD" "$DB_HOST" "$DB_USER" "$DB_NAME" < "$seed_file"

  rm -f "$seed_file"

  echo "Datos de prueba cargados."
}

save_evidence() {
  local host="$1"

  section "Guardando evidencia"

  mkdir -p "$EVIDENCE_DIR"

  {
    echo "=== Fecha ==="
    date

    echo
    echo "=== Terraform outputs ==="
    terraform -chdir="$TF_DIR" output

    echo
    echo "=== Ingress ALB ==="
    kubectl get ingress -n "$NAMESPACE"

    echo
    echo "=== Pods ==="
    kubectl get pods -n "$NAMESPACE" -o wide

    echo
    echo "=== Service ==="
    kubectl get svc -n "$NAMESPACE"

    echo
    echo "=== HPA ==="
    kubectl get hpa -n "$NAMESPACE" || true

    echo
    echo "=== ALB en AWS ==="
    aws elbv2 describe-load-balancers \
      --region "$AWS_REGION" \
      --query "LoadBalancers[?DNSName=='$host'].[LoadBalancerName,State.Code,DNSName,Scheme,VpcId]" \
      --output table

    echo
    echo "=== Health publico por ALB ==="
    curl -s "http://$host/health"

    echo
    echo
    echo "=== Catalog publico por ALB ==="
    curl -s "http://$host/catalog"

    echo
    echo
    echo "=== Inventory publico por ALB ==="
    curl -s "http://$host/inventory"

    echo
    echo
    echo "=== Customer publico por ALB ==="
    curl -s "http://$host/customer/1" || true

    echo
    echo
    echo "=== Cart publico por ALB ==="
    curl -s "http://$host/cart/1" || true

    echo
  } | tee "$EVIDENCE_DIR/evidencia-despliegue-aws.txt"
}

probar_endpoints_publicos() {
  local host="$1"

  section "Probando endpoints públicos"

  echo "GET /health"
  curl -s "http://$host/health"
  echo

  echo "GET /catalog"
  curl -s "http://$host/catalog"
  echo

  echo "GET /inventory"
  curl -s "http://$host/inventory"
  echo

  echo "GET /customer/1"
  curl -s "http://$host/customer/1" || true
  echo

  echo "GET /cart/1"
  curl -s "http://$host/cart/1" || true
  echo
}

despliegue_completo() {
  section "Despliegue obligatorio cloud"

  echo "Region AWS: $AWS_REGION"
  echo "Namespace Kubernetes: $NAMESPACE"
  echo "Tag imagen: $IMAGE_TAG"

  validaciones_iniciales

  section "2 - Terraform init / fmt / validate"

  export TF_VAR_db_password="$DB_PASSWORD"
  export TF_VAR_db_username="$DB_USER"
  export TF_VAR_db_name="$DB_NAME"

  terraform -chdir="$TF_DIR" init -backend=false
  terraform fmt -check -recursive "$ROOT_DIR/infraestructura"
  terraform -chdir="$TF_DIR" validate

  section "3 - Terraform apply"

  if [ "$AUTO_APPROVE_TERRAFORM" = "si" ]; then
    terraform -chdir="$TF_DIR" apply -auto-approve
  else
    echo "Se va a ejecutar terraform apply."
    echo "Revisar el plan antes de confirmar."
    terraform -chdir="$TF_DIR" apply
  fi

  section "4 - Outputs Terraform"

  leer_outputs_terraform

  section "5 - Build de imagen Docker"

  docker build -t "$ECR_URL:$IMAGE_TAG" "$APP_DIR"

  section "6 - Login y push a ECR"

  ECR_REGISTRY="$(echo "$ECR_URL" | cut -d '/' -f 1)"

  aws ecr get-login-password --region "$AWS_REGION" \
    | docker login --username AWS --password-stdin "$ECR_REGISTRY"

  docker push "$ECR_URL:$IMAGE_TAG"

  section "7 - Acceso a EKS"

  actualizar_kubeconfig

  section "8 - Configurando AWS Load Balancer Controller"

  echo "Tagueando subredes públicas para uso de ALB..."

  for subnet in $PUBLIC_SUBNETS; do
    aws ec2 create-tags \
      --region "$AWS_REGION" \
      --resources "$subnet" \
      --tags Key=kubernetes.io/role/elb,Value=1 Key=kubernetes.io/cluster/$CLUSTER_NAME,Value=shared
  done

  echo "Instalando/actualizando AWS Load Balancer Controller..."

  helm repo add eks https://aws.github.io/eks-charts >/dev/null 2>&1 || true
  helm repo update

  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="$CLUSTER_NAME" \
    --set region="$AWS_REGION" \
    --set vpcId="$VPC_ID" \
    --set hostNetwork=true \
    --set serviceAccount.create=true \
    --set serviceAccount.name=aws-load-balancer-controller

  kubectl rollout status deployment/aws-load-balancer-controller \
    -n kube-system \
    --timeout=300s

  section "9 - Preparando manifiestos Kubernetes"

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

  section "10 - Aplicando Kubernetes"

  kubectl apply -f "$TMP_DIR/namespace/namespace.yaml"

  kubectl create secret generic nodejs-app-secret \
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

  section "11 - Verificando estado de Kubernetes"

  kubectl rollout status deployment/nodejs-app -n "$NAMESPACE" --timeout=300s

  kubectl get pods -n "$NAMESPACE"
  kubectl get svc -n "$NAMESPACE"
  kubectl get ingress -n "$NAMESPACE"
  kubectl get hpa -n "$NAMESPACE" || true

  section "12 - Importando schema de base de datos"

  importar_schema_db

  section "13 - Esperando endpoint público del ALB"

  ALB_HOST="$(wait_for_alb "nodejs-app-ingress" "$NAMESPACE")" || {
    echo "ERROR: el Ingress no obtuvo ADDRESS de ALB."
    echo
    echo "Revisar:"
    echo "  kubectl describe ingress nodejs-app-ingress -n $NAMESPACE"
    echo "  kubectl logs -n kube-system deployment/aws-load-balancer-controller --tail=100"
    exit 1
  }

  echo "ALB disponible: $ALB_HOST"

  section "14 - Probando healthcheck público"

  wait_for_healthcheck "$ALB_HOST" || {
    echo "ERROR: el ALB no respondió OK en /health."
    echo
    echo "Revisar:"
    echo "  kubectl describe ingress nodejs-app-ingress -n $NAMESPACE"
    echo "  kubectl get pods -n $NAMESPACE"
    echo "  kubectl logs -n $NAMESPACE deploy/nodejs-app"
    exit 1
  }

  probar_endpoints_publicos "$ALB_HOST"

  if [ "$LOAD_SAMPLE_DATA" = "preguntar" ]; then
    echo
    read -r -p "¿Querés cargar datos de prueba para demostrar la app? [s/N]: " respuesta
    case "$respuesta" in
      s|S|si|SI|Si|sí|Sí)
        LOAD_SAMPLE_DATA="si"
        ;;
      *)
        LOAD_SAMPLE_DATA="no"
        ;;
    esac
  fi

  if [ "$LOAD_SAMPLE_DATA" = "si" ]; then
    load_sample_data
    probar_endpoints_publicos "$ALB_HOST"
  else
    echo "No se cargaron datos de prueba."
  fi

  save_evidence "$ALB_HOST"
}

solo_cargar_datos() {
  section "Modo solo cargar datos"

  validaciones_iniciales
  leer_outputs_terraform
  actualizar_kubeconfig

  importar_schema_db
  load_sample_data

  ALB_HOST="$(wait_for_alb "nodejs-app-ingress" "$NAMESPACE")" || {
    echo "ERROR: el Ingress no tiene ADDRESS de ALB."
    echo "Primero ejecutá el despliegue completo."
    exit 1
  }

  echo "ALB disponible: $ALB_HOST"

  wait_for_healthcheck "$ALB_HOST" || {
    echo "ERROR: el ALB no respondió OK en /health."
    exit 1
  }

  probar_endpoints_publicos "$ALB_HOST"
  save_evidence "$ALB_HOST"
}

if [ "$SOLO_CARGAR_DATOS" = "si" ]; then
  solo_cargar_datos
else
  despliegue_completo
fi

section "Despliegue terminado"

echo "Endpoint público:"
echo "  http://$ALB_HOST/health"
echo "  http://$ALB_HOST/catalog"
echo "  http://$ALB_HOST/inventory"
echo "  http://$ALB_HOST/customer/1"
echo "  http://$ALB_HOST/cart/1"
echo
echo "Evidencia generada en:"
echo "  evidencias/evidencia-despliegue-aws.txt"
echo
echo "Para ver logs:"
echo "  kubectl logs -n $NAMESPACE deploy/nodejs-app"
echo
echo "Para ver recursos:"
echo "  kubectl get all -n $NAMESPACE"
