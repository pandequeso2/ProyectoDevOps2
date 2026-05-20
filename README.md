Proyecto Devops - Etapa 2: Contenedorización y CI/CD

Descripción del Proyecto

Este proyecto consiste en la implementación de una arquitectura de microservicios robusta y automatizada para la empresa Innovatech Chile. El objetivo principal es realizar la transición de una infraestructura tradicional hacia un modelo DevOps, utilizando la contenedorización con Docker para asegurar la portabilidad y GitHub Actions para automatizar el ciclo de vida del software mediante pipelines de Integración y Despliegue Continuo (CI/CD).

La solución despliega un stack tecnológico compuesto por un Frontend desarrollado en React y dos microservicios de Backend (Ventas y Despachos) en Spring Boot, integrados con una base de datos MySQL con persistencia de datos.

Arquitectura de la Solución

La infraestructura se ha diseñado bajo principios de seguridad y escalabilidad en AWS Academy:
Redes: Se utiliza una VPC con una subred pública para el acceso de usuarios al Frontend y una subred privada para aislar la lógica de negocio (Backends) y los datos (Base de Datos).

Seguridad: Implementación de Security Groups que restringen el tráfico, permitiendo que solo el Frontend se comunique con los microservicios, cumpliendo con el principio de mínimo privilegio.

Contenedorización: Uso de Dockerfiles multi-stage para optimizar el tamaño de las imágenes, mejorar el rendimiento y garantizar la seguridad mediante usuarios no root.

Componentes del Stack

El despliegue se gestiona de forma conjunta mediante un archivo docker-compose.yml que orquestra los siguientes servicios:
Frontend: Interfaz de usuario accesible vía puerto 80.

Backend Ventas: Microservicio encargado de la gestión comercial (Puerto 8083).

Backend Despachos: Microservicio encargado de la logística (Puerto 8080).

MySQL: Motor de base de datos con volúmenes de datos para asegurar la persistencia de la información tras reinicios de los contenedores.

Automatización CI/CD

Se han configurado pipelines en GitHub Actions que se activan automáticamente al realizar un push en la rama deploy:

Build: Construcción de imágenes Docker utilizando las mejores prácticas de capas limpias.

Registry: Publicación de las imágenes en AWS ECR o Docker Hub.

Deploy: Despliegue automático de la versión actualizada en las instancias Amazon EC2 correspondientes.

Gestión de Secretos: Uso de GitHub Secrets para proteger credenciales de AWS, tokens y variables de entorno críticas.

Requisitos Previos

Para ejecutar o colaborar en este proyecto, se requiere contar con:

Docker Desktop y Docker Compose.

AWS CLI configurado con acceso a un laboratorio de AWS Academy.

Visual Studio Code o IDE de preferencia.

Acceso a los repositorios de Frontend y Backend en GitHub.

Instrucciones de Uso (Local)

Clonar el repositorio.

Configurar las variables de entorno necesarias en un archivo .env.

Ejecutar el comando para levantar el stack completo:

Dentro de Bash:

docker-compose up -d --build




Acceder al Frontend a través de devops-alb-452824622.us-east-1.elb.amazonaws.com.

Desarrollado por: Francisco Díaz y Benjamin Araya

Asignatura: Introducción a Herramientas DevOps (ISY1101)

Institución: Duoc UC
