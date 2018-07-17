provider "aws" {
  version = "~> 1.23"
  region  = "eu-west-1"
}

module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"
  cluster_name = "webserver-prod"
  db_remote_state_bucket = "andreacfm-terraform-state"
  db_remote_state_key = "prod/data-stores/mysql/terraform.state"
}