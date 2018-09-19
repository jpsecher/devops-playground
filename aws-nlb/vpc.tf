resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr-prefix}.0.0/16"
  enable_dns_hostnames = true
  tags {
    Name = "${var.environment}"
    Description = "VPC ${var.environment}"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "internet" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.environment}"
    Description = "Internet gateway ${var.environment}"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = "${var.subnet-count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  tags = {
    Name = "${var.environment}-${count.index}"
    Description = "NAT gateway"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_eip" "nat" {
  count = "${var.subnet-count}"
  vpc = true
  depends_on = ["aws_internet_gateway.internet"]
  tags = {
    Name = "${var.environment}-${count.index}"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource aws_route "nat" {
  count = "${var.subnet-count}"
  nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  count = "${var.subnet-count}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.environment}-private-${count.index}"
    Description = "Private route table"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_subnet" "private" {
  count = "${var.subnet-count}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr-prefix}.${count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.environment}-private-${count.index}"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "experimental" {
  count = "${var.subnet-count}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
