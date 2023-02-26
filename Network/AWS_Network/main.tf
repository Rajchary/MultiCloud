
#=====================================> AWS_Network main.tf <================================================

resource "aws_vpc" "hubble_aws_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "hubble_subnet" {
  vpc_id                  = aws_vpc.hubble_aws_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = var.aws_subnet_cidrs[0]

  tags = {
    "Name" = var.aws_subnet_names
  }
}

resource "aws_internet_gateway" "hubble_igw" {
  vpc_id = aws_vpc.hubble_aws_vpc.id
  tags = {
    "Name" = "Hubble_IGW"
  }
}

resource "aws_route_table" "hubble_rt" {
  vpc_id = aws_vpc.hubble_aws_vpc.id
  tags = {
    "Name" = "Hubble_RouteTable"
  }
}

resource "aws_route_table_association" "hubble_rt_assc" {
  subnet_id      = aws_subnet.hubble_subnet.id
  route_table_id = aws_route_table.hubble_rt.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.hubble_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hubble_igw.id
}

