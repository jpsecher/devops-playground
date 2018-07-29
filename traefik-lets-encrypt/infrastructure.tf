variable "sub-zone" {
  description = "DNS subdomain of main-zone"
  default = "test"
}

variable "ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

variable "machine" {
  default = "t2.micro"
}

variable "cidr-prefix" {
  description = "Private 16 bit CIDR prefix for the VPC"
  default = "172.16"
}

resource "aws_instance" "docker-host" {
  count = 1
  tags {
    Name = "docker-host-${count.index}"
    Description = "Docker host"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.sub-zone}"
  }
  ami = "${var.ami}"
  instance_type = "${var.machine}"
  vpc_security_group_ids = [
    "${aws_security_group.access-from-safe-ips.id}",
    "${aws_security_group.access-to-http-and-https.id}"
  ]
  root_block_device = {
    delete_on_termination = true
  }
  key_name = "${var.aws-key-name}"
  depends_on = ["aws_internet_gateway.experimental"]
  subnet_id = "${element(aws_subnet.experimental.*.id,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
}

resource "aws_route53_record" "docker-host" {
  zone_id = "${data.aws_route53_zone.current.zone_id}"
  name = "${var.sub-zone}.${data.aws_route53_zone.current.name}"
  type = "A"
  ttl = 60
  records = ["${aws_instance.docker-host.public_ip}"]
}

resource "aws_security_group" "access-to-http-and-https" {
  tags {
    Name = "access-to-http-and-https"
    Description = "Access to HTTP(S)"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.sub-zone}"
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.experimental.id}"
}

resource "aws_security_group" "access-from-safe-ips" {
  tags {
    Name = "access-from-safe-ips"
    Description = "Access from safe IPs"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.sub-zone}"
  }
  ingress {
    from_port = 0,
    to_port = 0,
    protocol = "-1"
    cidr_blocks = ["${split(",", var.safe-ips)}"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.experimental.id}"
}

resource "aws_vpc" "experimental" {
  tags {
    Name = "${var.sub-zone}"
    Description = "Default VPC"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.sub-zone}"
  }
  cidr_block = "${var.cidr-prefix}.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "experimental" {
  tags {
    Name = "${var.sub-zone}"
    Description = "Default gateway"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.sub-zone}"
  }
  vpc_id = "${aws_vpc.experimental.id}"
}

resource "aws_subnet" "experimental" {
  tags {
    Name = "${var.sub-zone}"
    Description = "Default subnet"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.sub-zone}"
  }
  vpc_id = "${aws_vpc.experimental.id}"
  cidr_block = "${var.cidr-prefix}.${count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
  map_public_ip_on_launch = true
  count = 1
}

resource "aws_route_table" "experimental" {
  tags {
    Name = "${var.sub-zone}"
    Description = "Default route table"
    ManagedBy = "terraform"
    Repo = "infrastructure"
    Organisation = "monolit"
  }
  vpc_id = "${aws_vpc.experimental.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.experimental.id}"
  }
}

resource "aws_route_table_association" "experimental" {
  subnet_id = "${element(aws_subnet.experimental.*.id,count.index)}"
  route_table_id = "${aws_route_table.experimental.id}"
  count = 1
}

data "aws_route53_zone" "current" {
  name = "${var.main-zone}"
}

data "aws_availability_zones" "available" {}

output "docker-host-public-names" {
  value = "${aws_instance.docker-host.*.public_dns}"
}
