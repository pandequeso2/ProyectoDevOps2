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
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "devops-workers"
  node_role_arn   = data.aws_iam_role.labrole.arn
  
  # Despliegue seguro en la capa privada aislada de internet directo
  subnet_ids      = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

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
}