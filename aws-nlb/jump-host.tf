resource "aws_instance" "jump-host" {
  ami = "${var.ami}"
  instance_type = "${var.machine}"
  vpc_security_group_ids = [
    "${aws_security_group.access-from-safe-ips.id}"
  ]
  root_block_device = {
    delete_on_termination = true
  }
  key_name = "${var.aws-key-name}"
  #depends_on = ["aws_internet_gateway.internet"]
  subnet_id = "${aws_subnet.public.0.id}"
  availability_zone = "${element(data.aws_availability_zones.available.names,0)}"
  tags {
    Name = "jump-host"
    Description = "Jump host"
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_route53_record" "jump-host" {
  zone_id = "${data.aws_route53_zone.current.zone_id}"
  name = "jump-${var.environment}.${data.aws_route53_zone.current.name}"
  type = "A"
  ttl = 60
  records = ["${aws_instance.jump-host.public_ip}"]
}
