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
