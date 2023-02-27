
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
  count                   = length(var.aws_subnet_cidrs)
  vpc_id                  = aws_vpc.hubble_aws_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = var.aws_subnet_cidrs[count.index]

  tags = {
    "Name" = var.aws_subnet_names[count.index]
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
  count          = length(var.aws_subnet_cidrs)
  subnet_id      = aws_subnet.hubble_subnet.*.id[count.index]
  route_table_id = aws_route_table.hubble_rt.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.hubble_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hubble_igw.id
}

resource "aws_security_group" "hubble_aws_sts_sg" {
  name        = var.aws_sg_data.site_to_site_sg.name
  description = var.aws_sg_data.site_to_site_sg.description
  vpc_id      = aws_vpc.hubble_aws_vpc.id
  dynamic "ingress" {
    for_each = var.aws_sg_data.site_to_site_sg.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hubble_aws_frontier_sg" {
  name        = var.aws_sg_data.frontier_sg.name
  description = var.aws_sg_data.frontier_sg.description
  vpc_id      = aws_vpc.hubble_aws_vpc.id
  dynamic "ingress" {
    for_each = var.aws_sg_data.frontier_sg.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "hubble_aws_midtier_sg" {
  name        = "AWS_Business_tier_SG"
  description = "Handles Business application security"
  vpc_id      = aws_vpc.hubble_aws_vpc.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.hubble_aws_frontier_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}