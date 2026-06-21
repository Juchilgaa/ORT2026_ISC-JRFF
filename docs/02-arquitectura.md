# 02 - Arquitectura

## Arquitectura propuesta

La arquitectura objetivo se despliega en AWS y utiliza servicios administrados para mejorar disponibilidad, escalabilidad, seguridad y operación.

```text
Internet
  -> Application Load Balancer / Ingress
  -> Service Kubernetes
  -> Pods Node.js en Amazon EKS
  -> Amazon RDS MySQL privado
