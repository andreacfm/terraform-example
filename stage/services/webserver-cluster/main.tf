terraform {
  backend "s3" {
    bucket = "andreacfm-terraform-state"
    key = "stage/services/webserver-cluster/terraform.state"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  version = "~> 1.23"
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

data "terraform_remote_state" "db" {
  backend = "s3"
  config {
    bucket="andreacfm-terraform-state"
    key     = "stage/data-stores/mysql/terraform.state"
    region  = "eu-west-1"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-sg-instance"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "example" {
  image_id               = "ami-40d28157"
  instance_type          = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]


  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" >> index.html
              echo "${data.terraform_remote_state.db.address}" >> index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"
  max_size = 10
  min_size = 2
  tag {
    key = "Name"
    value = "terraform-example-asg"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name = "terraform-example-elb"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  security_groups = ["${aws_security_group.elb.id}"]
  listener {
    instance_port = "${var.server_port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    interval = 30
    target = "HTTP:${var.server_port}/"
    timeout = 3
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "elb" {
  name = "terraform-example-sg-elb"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}