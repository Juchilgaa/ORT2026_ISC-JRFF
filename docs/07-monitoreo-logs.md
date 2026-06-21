# 07 - Monitoreo y logs

## Objetivo

Se agrega CloudWatch Logs como mejora de observabilidad y concentración de logs.

Esta mejora permite centralizar registros de la aplicación y del entorno EKS, facilitando diagnóstico y operación.

## Log groups definidos

| Log group | Uso |
| --- | --- |
| `/obligatorio-isc-academy/app/nodejs` | Logs de aplicación |
| `/aws/eks/obligatorio-isc-academy-eks/cluster` | Logs del cluster EKS |

## Retención

La retención de logs se parametriza mediante:

```text
log_retention_days
