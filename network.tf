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

resource "aws_route_table" "app-1-route-table" {
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
    Name = "app-1-route-table"
  }
}

resource "aws_subnet" "app-1-subnets" {
  count             = length(var.subnet_cidrs)
  vpc_id            = aws_vpc.app-1-vpc.id
  cidr_block        = var.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name : "app-1-vpc-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "app-1-route-table-aws_route_table_association" {
  count          = length(aws_subnet.app-1-subnets)
  subnet_id      = element(aws_subnet.app-1-subnets.*.id, count.index)
  route_table_id = aws_route_table.app-1-route-table.id
}
