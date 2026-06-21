# 06 - Kubernetes

## Objetivo

La aplicación se prepara para ejecutarse en Kubernetes sobre Amazon EKS.

Kubernetes permite desplegar la aplicación en pods, escalar réplicas, realizar health checks y exponer el servicio mediante Ingress.

## Ubicación de manifiestos

Los manifiestos se encuentran en:

```text
kubernetes/
```

Estructura:

```text
kubernetes/
├── namespace/
│   └── namespace.yaml
├── config/
│   ├── configmap.yaml
│   └── secret.example.yaml
└── app/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    └── hpa.yaml
```

## Namespace

Se define un namespace dedicado:

```text
obligatorio-isc
```

Esto permite aislar los recursos del proyecto dentro del cluster.

## ConfigMap

El ConfigMap contiene variables no sensibles:

```text
APP_PORT
DB_NAME
DB_HOST
```

`DB_HOST` se deja como placeholder y debe reemplazarse por el endpoint privado de RDS.

## Secret

El repositorio incluye solamente:

```text
secret.example.yaml
```

No se sube el `secret.yaml` real.

El Secret real debe contener:

```text
DB_USER
DB_PASSWORD
```

## Deployment

El Deployment define la aplicación Node.js con:

- 2 réplicas iniciales.
- Imagen de contenedor parametrizada como placeholder.
- Variables de entorno desde ConfigMap y Secret.
- Readiness probe usando `/health`.
- Liveness probe usando `/health`.
- Requests y limits de CPU/memoria.

## Service

El Service es de tipo:

```text
ClusterIP
```

Expone internamente la aplicación en el puerto 80 y redirige al puerto 3000 del contenedor.

## Ingress

El Ingress queda preparado para integrarse con AWS Load Balancer Controller y un Application Load Balancer.

Se usa:

```text
ingressClassName: alb
```

y healthcheck en:

```text
/health
```

## HPA

Se define un HorizontalPodAutoscaler con:

| Parámetro | Valor |
| --- | --- |
| Mínimo de réplicas | 2 |
| Máximo de réplicas | 5 |
| Métrica | CPU |
| Umbral | 70% |

## Aplicación de manifiestos

Orden sugerido:

```bash
kubectl apply -f kubernetes/namespace/namespace.yaml
kubectl apply -f kubernetes/config/configmap.yaml
kubectl apply -f kubernetes/config/secret.yaml
kubectl apply -f kubernetes/app/deployment.yaml
kubectl apply -f kubernetes/app/service.yaml
kubectl apply -f kubernetes/app/ingress.yaml
kubectl apply -f kubernetes/app/hpa.yaml
```

## Importante

Antes de aplicar en un entorno real se deben reemplazar:

```text
REEMPLAZAR_ENDPOINT_RDS
REEMPLAZAR_IMAGEN_ECR
CAMBIAR_NO_SUBIR_SECRET_REAL
```

por valores reales del ambiente.
