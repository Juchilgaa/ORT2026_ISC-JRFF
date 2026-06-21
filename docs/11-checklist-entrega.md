# 11 - Checklist de entrega

## Repositorio

- [ ] README actualizado.
- [ ] Documentación completa en `/docs`.
- [ ] Código de aplicación en `aplicacion/nodejs-app`.
- [ ] Infraestructura Terraform en `infraestructura`.
- [ ] Manifiestos Kubernetes en `kubernetes`.
- [ ] Scripts de validación en `scripts`.
- [ ] Workflow de GitHub Actions en `.github/workflows`.

## Seguridad

- [ ] No existe `.env` versionado.
- [ ] No existe `terraform.tfvars` versionado.
- [ ] No existe `secret.yaml` real versionado.
- [ ] No existen claves `.pem` o `.key`.
- [ ] No existe kubeconfig versionado.
- [ ] Solo se versionan archivos de ejemplo.

## Validaciones

- [ ] `./scripts/validar-estructura.sh`
- [ ] `terraform fmt -recursive`
- [ ] `terraform init -backend=false`
- [ ] `terraform validate`
- [ ] Docker build de la aplicación.
- [ ] Healthcheck `/health` probado.
- [ ] GitHub Actions ejecutado correctamente en PR.

## Documentación

- [ ] Alcance.
- [ ] Arquitectura.
- [ ] Red y seguridad.
- [ ] RDS MySQL.
- [ ] Docker.
- [ ] Kubernetes.
- [ ] Monitoreo y logs.
- [ ] DevOps.
- [ ] Runbook.
- [ ] Uso de IA.
- [ ] Decisiones técnicas.

## Entrega ORT

- [ ] Exportar o comprimir el contenido del repositorio.
- [ ] Incluir PDF con URL del repositorio Git.
- [ ] Verificar que el archivo final no supere 40 MB.
- [ ] Subir a Gestión antes de la hora límite.
