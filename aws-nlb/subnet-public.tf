resource "aws_subnet" "public" {
  count = "${var.public-count}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr-prefix}.${count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
  map_public_ip_on_launch = true
  tags {
    Name = "${var.environment}-public-${count.index}"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = "${var.public-count}"
  allocation_id = "${element(aws_eip.nat.*.id,count.index)}"
  subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
  tags = {
    Name = "${var.environment}-${count.index}"
    Description = "NAT gateway"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_eip" "nat" {
  count = "${var.public-count}"
  vpc = true
  depends_on = ["aws_internet_gateway.internet"]
  tags = {
    Name = "${var.environment}-${count.index}"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.environment}-public"
    Description = "Public route table"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "public" {
  count = "${var.public-count}"
  subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route" "internet" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.internet.id}"
}
