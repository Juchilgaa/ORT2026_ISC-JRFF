# 12 - Diagrama de arquitectura

## Diagrama general

El siguiente diagrama representa la arquitectura propuesta para la solución cloud en AWS.

```mermaid
flowchart TB
    usuario[Usuarios / Internet]

    subgraph aws[AWS - us-east-1]
        subgraph vpc[VPC 10.0.0.0/16]
            igw[Internet Gateway]

            subgraph publicas[Subredes públicas]
                pub1[Public subnet 10.0.1.0/24 - AZ A]
                pub2[Public subnet 10.0.2.0/24 - AZ B]
                alb[Application Load Balancer / Ingress]
                nat[NAT Gateway]
            end

            subgraph privadas_app[Subredes privadas de aplicación]
                app1[Private app subnet 10.0.11.0/24 - AZ A]
                app2[Private app subnet 10.0.12.0/24 - AZ B]

                subgraph eks[Amazon EKS]
                    ng[Managed Node Group]
                    svc[Kubernetes Service]
                    hpa[Horizontal Pod Autoscaler]
                    pod1[Pod Node.js replica 1]
                    pod2[Pod Node.js replica 2]
                end
            end

            subgraph privadas_db[Subredes privadas de base de datos]
                db1[Private DB subnet 10.0.21.0/24 - AZ A]
                db2[Private DB subnet 10.0.22.0/24 - AZ B]
                rds[(Amazon RDS MySQL)]
                backups[Backups automáticos RDS]
            end

            cw[CloudWatch Logs]
        end
    end

    usuario --> alb
    alb --> svc
    svc --> pod1
    svc --> pod2
    hpa --> pod1
    hpa --> pod2
    pod1 --> rds
    pod2 --> rds
    rds --> backups
    pod1 --> cw
    pod2 --> cw
    eks --> cw
    app1 --> nat
    app2 --> nat
    nat --> igw
    igw --> usuario
```

## Flujo de tráfico

1. El usuario accede desde Internet.
2. El tráfico entra por el Application Load Balancer asociado al Ingress.
3. El Ingress envía tráfico al Service de Kubernetes.
4. El Service distribuye tráfico hacia los pods Node.js.
5. Los pods se conectan a Amazon RDS MySQL por red privada.
6. RDS no está expuesto públicamente.
7. Los logs de aplicación y EKS se centralizan en CloudWatch Logs.

## Segmentación de red

| Capa | Subredes | Uso |
| --- | --- | --- |
| Pública | 10.0.1.0/24 y 10.0.2.0/24 | ALB, NAT Gateway e Internet Gateway |
| Aplicación privada | 10.0.11.0/24 y 10.0.12.0/24 | Nodos de EKS y pods |
| Base de datos privada | 10.0.21.0/24 y 10.0.22.0/24 | Amazon RDS MySQL |

## Alta disponibilidad

La arquitectura se distribuye en dos zonas de disponibilidad.

Se definen subredes públicas, privadas de aplicación y privadas de base de datos en más de una AZ, permitiendo mejorar disponibilidad y tolerancia a fallas.

## Seguridad

La base de datos se ubica en subredes privadas y no tiene acceso público.

El acceso MySQL se restringe al tráfico desde la capa de aplicación privada.

Los secretos no se almacenan en el repositorio. Se utilizan archivos de ejemplo y placeholders para evitar publicar credenciales.
