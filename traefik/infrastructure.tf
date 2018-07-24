variable "ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

variable "machine" {
  default = "t2.micro"
}

resource "aws_instance" "docker-host" {
  count = 1
  tags {
    Name = "docker-host-${count.index}"
    Description = "Docker host"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "experimental"
  }
  ami = "${var.ami}"
  instance_type = "${var.machine}"
  vpc_security_group_ids = ["${aws_security_group.access-from-safe-ips.id}"]
  root_block_device = {
    delete_on_termination = true
  }
  key_name = "${var.aws-key-name}"
  depends_on = ["aws_internet_gateway.experimental"]
  subnet_id = "${element(aws_subnet.experimental.*.id,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
}

resource "aws_security_group" "access-from-safe-ips" {
  tags {
    Name = "access-from-safe-ips"
    Description = "Access from safe IPs"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "experimental"
  }
  ingress {
    from_port = 0,
    to_port = 0,
    protocol = "tcp"
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

# TODO: allow ping

# resource "aws_security_group" "all-open" {
#   tags {
#     Description = "Wide open"
#     Name = "all-open"
#     managed-by = "terraform"
#     repo = "${var.repository}"
#     environment = "experimental"
#   }
#   ingress {
#     from_port = 0,
#     to_port = 0,
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

variable "cidr-prefix" {
  default = "172.16"
}

resource "aws_vpc" "experimental" {
  tags {
    Name = "experimental"
    Description = "Default VPC"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "experimental"
  }
  cidr_block = "${var.cidr-prefix}.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "experimental" {
  tags {
    Name = "experimental"
    Description = "Default gateway"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "experimental"
  }
  vpc_id = "${aws_vpc.experimental.id}"
}

resource "aws_subnet" "experimental" {
  tags {
    Name = "experimental"
    Description = "Default subnet"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "experimental"
  }
  vpc_id = "${aws_vpc.experimental.id}"
  cidr_block = "${var.cidr-prefix}.${count.index}.0/24"
  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
  map_public_ip_on_launch = true
  count = 1
}

resource "aws_route_table" "experimental" {
  tags {
    Name = "experimental"
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

data "aws_availability_zones" "available" {}

output "docker-host-public-names" {
  value = "${aws_instance.docker-host.*.public_dns}"
}
