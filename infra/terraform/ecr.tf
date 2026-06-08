resource "aws_ecr_repository" "repo_front" {
  name                 = "devops-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
  tags                 = { Name = "ecr-frontend" }
}

resource "aws_ecr_repository" "repo_ventas" {
  name                 = "devops-back-ventas"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
  tags                 = { Name = "ecr-back-ventas" }
}

resource "aws_ecr_repository" "repo_despachos" {
  name                 = "devops-back-despachos"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  image_scanning_configuration { scan_on_push = true }
  tags                 = { Name = "ecr-back-despachos" }
}