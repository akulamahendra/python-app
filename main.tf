terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "6.45.0"
    }
  }
}

provider "aws" {

    region = "ap-south-1"
}

resource "aws_instance" "myserver" {

    availability_zone  = "ap-south-1a"
    ami    = "ami-0685bcc683dadb6b9"
    instance_type = "c7i-flex.large"
    key_name = "docker"
    vpc_security_group_ids = [ aws_security_group.mysg.id ]

    tags = {
      Name = "python-app"
    }
  
}

resource "aws_security_group" "mysg" {

    vpc_id = 	"vpc-03987eef9d69ca4e8"

    ingress {
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    ingress {
        from_port = 8080
        to_port = 8080
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_eip" "myelastic-ip" {
    instance = aws_instance.myserver.id
    provisioner "local-exec" {
        command = <<EOT
            sleep 120
            ssh-keygen -R ${self.public_ip} || true
            sudo ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i ${self.public_ip}, playbook.yaml -u ec2-user --private-key /home/ec2-user/docker.pem
        EOT
    }
}
output "elastic_ip" {
    description = "Elastic IP address of the EC2 instance"
    value       = aws_eip.myelastic-ip.public_ip
}

output "instance_id" {
    description = "EC2 instance ID"
    value       = aws_instance.myserver.id
}
