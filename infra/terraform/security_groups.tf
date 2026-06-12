resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg-devops"
  description = "Permitir acceso seguro a MySQL desde los componentes internos de la VPC"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Solo permite conexiones originadas dentro de la VPC (EKS)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "sg-mysql-devops" }
}