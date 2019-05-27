# this file defines the overall aws architecture

# Define the vpc
resource "aws_vpc" "vpc_mlserve" {
  cidr_block           = "${var.vpc_cidr_block}"
  instance_tenancy     = "${var.vpc_tenancy}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "ML Serve VPC"
  }
}

# Define Internet Gateway
resource "aws_internet_gateway" "ig_mlserve" {
  vpc_id = "${aws_vpc.vpc_mlserve.id}"

  tags {
    Name = "ML Serve IG"
  }
}

# Define Public Subnet
resource "aws_subnet" "subnet_public_mlserve" {
  count  = "${var.subnet_public_count}"
  vpc_id = "${aws_vpc.vpc_mlserve.id}"

  # cidr_block = "${var.subnet_public_cidr}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr_block, var.subnet_address_bits, var.subnet_public_offset + count.index)}"
  availability_zone       = "${var.default_availability_zone}"
  map_public_ip_on_launch = true

  tags {
    Name = "ML Serve Public Subnet"
  }
}

# Define the public route table
resource "aws_route_table" "rt_public_mlserve" {
  vpc_id = "${aws_vpc.vpc_mlserve.id}"

  route {
    cidr_block = "${var.public_cidr_block}"
    gateway_id = "${aws_internet_gateway.ig_mlserve.id}"
  }

  tags {
    Name = "ML Serve Public Route Table"
  }
}

# Assign the public route table to public subnet
resource "aws_route_table_association" "rt_assoc_subnet_public_mlserve" {
  subnet_id      = "${aws_subnet.subnet_public_mlserve.id}"
  route_table_id = "${aws_route_table.rt_public_mlserve.id}"
}

# Define Private Subnet
resource "aws_subnet" "subnet_private_mlserve" {
  count  = "${var.subnet_private_count}"
  vpc_id = "${aws_vpc.vpc_mlserve.id}"

  # cidr_block = "${var.subnet_private_cidr}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr_block, var.subnet_address_bits, var.subnet_public_count + var.subnet_private_offset + count.index)}"
  availability_zone = "${var.default_availability_zone}"

  tags {
    Name = "ML Serve Private Subnet"
  }
}

# Define Elastic IP for NAT Gateway
resource "aws_eip" "eip_nat_mlserve" {
  vpc = true

  lifecycle {
    prevent_destroy = false
  }

  tags {
    Name = "ML Serve Nat Gateway Elastic IP"
  }
}

# Define Nat Gateway
resource "aws_nat_gateway" "nat_gw_mlserve" {
  allocation_id = "${aws_eip.eip_nat_mlserve.id}"
  subnet_id     = "${aws_subnet.subnet_public_mlserve.id}"

  tags {
    Name = "ML Serve Nat Gateway"
  }
}

# Define the private route table
resource "aws_route_table" "rt_private_mlserve" {
  vpc_id = "${aws_vpc.vpc_mlserve.id}"

  tags {
    Name = "ML Serve Private Route Table"
  }
}

# Define default private route
resource "aws_route" "route_private_default" {
  route_table_id         = "${aws_route_table.rt_private_mlserve.id}"
  destination_cidr_block = "${var.public_cidr_block}"
  nat_gateway_id         = "${aws_nat_gateway.nat_gw_mlserve.id}"
}

# Assign the private route table to private subnet
resource "aws_route_table_association" "rt_assoc_subnet_private_mlserve" {
  route_table_id = "${aws_route_table.rt_private_mlserve.id}"
  subnet_id      = "${aws_subnet.subnet_private_mlserve.id}"
}
