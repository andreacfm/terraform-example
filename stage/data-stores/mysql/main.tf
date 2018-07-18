provider "aws" {
  version = "~> 1.23"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket  = "andreacfm-terraform-state"
    key     = "stage/data-stores/mysql/terraform.state"
    region  = "eu-west-1"
    encrypt = true
  }
}

module "mysql" {
  source = "../../../modules/data-stores/mysql"
  db_name = "mysql_stage"
  db_password = "${var.db_password}"
}
