variable "public-count" {
  default = 2
}

variable "private-count" {
  default = 2
}

variable "environment" {
  default = "test"
}

variable "ami" {
  description = "Ubuntu LTS 16.04 AMD64 HVM EBS"
  # Search keys: eu-west-1 16.04 hvm ebs on https://cloud-images.ubuntu.com/locator/ec2/
  default = "ami-f90a4880"
}

variable "machine" {
  default = "t2.micro"
}

variable "cidr-prefix" {
  description = "Private 16 bit CIDR prefix for the VPC"
  default = "172.16"
}

# output "docker-host-public-names" {
#   value = "${aws_instance.docker-host.*.public_dns}"
# }
