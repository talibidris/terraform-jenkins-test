provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-b8b45ddf"
  instance_type          = "t2.micro"
  key_name               = ""
  vpc_security_group_ids = ""
  user_data              = ""

  tags {
    Name        = "jenkins-server"
    Environment = "Development"
  }
}

resource "template_file" "user_data" {
  template = "userdata.tpl"
}

resource "aws_security_group" "jenkins-security-group" {
  name        = "jenkins-security-group"
  description = "Allow access to Jenkins server"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["46.255.114.114/32"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
