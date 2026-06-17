terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}


resource "aws_instance" "python-app" {

  ami                    = "ami-0685bcc683dadb6b9"
  instance_type          = "c7i-flex.large"
  key_name               = "docker"
  availability_zone      = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.slave-server-sec-grp.id]


  tags = {
    Name = "python-app"
  }


  provisioner "local-exec" {

    command = <<EOT
sudo sleep 60
sudo ssh-keygen -R ${self.public_ip}
sudo ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ${self.public_ip}, playbook.yaml -u ec2-user --private-key /home/ec2-user/docker.pem
EOT

  }
}


resource "aws_eip" "slave-server-eip" {

  instance = aws_instance.python-app.id

}


resource "aws_security_group" "slave-server-sec-grp" {

  name = "slave-server-sec-grp"


  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

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