provider "aws" {
  version = "~> 1.23"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket  = "andreacfm-terraform-state"
    key     = "stage/services/webserver-cluster/terraform.state"
    region  = "eu-west-1"
    encrypt = true
  }
}

module "webserver-cluster" {
  source                 = "../../../modules/services/webserver-cluster"
  cluster_name           = "webserver-stage"
  db_remote_state_bucket = "andreacfm-terraform-state"
  db_remote_state_key    = "stage/data-stores/mysql/terraform.state"
  instance_type          = "ts.micro"
  min_size               = 2
  max_size               = 2
}

resource "aws_security_group_rule" "allow_testing_inboud" {
  from_port = 12345
  protocol = "tcp"
  security_group_id = "${module.webserver-cluster.elb_security_group_id}"
  to_port = 12345
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
