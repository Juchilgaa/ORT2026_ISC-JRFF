# 09 - Runbook

## Objetivo

Este runbook resume los pasos operativos para preparar, validar y desplegar la solución.

## 1. Requisitos locales

Herramientas necesarias:

```text
git
aws cli
terraform
node.js
npm
docker
kubectl
```

Versiones utilizadas o recomendadas:

```text
Terraform >= 1.6
Node.js 20
AWS Provider ~> 5.0
```

## 2. Configurar AWS Academy

Cargar credenciales temporales en:

```text
~/.aws/credentials
~/.aws/config
```

Validar identidad:

```bash
aws sts get-caller-identity
```

Validar región:

```bash
aws configure get region
```

Región esperada:

```text
us-east-1
```

## 3. Validar permisos EKS

```bash
aws eks list-clusters --region us-east-1
```

Si responde:

```json
{
  "clusters": []
}
```

significa que el servicio responde correctamente y no hay clusters creados.

## 4. Preparar variables Terraform

Copiar ejemplo:

```bash
cp terraform.tfvars.example infraestructura/ambientes/academy/terraform.tfvars
```

Editar valores reales:

```bash
nano infraestructura/ambientes/academy/terraform.tfvars
```

Nunca subir este archivo al repositorio.

## 5. Validar Terraform

```bash
terraform -chdir=infraestructura/ambientes/academy init -backend=false
terraform -chdir=infraestructura/ambientes/academy fmt -recursive
terraform -chdir=infraestructura/ambientes/academy validate
```

## 6. Plan de Terraform

```bash
terraform -chdir=infraestructura/ambientes/academy plan
```

Revisar cuidadosamente los recursos antes de aplicar.

## 7. Aplicar Terraform

Solo aplicar si el equipo aprueba el plan:

```bash
terraform -chdir=infraestructura/ambientes/academy apply
```

## 8. Configurar kubeconfig

Luego de crear EKS:

```bash
aws eks update-kubeconfig --region us-east-1 --name obligatorio-isc-academy-eks
```

Validar nodos:

```bash
kubectl get nodes
```

## 9. Preparar imagen Docker

Desde la app:

```bash
cd aplicacion/nodejs-app
docker build -t nodejs-obligatorio:local .
```

En un escenario completo, la imagen debe publicarse en un registry como Amazon ECR y luego actualizar el manifiesto `deployment.yaml`.

## 10. Crear Secret real

Tomar como base:

```text
kubernetes/config/secret.example.yaml
```

Crear un archivo local no versionado:

```text
kubernetes/config/secret.yaml
```

Aplicar:

```bash
kubectl apply -f kubernetes/config/secret.yaml
```

## 11. Aplicar Kubernetes

```bash
kubectl apply -f kubernetes/namespace/namespace.yaml
kubectl apply -f kubernetes/config/configmap.yaml
kubectl apply -f kubernetes/config/secret.yaml
kubectl apply -f kubernetes/app/deployment.yaml
kubectl apply -f kubernetes/app/service.yaml
kubectl apply -f kubernetes/app/ingress.yaml
kubectl apply -f kubernetes/app/hpa.yaml
```

## 12. Validaciones posteriores

```bash
kubectl get pods -n obligatorio-isc
kubectl get svc -n obligatorio-isc
kubectl get ingress -n obligatorio-isc
kubectl get hpa -n obligatorio-isc
```

Ver logs:

```bash
kubectl logs -n obligatorio-isc deploy/nodejs-app
```

## 13. Prueba de salud

Cuando el Ingress tenga endpoint disponible:

```bash
curl http://ENDPOINT/health
```

Respuesta esperada:

```json
{
  "status": "ok",
  "service": "nodejs-obligatorio"
}
```

## 14. Destrucción del ambiente

Para evitar costos:

```bash
terraform -chdir=infraestructura/ambientes/academy destroy
```

Ejecutar solamente si el equipo confirma que ya no se necesita el ambiente.
