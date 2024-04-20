# VPC
resource "aws_vpc" "sftpgo" {
  cidr_block           = local.workspace["sftpgo_vpc_cidr_block"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

# Subnets (public)
resource "aws_subnet" "sftpgo_public" {
  for_each          = local.workspace["sftpgo_public_subnet_cidr_blocks"]
  vpc_id            = aws_vpc.sftpgo.id
  cidr_block        = each.value
  availability_zone = each.key

  map_public_ip_on_launch = true

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}-public-${each.key}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

# Internet Gateway
resource "aws_internet_gateway" "sftpgo" {
  vpc_id = aws_vpc.sftpgo.id

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

resource "aws_route_table" "sftpo_public" {
  vpc_id = aws_vpc.sftpgo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sftpgo.id
  }

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}-public"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

# Route Table Association
resource "aws_route_table_association" "public_route_association" {
  for_each       = aws_subnet.sftpgo_public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.sftpo_public.id
}

# Security Group
resource "aws_security_group" "sftpgo" {
  name        = "sftpgo-${local.workspace["environment"]}"
  description = "SFTPGo access rules for HTTP, SSH"
  vpc_id      = aws_vpc.sftpgo.id

  # HTTP and HTTPS for Traefik
  ingress {
    description = "Allow all HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP for VPN access only
  ingress {
    description = "Wireguard VPN access to admin panel"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [
      var.allow_ip
    ]
  }

  ingress {
    description = "Wireguard VPN access for SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      var.allow_ip
    ]
  }

  ingress {
    description = "Allow global SFTP access"
    from_port   = 2022
    to_port     = 2022
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # may want to be more restrictive in the future
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}

resource "aws_network_acl" "sftpgo_acl" {
  vpc_id = aws_vpc.sftpgo.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 443
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "sftpgo-${local.workspace["environment"]}"
    project     = "sftpgo"
    environment = local.workspace["environment"]
  }
}
