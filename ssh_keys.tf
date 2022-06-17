# SSH Keys
resource "aws_key_pair" "laptop" {
  key_name   = "laptop_vps"
  public_key = file(var.ssh_pub_path)

  tags = {
    Name     = "laptop"
    Usuario  = "Frank J. <ago>"
    Episodio = "Informe Nube "
  }
}
