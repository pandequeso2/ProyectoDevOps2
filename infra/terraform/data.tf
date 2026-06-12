# Consulta el rol pre-creado obligatorio de AWS Academy para asociarlo al clúster y nodos
data "aws_iam_role" "labrole" {
  name = "LabRole"
}