output "cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "Nombre del Clúster EKS para su uso en kubectl"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "Endpoint de conexión de la API de Kubernetes"
}

output "mysql_private_ip" {
  value       = aws_instance.mysql_srv.private_ip
  description = "IP Privada de MySQL para configurar los archivos de Kubernetes (.yml)"
}

output "ecr_repository_urls" {
  value = {
    frontend  = aws_ecr_repository.repo_front.repository_url
    ventas    = aws_ecr_repository.repo_ventas.repository_url
    despachos = aws_ecr_repository.repo_despachos.repository_url
  }
  description = "URLs de los repositorios ECR necesarios para el Pipeline de GitHub Actions"
}