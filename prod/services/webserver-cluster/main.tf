terraform {
  backend "s3" {
    bucket  = "andreacfm-terraform-state"
    key     = "prod/services/webserver-cluster/terraform.state"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.23"
  region  = "eu-west-1"
}

module "webserver-cluster" {
  source                 = "../../../modules/services/webserver-cluster"
  cluster_name           = "webserver-prod"
  db_remote_state_bucket = "andreacfm-terraform-state"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.state"
  instance_type          = "ts.micro"
  min_size               = 2
  max_size               = 10
}

resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name = "scale-up"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
  autoscaling_group_name = "${module.webserver-cluster.asg_name}"
}

resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name = "scale-down"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
  autoscaling_group_name = "${module.webserver-cluster.asg_name}"
}
