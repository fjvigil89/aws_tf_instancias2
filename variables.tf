variable "cidr" {
  description = "Direccion IP privados a utilizar VPC de AWS"
  default     = "192.0.0.0/20"
}

variable "ssh_pub_path" {
  description = "Direccion de las llabes ssh publica"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_priv_path" {
  description = "Direccion de las llabes ssh privada"
  default     = "~/.ssh/id_rsa"
}