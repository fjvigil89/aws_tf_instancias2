# Elastic IPS
resource "aws_eip" "microservice" {
  vpc = true

  tags = {
    Name     = "IP elastica"
    Episodio = "Vision Artificial"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_efs_file_system" "microservice" {
  creation_token   = "microservice"
  encrypted        = true
  performance_mode = "generalPurpose"

  tags = {
    Name     = "EFS"
    Episodio = "Vision Artificial"
  }
}

resource "aws_efs_mount_target" "microservice" {
  count           = length(data.aws_availability_zones.available.zone_ids)
  file_system_id  = aws_efs_file_system.microservice.id
  subnet_id       = element(aws_subnet.privada.*.id, count.index)
  security_groups = [aws_security_group.efs.id]
}


resource "aws_instance" "microservice" {
  count = 1
  #availability_zone      = "eu-west-1b"
  ami                    = "ami-00e7df8df28dfa791" // AMI  instancia de ubuntu en la region 
  instance_type          = "t2.micro"
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
                apt install python3-pip python3-opencv apt-transport-https ca-certificates curl software-properties-common nfs-common -y
                mkdir /var/lib/docker
                echo "${aws_efs_file_system.microservice.dns_name}:/  /var/lib/docker    nfs4   nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 2" >> /etc/fstab
                mount -a
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
                apt update && apt upgrade -y
                apt install docker-ce -y
                systemctl status docker
                usermod -aG docker ubuntu
                #---docker run -p 80:80 -d nginxdemos/hello
                sudo docker run -p 80:80 -d fjvigil/b2b_api

                EOF

  tags = {
    Name     = "EC2 con persistencia en ${aws_subnet.public[count.index].availability_zone}"
    Episodio = "Vision Artificial"
  }

  depends_on = [aws_efs_file_system.microservice, aws_efs_mount_target.microservice]
}

resource "aws_eip_association" "microservice" {
  instance_id   = aws_instance.microservice[0].id
  allocation_id = aws_eip.microservice.id
}



