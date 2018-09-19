resource "aws_instance" "docker-host" {
  count = "${var.private-count}"
  ami = "${var.ami}"
  instance_type = "${var.machine}"
  vpc_security_group_ids = [
    "${aws_security_group.access-from-safe-ips.id}",
    "${aws_security_group.access-to-http.id}",
    "${aws_security_group.access-from-vpc.id}"
  ]
  root_block_device = {
    delete_on_termination = true
  }
  key_name = "${var.aws-key-name}"
  #depends_on = ["aws_internet_gateway.internet"]
  subnet_id = "${element(aws_subnet.private.*.id,count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
  tags {
    Name = "docker-host-${count.index}"
    Description = "Docker host"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_route53_record" "docker-host" {
  count = "${var.private-count}"
  zone_id = "${data.aws_route53_zone.current.zone_id}"
  name = "${var.environment}-${count.index}.${data.aws_route53_zone.current.name}"
  type = "A"
  ttl = 60
  records = ["${element(aws_instance.docker-host.*.public_ip,count.index)}"]
}

resource "aws_security_group" "access-from-safe-ips" {
  tags {
    Name = "access-from-safe-ips"
    Description = "Access from safe IPs"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc.id}"
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
}

resource "aws_security_group" "access-from-vpc" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "access-from-vpc"
    Description = "Access from VPC"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
  }
}

resource "aws_security_group" "access-to-http" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "access-to-http"
    Description = "Access to HTTP"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group_attachment" "http" {
  count = "${var.private-count}"
  target_group_arn = "${aws_lb_target_group.http.arn}"
  target_id = "${element(aws_instance.docker-host.*.id,count.index)}"
}
