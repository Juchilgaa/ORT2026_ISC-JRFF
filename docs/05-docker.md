# 05 - Docker

## Objetivo

La aplicación Node.js se prepara para ejecutarse dentro de un contenedor Docker.

Esto permite que la aplicación tenga un entorno de ejecución consistente, tanto en desarrollo local como en un despliegue posterior sobre Kubernetes.

## Ubicación

La aplicación se encuentra en:

```text
aplicacion/nodejs-app
```

## Archivos principales

| Archivo | Descripción |
| --- | --- |
| `package.json` | Define dependencias y script de arranque |
| `package-lock.json` | Bloquea versiones de dependencias |
| `server.js` | Punto de entrada de la aplicación |
| `Dockerfile` | Define la imagen Docker |
| `.dockerignore` | Evita copiar archivos innecesarios o sensibles |
| `.env.example` | Variables de entorno de ejemplo |

## Imagen base

El Dockerfile utiliza:

```text
node:20-alpine
```

Se eligió una imagen Alpine porque es liviana y suficiente para ejecutar una aplicación Node.js simple.

## Construcción local

Desde la carpeta de la aplicación:

```bash
cd aplicacion/nodejs-app
docker build -t nodejs-obligatorio:local .
```

## Ejecución local

```bash
docker run --rm -p 3000:3000 --env-file .env.example nodejs-obligatorio:local
```

## Healthcheck de aplicación

La aplicación expone el endpoint:

```text
/health
```

Prueba:

```bash
curl http://localhost:3000/health
```

Respuesta esperada:

```json
{
  "status": "ok",
  "service": "nodejs-obligatorio"
}
```

## Variables de entorno

La aplicación usa variables de entorno para evitar hardcodear configuración:

```text
DB_HOST
DB_USER
DB_PASSWORD
DB_NAME
APP_PORT
```

## Seguridad

No se sube `.env` al repositorio.

Se versiona únicamente:

```text
.env.example
```

como referencia para saber qué variables necesita la aplicación.
