# ==============================================================================
# PROYECTO: INNOVATECH CHILE - EVALUACIÓN PARCIAL N°2
# DESCRIPCIÓN: INFRAESTRUCTURA PARA MICROSERVICIOS (FRONTEND, 2 BACKENDS, MYSQL)
# ASIGNATURA: INTRODUCCIÓN A HERRAMIENTAS DEVOPS
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. PROVEEDOR Y CONFIGURACIÓN INICIAL
# ------------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------------------------------
# 2. REDES (VPC, SUBREDES Y CONECTIVIDAD)
# ------------------------------------------------------------------------------
resource "aws_vpc" "devops_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-innovatech-ep2"
  }
}

# Subred Pública: Para el Frontend (Acceso desde Internet)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.devops_vpc.id
  cidr_block              = "10.0.1.0/24" # Rango de IPs para el frontend
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Zona de disponibilidad para alta disponibilidad
  tags = { Name = "subnet-public-front" }
}

# Subred Privada: Para los Backends y Base de Datos (Aislamiento de seguridad)
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.devops_vpc.id # Rango de IPs para los backends y DB
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "subnet-private-back" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops_vpc.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.devops_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------------------------------------------------------
# 3. SEGURIDAD (SECURITY GROUPS)
# ------------------------------------------------------------------------------

# SG para Frontend: Solo permite HTTP (Puerto 80)
resource "aws_security_group" "front_sg" {
  name        = "frontend-sg" 
  description = "Permitir trafico HTTP publico" # Permitir solo tráfico HTTP desde cualquier origen
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# SG para Backends: Solo permite trafico desde el SG del Frontend
resource "aws_security_group" "back_sg" {
  name        = "backend-sg"
  description = "Permitir trafico desde el frontend a los microservicios" # Permitir tráfico solo desde el SG del frontend para los puertos de los microservicios y MySQL
  vpc_id      = aws_vpc.devops_vpc.id

  # Puerto para Microservicio Despachos
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.front_sg.id]
  }

  # Puerto para Microservicio Ventas
  ingress {
    from_port       = 8083
    to_port         = 8083
    protocol        = "tcp"
    security_groups = [aws_security_group.front_sg.id]
  }

  # Acceso interno para la DB MySQL (3306)
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------------------------------------------------------------
# 4. REGISTRO DE CONTENEDORES (AWS ECR)
# ------------------------------------------------------------------------------
resource "aws_ecr_repository" "repo_front" {
  name                 = "innovatech-frontend" 
  image_tag_mutability = "MUTABLE" # Permitir mutabilidad de tags para facilitar despliegues continuos sin necesidad de crear un nuevo repositorio cada vez
}

resource "aws_ecr_repository" "repo_ventas" {
  name                 = "innovatech-back-ventas"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "repo_despachos" {
  name                 = "innovatech-back-despachos"
  image_tag_mutability = "MUTABLE"
}

# ------------------------------------------------------------------------------
# 5. INSTANCIAS EC2 CON DOCKER
# ------------------------------------------------------------------------------

# Variable para la AMI (Amazon Linux 2023)
variable "ami_id" {
  default = "ami-0e2c8ccd4e1bb2715"
}

# Instancia para el Frontend
resource "aws_instance" "frontend_srv" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.front_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo usermod -a -G docker ec2-user
              EOF

  tags = { Name = "EC2-Frontend-Innovatech" }
}

# Instancia para los 2 Backends y MySQL
resource "aws_instance" "backend_srv" {
  ami           = var.ami_id
  instance_type = "t3.small" # t3.small recomendado por el uso de 2 microservicios Java y DB
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.back_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y docker
              sudo systemctl start docker
              sudo usermod -a -G docker ec2-user
              # Instalación de Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              EOF

  tags = { Name = "EC2-Backends-Innovatech" }
}

# ------------------------------------------------------------------------------
# 6. SALIDAS (OUTPUTS)
# ------------------------------------------------------------------------------
output "frontend_public_ip" {
  value = aws_instance.frontend_srv.public_ip
  description = "IP publica para acceder al Frontend"
}

output "ecr_repository_urls" {
  value = {
    frontend  = aws_ecr_repository.repo_front.repository_url
    ventas    = aws_ecr_repository.repo_ventas.repository_url
    despachos = aws_ecr_repository.repo_despachos.repository_url
  }
}