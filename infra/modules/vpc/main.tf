resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "private_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
