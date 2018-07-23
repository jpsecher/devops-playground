variable "ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  default = "ami-f90a4880"
}

variable "machine" {
  default = "t2.micro"
}

resource "aws_instance" "docker-host" {
  tags {
    Description = "Docker host"
    Name = "docker-host"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "experimental"
  }
  ami = "${var.ami}"
  instance_type = "${var.machine}"
  vpc_security_group_ids = ["${aws_security_group.all-open.id}"]
  root_block_device = {
    "delete_on_termination" = true
  }
  key_name = "${var.aws-key-name}"
  # TODO: setup a map in variables using data source "available".
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_security_group" "all-open" {
  tags {
    Description = "Wide open"
    Name = "all-open"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "experimental"
  }
  ingress {
    from_port = 0,
    to_port = 0,
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "available" {}
