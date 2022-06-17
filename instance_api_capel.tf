# Elastic IPS
resource "aws_eip" "apicapel" {
  vpc = true

  tags = {
    Name     = "IP elastica"
    Episodio = "Vision Artificial"
  }

  lifecycle {
    prevent_destroy = false
  }
}




resource "aws_instance" "apicapel" {
  count = 1
  #availability_zone      = "eu-west-1b"
  ami                    = "ami-00e7df8df28dfa791" // AMI  instancia de ubuntu en la region 
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = concat([aws_security_group.servidor_web.id], [aws_security_group.efs.id], [aws_default_security_group.default.id])
  key_name               = aws_key_pair.laptop.id

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "25"
    delete_on_termination = true
  }

  user_data = <<-EOF
                #!/bin/bash
                # ---> Updating, upgrating and installing the base
                apt update
                timedatectl set-timezone America/Santiago
                apt install python3-pip python3-opencv apt-transport-https ca-certificates curl software-properties-common nfs-common -y
                mkdir /var/lib/docker               
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
                apt update && apt upgrade -y
                apt install docker-ce -y
                systemctl status docker
                usermod -aG docker ubuntu
                
                docker run -p 80:80 --name apicapel -d fjvigil/api-capel
                (crontab -u ubuntu -l; echo "0 19 * * * wget -q -d  --no-check-certificate http://${aws_eip.apicapel.public_dns}/api/v1/populate")| crontab -u ubuntu -

                EOF

  tags = {
    Name     = "EC2 con persistencia en ${aws_subnet.public[count.index].availability_zone}"
    Episodio = "Vision Artificial"
  }


}

resource "aws_eip_association" "apicapel" {
  instance_id   = aws_instance.apicapel[0].id
  allocation_id = aws_eip.apicapel.id
}



