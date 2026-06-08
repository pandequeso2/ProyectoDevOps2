# Proyecto DevOps - Etapa 2 y 3: Contenedorización, EKS y CI/CD

## Descripción del Proyecto
Este proyecto consiste en la implementación de una arquitectura de microservicios robusta y automatizada para la empresa Innovatech Chile. El objetivo principal es realizar la transición de una infraestructura tradicional hacia un modelo DevOps, utilizando la contenedorización con Docker para asegurar la portabilidad, Kubernetes (AWS EKS) para la orquestación y GitHub Actions para automatizar el ciclo de vida del software mediante pipelines de Integración y Despliegue Continuo (CI/CD).

La solución despliega un stack tecnológico compuesto por un Frontend desarrollado en React y dos microservicios de Backend (Ventas y Despachos) en Spring Boot, integrados con una base de datos MySQL con persistencia de datos.

---

## Arquitectura de la Solución
La infraestructura se ha diseñado bajo principios de seguridad y escalabilidad en AWS:
* **Redes:** Se utiliza una VPC dedicada (`despacho-ventas-vpc`) con dos subredes públicas distribuidas en diferentes zonas de disponibilidad para cumplir con la alta disponibilidad requerida por AWS EKS.
* **Seguridad:** Implementación de Security Groups personalizados (`eks-cluster-sg`) que restringen el tráfico del plano de control, aislando la lógica de negocio y aplicando el principio de mínimo privilegio.
* **Contenedorización:** Uso de Dockerfiles multi-stage para optimizar el tamaño de las imágenes, mejorar el rendimiento y garantizar la seguridad mediante usuarios no root.
* **Orquestación:** Migración de entornos locales hacia un Cluster gestionado de Kubernetes en la nube mediante **AWS EKS** (`despacho-ventas-cluster`).

---

## Componentes del Stack
* **Frontend Despacho:** Interfaz de usuario accesible en AWS mediante un servicio de tipo `LoadBalancer` en el puerto 80.
* **Backend Ventas:** Microservicio encargado de la gestión comercial (Puerto 8082).
* **Backend Despachos:** Microservicio encargado de la logística (Puerto 8081).
* **MySQL:** Motor de base de datos accesible internamente (Puerto 3306) inicializado mediante scripts automatizados vía ConfigMaps.

---

## Automatización CI/CD
Se han configurado pipelines en GitHub Actions que se activan automáticamente al realizar un push en la rama `deploy`:
1. **Build:** Construcción de imágenes Docker utilizando las mejores prácticas de capas limpias y empaquetado multi-plataforma (`linux/amd64`).
2. **Registry:** Publicación automática de las imágenes en los repositorios privados de **AWS ECR**.
3. **Deploy:** Despliegue automático de la versión actualizada en el cluster de AWS EKS.
4. **Gestión de Secretos:** Uso de GitHub Secrets para proteger credenciales de AWS (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) y tokens críticos.

---

## Requisitos Previos
Para ejecutar o colaborar en este proyecto, se requiere contar con:
* Docker Desktop con soporte para Kubernetes local (opcional).
* AWS CLI instalado y configurado de forma global.
* Herramientas de línea de comandos: `kubectl` y `terraform`.
* Visual Studio Code o IDE de preferencia.

---

## Guía de Despliegue en AWS (Experiencia 3)

Sigue estos pasos en orden cronológico para compilar, subir y desplegar la aplicación completa en la infraestructura real de AWS.

### Paso 1: Construcción de Imágenes con Docker (Multi-plataforma)
Desde la raíz del proyecto, compila las imágenes forzando la arquitectura compatible con los nodos EC2 de AWS (`linux/amd64`):

```bash
# Backend Despacho
docker build --platform linux/amd64 -t [992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-despacho:latest](https://992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-despacho:latest) -f ./backend/back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO/Dockerfile ./backend/back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO/

# Backend Ventas
docker build --platform linux/amd64 -t [992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-ventas:latest](https://992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-ventas:latest) -f ./backend/back-Ventas_SpringBoot/Springboot-API-REST/Dockerfile ./backend/back-Ventas_SpringBoot/Springboot-API-REST/

# Frontend Despacho
docker build --platform linux/amd64 -t [992382589430.dkr.ecr.us-east-1.amazonaws.com/frontend-despacho:latest](https://992382589430.dkr.ecr.us-east-1.amazonaws.com/frontend-despacho:latest) -f ./front_despacho/Dockerfile ./front_despacho/



aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382589430.dkr.ecr.us-east-1.amazonaws.com 

docker push [992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-ventas:latest](https://992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-ventas:latest)
docker push [992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-despacho:latest](https://992382589430.dkr.ecr.us-east-1.amazonaws.com/backend-despacho:latest)
docker push [992382589430.dkr.ecr.us-east-1.amazonaws.com/frontend-despacho:latest](https://992382589430.dkr.ecr.us-east-1.amazonaws.com/frontend-despacho:latest)

# Actualizar contexto
aws eks update-kubeconfig --region us-east-1 --name despacho-ventas-cluster

# Verificar conexión (Debe listar los dos nodos ip-10-0-X-X de AWS en estado Ready)
kubectl get nodes

kubectl create configmap mysql-init-config --from-file=./infra/k8s/init.sql

kubectl apply -f infra/k8s/

kubectl get pods

kubectl get svc