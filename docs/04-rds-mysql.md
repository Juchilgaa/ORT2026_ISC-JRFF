# 04 - RDS MySQL

## Servicio utilizado

La base de datos se implementa con Amazon RDS MySQL.

Se eligió MySQL porque la aplicación Node.js utiliza la librería `mysql2` y el script SQL incluido está pensado para MySQL.

## Configuración principal

| Parámetro | Valor |
| --- | --- |
| Motor | MySQL |
| Acceso público | No |
| Subredes | Privadas de base de datos |
| Puerto | 3306 |
| Cifrado en reposo | Habilitado |
| Backups automáticos | Habilitados |
| Retención de backups | 7 días |
| Usuario ejemplo | adminisc |
| Base inicial ejemplo | obligatorio |

## Seguridad

RDS se crea como no público mediante:

```text
publicly_accessible = false
