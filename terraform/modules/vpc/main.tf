##############
# VPC
##############
resource "aws_vpc" "main" {
  cidr_block = var.cidrblock

  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}

##############
# Subnets
##############
resource "aws_subnet" "private-a" {
  vpc_id            = aws_vpc.main.id
  # TODO split  cidr_block with cidrsubnet 
  cidr_block        = "10.0.0.0/19"
  # TODO
  availability_zone = "eu-north-1a"

  tags = {
    "Name"                                      = "private-a"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id            = aws_vpc.main.id
  # TODO split  cidr_block with cidrsubnet 
  cidr_block        = "10.0.32.0/19"
  # TODO
  availability_zone = "eu-north-1b"

  tags = {
    "Name"                                      = "private-b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id                  = aws_vpc.main.id
  # TODO split  cidr_block with cidrsubnet 
  cidr_block              = "10.0.64.0/19"
  # TODO
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-a"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id                  = aws_vpc.main.id
  # TODO split  cidr_block with cidrsubnet 
  cidr_block              = "10.0.96.0/19"
  # TODO
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-b"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}


##############
# IGW
##############
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

##############
# NAT
##############
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-a.id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

##############
# Routes
##############
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}
