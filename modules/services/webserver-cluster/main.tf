data "aws_availability_zones" "available" {}

data "terraform_remote_state" "db" {
  backend = "s3"

  config {
    bucket = "${var.db_remote_state_bucket}"
    key    = "${var.db_remote_state_key}"
    region = "eu-west-1"
  }
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"

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

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
  }
}

resource "aws_launch_configuration" "example" {
  name            = "${var.cluster_name}"
  image_id        = "ami-2a7d75c0"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data       = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  name                 = "${var.cluster_name}"
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.available.names}"]
  load_balancers       = ["${aws_elb.example.name}"]
  health_check_type    = "ELB"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }
}

resource "aws_elb" "example" {
  name               = "${var.cluster_name}"
  availability_zones = ["${data.aws_availability_zones.available.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 30
    target              = "HTTP:${var.server_port}/"
    timeout             = 3
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "elb" {
  name = "${var.cluster_name}-sg-elb"
}

resource "aws_security_group_rule" "allow_http_inboud" {
  type              = "ingress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
}
