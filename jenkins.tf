provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "jenkins_master" {
  ami                    = "ami-b8b45ddf"
  instance_type          = "t2.micro"
  key_name               = "codepipeline-ec2-key"
  vpc_security_group_ids = ["${aws_security_group.jenkins-security-group.id}"]
  user_data              = "${file("userdata.tpl")}"

  tags {
    Name        = "jenkins-master-server"
    Environment = "Development"
  }
}

resource "aws_instance" "jenkins_slave" {
  ami                    = "ami-b8b45ddf"
  instance_type          = "t2.micro"
  key_name               = "codepipeline-ec2-key"
  vpc_security_group_ids = ["${aws_security_group.jenkins-worker-security-group.id}"]
  user_data              = "${file("userdata.tpl")}"

  tags {
    Name        = "jenkins-worker-server"
    Environment = "Development"
  }
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "jenkins-worker-security-group" {
  name        = "jenkins-worker-security-group"
  description = "Allow access to Jenkins worker from master via port 22"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.jenkins_master.private_ip}/32", "46.255.114.114/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "jenkins-efs" {
  creation_token = "jenkins-efs"

  tags {
    Name = "jenkins-efs"
  }
}

resource "aws_efs_mount_target" "jenkins-efs-mount-target" {
  file_system_id = "${aws_efs_file_system.jenkins-efs.id}"
  subnet_id      = "${aws_instance.jenkins_master.subnet_id}"
}

#To do add role to attach jenkins server to EFS
#Consider using s3 instead of EFS

