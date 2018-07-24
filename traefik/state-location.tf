terraform {
  backend "s3" {
    ## Has to be the same as var.bucket-name
    bucket = "kaleidoscope-terraform-state"
    key = "traefik.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}
