terraform {
  backend "s3" {
    bucket  = "andreacfm-terraform-state"
    key     = "stage/data-stores/mysql/terraform.state"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.23"
  region  = "eu-west-1"
}

resource "aws_db_instance" "example" {
  instance_class    = "db.t2.micro"
  engine            = "mysql"
  allocated_storage = 10
  name              = "example_database"
  username          = "admin"
  password          = "${var.db_password}"
}
