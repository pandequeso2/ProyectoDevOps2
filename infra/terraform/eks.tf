# Archivo: infra/terraform/eks.tf

resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/devops-proyect-cluster/cluster" # Usa el nombre fijo o una variable
  retention_in_days = 7
}

resource "aws_eks_cluster" "eks" {
  name     = "devops-proyect-cluster"
  role_arn = data.aws_iam_role.labrole.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.private_subnet_1.id,
      aws_subnet.private_subnet_2.id
    ]
  }

  # --- MOVER ESTOS BLOQUES DENTRO DEL RESOURCE ---
  # Habilita todos los tipos de logs del plano de control
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Asegura que el log group exista antes de que el clúster intente enviar logs
  depends_on = [
    aws_cloudwatch_log_group.eks_cluster_logs
  ]
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "devops-workers"
  node_role_arn   = data.aws_iam_role.labrole.arn
  
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.small"] 
  capacity_type  = "ON_DEMAND"

  labels = {
    environment = "education"
  }

  # Dependencia explícita para que el node group se cree después del clúster
  depends_on = [
    aws_eks_cluster.eks
  ]
}