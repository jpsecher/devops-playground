data "aws_route53_zone" "current" {
  name = "${var.main-zone}"
}

data "aws_availability_zones" "available" {}
