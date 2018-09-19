resource "aws_subnet" "private" {
  count = "${var.private-count}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.cidr-prefix}.${15 - count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
  #map_public_ip_on_launch = true
  tags {
    Name = "${var.environment}-private-${count.index}"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_route_table" "private" {
  count = "${var.private-count}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.environment}-private-${count.index}"
    Description = "Private route table"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource aws_route "nat" {
  count = "${var.private-count}"
  nat_gateway_id = "${element(aws_nat_gateway.nat.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = "${element(aws_route_table.private.*.id,count.index)}"
}

resource "aws_route_table_association" "nat" {
  count = "${var.private-count}"
  subnet_id = "${element(aws_subnet.private.*.id,count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id,count.index)}"
}
