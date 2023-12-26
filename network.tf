# Network
resource "aws_vpc" "app-1-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name : "app-1-vpc"
  }
}

resource "aws_internet_gateway" "app-1-internet_gateway" {
  vpc_id = aws_vpc.app-1-vpc.id

  tags = {
    Name = "app-1-internet_gateway"
  }
}

resource "aws_route_table" "app-1-public-route-table" {
  vpc_id = aws_vpc.app-1-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-1-internet_gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.app-1-internet_gateway.id
  }

  tags = {
    Name = "app-1-public-route-table"
  }
}

resource "aws_route_table" "app-1-private-route-tables" {
  count  = length(var.subnet_cidrs_private)
  vpc_id = aws_vpc.app-1-vpc.id

  tags = {
    Name = "-${count.index + 1}"
  }
}

resource "aws_subnet" "app-1-public-subnets" {
  count             = length(var.subnet_cidrs_public)
  vpc_id            = aws_vpc.app-1-vpc.id
  cidr_block        = var.subnet_cidrs_public[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name : "app-1-vpc-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "app-1-private-subnets" {
  count             = length(var.subnet_cidrs_private)
  vpc_id            = aws_vpc.app-1-vpc.id
  cidr_block        = var.subnet_cidrs_private[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name : "app-1-vpc-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "app-1-public-route-table-association" {
  count          = length(aws_subnet.app-1-public-subnets)
  subnet_id      = element(aws_subnet.app-1-public-subnets.*.id, count.index)
  route_table_id = aws_route_table.app-1-public-route-table.id
}

resource "aws_route_table_association" "app-1-private-route-table-association" {
  count          = length(aws_subnet.app-1-private-subnets)
  subnet_id      = element(aws_subnet.app-1-private-subnets.*.id, count.index)
  route_table_id = element(aws_route_table.app-1-private-route-tables.*.id, count.index)
}

resource "aws_eip" "eip-nat-gateway" {
  count  = length(var.subnet_cidrs_public)
  domain = "vpc"
  tags = {
    "Name" = "app-1-eip-NAT-${count.index + 1}"
  }
}
resource "aws_nat_gateway" "app_1_nat_gateways" {
  count         = length(var.subnet_cidrs_private)
  subnet_id     = element(aws_subnet.app-1-public-subnets.*.id, count.index)
  allocation_id = element(aws_eip.eip-nat-gateway.*.id, count.index)
  depends_on    = [aws_internet_gateway.app-1-internet_gateway]
  tags = {
    "Name" = "app-1-NAT-${count.index + 1}"
  }
}

resource "aws_route" "private-route" {
  count                  = length(var.subnet_cidrs_private)
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = element(aws_route_table.app-1-private-route-tables.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.app_1_nat_gateways.*.id, count.index)
}
