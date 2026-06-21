# Decisiones técnicas

## Uso de Node.js

Se eligió Node.js porque la aplicación entregada ya estaba desarrollada con Express y utiliza MySQL mediante `mysql2`.

Esto permitió adaptar la aplicación a Docker y Kubernetes sin incorporar complejidad innecesaria.

## Uso de MySQL y no PostgreSQL

Se mantiene MySQL porque:

- La aplicación usa `mysql2`.
- El archivo `db.sql` está orientado a MySQL.
- Amazon RDS ofrece MySQL como servicio administrado.
- Evita migraciones innecesarias de motor de base de datos.

## Uso de Docker

Docker permite empaquetar la aplicación y sus dependencias en una imagen reproducible.

Esto facilita la ejecución local, la validación en CI y el despliegue posterior en Kubernetes.

## Uso de Kubernetes / EKS

Se plantea Amazon EKS para ejecutar la aplicación en Kubernetes dentro de AWS.

EKS permite:

- Ejecutar pods de aplicación.
- Usar Services e Ingress.
- Escalar réplicas mediante HPA.
- Distribuir carga.
- Integrarse con servicios de AWS.

## Separación de secretos

No se hardcodean credenciales en código ni en manifiestos versionados.

Se utilizan archivos de ejemplo:

```text
.env.example
terraform.tfvars.example
secret.example.yaml
```

Los archivos reales quedan excluidos mediante `.gitignore`.

## Separación entre README y docs

El README se mantiene acotado para explicar rápidamente el objetivo, arquitectura y estructura del repositorio.

La documentación detallada se separa en `/docs` para mantener el repositorio claro y fácil de navegar.

## Pull Requests chicos

Se decidió trabajar con Pull Requests chicos y separados por tema.

Esto permite:

- Facilitar revisión cruzada.
- Dejar evidencia de colaboración.
- Reducir riesgo de errores.
- Mantener historial claro.

## Terraform modular

La infraestructura se separa en módulos:

```text
red
rds
eks
monitoreo
```

Esto mejora el orden, la reutilización y la comprensión de la solución.
