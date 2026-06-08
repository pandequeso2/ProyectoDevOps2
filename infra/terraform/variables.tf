variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID estándar para AWS Academy"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "key_name" {
  description = "Nombre de la llave SSH por defecto en el laboratorio de AWS Academy"
  type        = string
  default     = "vockey"
}