variable "repository" {
	default = "jpsecher/devops-playground"
}

variable "main-zone" {
  description = "DNS zone"
  default = "kaleidoscope.software"
}

variable "aws-key-name" {
  description = "Name of the SSH keypair to use in AWS."
  default = "kaleidoscope-jp"
  # Must be one of
  # https://eu-west-1.console.aws.amazon.com/ec2/v2/home?region=eu-west-1#KeyPairs:sort=keyName
}

variable "bucket-name" {
  default = "kaleidoscope-terraform-state"
}

provider "aws" {
  region = "${var.aws-region}"
  version = "~> 1.28"
}

variable "aws-region" {
  default = "eu-west-1"
}
