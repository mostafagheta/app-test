terraform {
  backend "s3" {
    bucket = "atos-terraform-state"
    key    = "eks/terraform.tfstate"
    region = "eu-central-1"

    encrypt = true
  }
}