# Archivo: infra/terraform/cloudwatch.tf

# 1. Data source para obtener información del clúster (necesario para IRSA)
data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.eks.name
}

data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# 2. Crear un rol IAM para el add-on (usando el mecanismo IRSA)
module "iam_assumable_role_cloudwatch" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> 5.0"
  create_role                   = true
  role_name                     = "cloudwatch-observability-role"
  provider_url                  = replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
  oidc_fully_qualified_subjects = ["system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"]
}

# 3. Adjuntar la política necesaria al rol
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
  role       = module.iam_assumable_role_cloudwatch.role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# 4. Instalar el add-on de CloudWatch Observability
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
    containerLogs = {
      enabled = true
    }
  })

  service_account_role_arn = module.iam_assumable_role_cloudwatch.iam_role_arn
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.eks,
    module.iam_assumable_role_cloudwatch
  ]
}