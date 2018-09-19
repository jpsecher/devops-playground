resource "aws_lb" "nlb" {
  name = "lb-${var.environment}"
  load_balancer_type = "network"
  subnets = ["${aws_subnet.public.*.id}"]
  enable_cross_zone_load_balancing = true
  tags {
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = "${aws_lb.nlb.arn}"
  port = 80
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.http.arn}"
  }
}

resource "aws_lb_target_group" "http" {
  name = "http-${var.environment}"
  port = 80
  protocol = "TCP"
  vpc_id = "${aws_vpc.vpc.id}"
  target_type = "instance"
  health_check = {
    protocol = "TCP"
    port = 22
  }
  tags {
    managed-by = "terraform"
    repo = "${var.repository}"
    environment = "${var.environment}"
  }
}

resource "aws_route53_record" "nlb" {
  zone_id = "${data.aws_route53_zone.current.id}"
  name = "${var.environment}.lb.${var.main-zone}"
  type = "CNAME"
  ttl = "360"
  records = [
    "${aws_lb.nlb.dns_name}"
  ]
}
