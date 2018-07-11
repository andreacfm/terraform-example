terraform {
  backend "s3" {
    bucket = "andreacfm-terraform-state"
    key = "global/s3/terraform.state"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.23"
  region = "eu-west-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "andreacfm-terraform-state"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

}
