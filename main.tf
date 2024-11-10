terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket = "terraform-s3-bucket-demo"
    region = "ap-southeast-2"
    key = "private/mystatefile/terraform.tfstate"
    encrypt = true
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "tls_private_key" "my-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "ec2-key" {
  key_name   = var.key_name
  public_key = tls_private_key.my-key.public_key_openssh
}

resource "local_file" "private-key" {
  content = tls_private_key.my-key.private_key_pem
  filename = var.key_name

  provisioner "local-exec" {
    command = "chmod 400 ${var.key_name}"
  }
}

# Create a security group
resource "aws_security_group" "sg_ec2" {
  name        = "sg_ec2"
  description = "Security group for EC2"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.my_ip}/32"]

  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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


resource "aws_instance" "app_server" {
  ami           = "ami-086918d8178bfe266"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_ec2.id]
  key_name      = aws_key_pair.ec2-key.key_name

  tags = {
    Name = var.instance_name
  }

  provisioner "remote-exec" {
    inline = ["echo 'EC2 instance is ready.'"]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = tls_private_key.my-key.private_key_pem
    }
  }

  provisioner "local-exec" {
    command = "echo '[ec2_instances]\n${self.public_ip} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/Users/sudipto/Documents/Code_Repos/learn-terraform-aws-instance/${var.key_name}' > inventory.ini"
  }
}


