# Archivo: infra/terraform/cloudwatch.tf

# Instalar el add-on de CloudWatch Observability
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "amazon-cloudwatch-observability"

  configuration_values = jsonencode({
    agent = {
      config = {
        logs = {
          metrics_collected = {
            kubernetes = {
              enhanced_container_insights = true
            }
          }
        }
      }
    }
    # containerLogs debe ser un objeto válido, no un objeto vacío {}
    containerLogs = {
      enabled = true  # Especifica la propiedad enabled
    }
  })

  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.eks
  ]
}