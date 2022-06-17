# VPC
resource "aws_vpc" "informe_nube" {
  cidr_block                       = var.cidr
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = true

  tags = {
    Name     = "Ages"
    Episodio = "Ages"
  }

  lifecycle {
    prevent_destroy = false // para entornos de produccion colocarlo en true
  }
}

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.informe_nube.id
  count                   = length(data.aws_availability_zones.available.zone_ids)
  cidr_block              = cidrsubnet(var.cidr, 4, 0 + count.index)
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name     = "Red publica-${count.index}"
    Episodio = "Ages"
  }

  depends_on = [aws_vpc.informe_nube]
}

resource "aws_subnet" "privada" {
  vpc_id                  = aws_vpc.informe_nube.id
  count                   = length(data.aws_availability_zones.available.zone_ids)
  cidr_block              = cidrsubnet(var.cidr, 4, 3 + count.index)
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name     = "ages privada-${count.index}"
    Episodio = "Ages"
  }

  depends_on = [aws_vpc.informe_nube]
}

# Internet Gateway
resource "aws_internet_gateway" "informe_nubec" {
  vpc_id = aws_vpc.informe_nube.id

  tags = {
    Name     = "Internet Gateway"
    Episodio = "Ages"
  }

  lifecycle {
    prevent_destroy = false // para entornos de produccion colocarlo en true
  }

  depends_on = [aws_vpc.informe_nube]
}

# Routes
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.informe_nube.id
  # Internet
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.informe_nubec.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.informe_nubec.id
  }

  tags = {
    Name     = "Tabla de Route para las redes public"
    Episodio = "Ages"
  }

}

# Route Association
resource "aws_route_table_association" "public" {
  count          = length(data.aws_availability_zones.available.zone_ids)
  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public[*].id, count.index)

  depends_on = [aws_route_table.public]
}
