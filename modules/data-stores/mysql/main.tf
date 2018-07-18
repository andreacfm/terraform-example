resource "aws_db_instance" "example" {
  instance_class    = "db.t2.micro"
  engine            = "mysql"
  allocated_storage = 10
  name              = "${var.db_name}"
  username          = "admin"
  password          = "${var.db_password}"
  skip_final_snapshot = true
}
