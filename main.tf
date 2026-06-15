terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.45.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}


resource "aws_security_group" "mysg" {

  vpc_id = "vpc-03987eef9d69ca4e8"

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


  tags = {
    Name = "python-app-sg"
  }
}



resource "aws_instance" "myserver" {

  availability_zone = "ap-south-1a"

  ami = "ami-0685bcc683dadb6b9"

  instance_type = "c7i-flex.large"

  key_name = "docker"

  vpc_security_group_ids = [
    aws_security_group.mysg.id
  ]


  tags = {
    Name = "python-app"
  }

}



resource "aws_eip" "myelastic-ip" {

  domain = "vpc"


  tags = {
    Name = "python-app-eip"
  }

}



resource "aws_eip_association" "eip_assoc" {

  instance_id   = aws_instance.myserver.id

  allocation_id = aws_eip.myelastic-ip.id

}



resource "null_resource" "ansible" {


  depends_on = [
    aws_eip_association.eip_assoc
  ]


  provisioner "local-exec" {


    command = <<EOT

sleep 180

ssh-keygen -R ${aws_eip.myelastic-ip.public_ip} || true


ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
-i ${aws_eip.myelastic-ip.public_ip}, \
playbook.yaml \
-u ec2-user \
--private-key /home/ec2-user/docker.pem

EOT

  }

}



output "elastic_ip" {

  description = "Elastic IP address"

  value = aws_eip.myelastic-ip.public_ip

}



output "instance_id" {

  description = "EC2 Instance ID"

  value = aws_instance.myserver.id

}