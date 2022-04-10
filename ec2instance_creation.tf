provider "aws" {
  region = "ap-south-1"
  profile = "terraform-project"
  access_key = "<your access_key>"
  secret_key = "<your secret_key>"
}

resource "aws_key_pair" "terraform" {
  key_name = "terraform-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCMhi9wOIiaJR8olVJX4aYLHnyA8gepxs8KMIIHewjk+aYQvxOdbddif9AAI55WbB03a37+1SvkrB8zSO6Qh/alTmPy6chjnY0tlNym6PLOzf3JwzlY62tv6aJa83SNumQLjeUlYeUH6o/9oJ34SpntVw0DJsVT06CdZ9GJQyExUp5ldGujOiU8kiBLsgZzZqAjYasIjcha8tr5/o898JKhmaBZzilP0sIM6tTAdTdxwIYxdk0wIWAe3WZHFB0BwuysStBrqh1UeT8WLS8ZyhT0gzHnEs15z8CWXqLksCriU39xrqkGX5RF0O2C5+Rk/X3XBl3ZEW9O/LkinP801IVz"
}

resource "aws_instance" "test_windows" {
  ami = "ami-windows number"
  instance_type = "t2.medium"
}

resource "aws_instance" "dev" {
  ami           = "ami-0b614a5d911900a9b"
  instance_type = "t2.micro"
  key_name = "terraform-key"
  security_groups = ["terraform-security-group"]

  tags = {
    Name = "terraform_instance_santhosh_new"
  }
}

resource "aws_security_group" "terraform-sg" {
  name = "terraform-security-group"
  description = "default terraform security group"
  vpc_id = "vpc-029c524436667ec83"
  ingress {
    from_port = 22
    protocol  = "all"
    to_port   = 22
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port = 22
    protocol  = "all"
    to_port   = 22
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
  Name = "terraform-rules"
  }
}