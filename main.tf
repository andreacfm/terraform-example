provider "aws" {
  version = "~> 1.23"
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami = "ami-40d28157",
  instance_type = "t2.micro"
  tags {
    Name = "terraform-example"
  }
}