locals {
  ec2_ami_ubuntu_22_04      = "ami-03fa85deedfcac80b"
  ec2_instance_type_t2_nano = "t2.nano"

  ec2_user_data = file("user-data.sh")
}

resource "aws_instance" "app_server" {
  ami           = local.ec2_ami_ubuntu_22_04 # Ubuntu 22.04 LTS
  instance_type = local.ec2_instance_type_t2_nano

  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-server"
  }

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]
  key_name  = aws_key_pair.app_server_key_pair.key_name
  user_data = local.ec2_user_data

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      #user_data
    ]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #   ingress {
  #     description = "Custom application port"
  #     from_port   = 3000
  #     to_port     = 3000
  #     protocol    = "tcp"
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_http"
  }
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app_server.id

  tags = {
    Name = "${var.project_name}-eip"
  }
}

resource "tls_private_key" "app_server_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "app_server_key_pair" {
  key_name   = "${var.project_name}-server-key"
  public_key = tls_private_key.app_server_key.public_key_openssh

  provisioner "local-exec" { # Create a "key.pem" to your computer!!
    command = "echo '${tls_private_key.app_server_key.private_key_pem}' > ./key.pem"
  }

  tags = {
    Name = "${var.project_name}-server-key"
  }
}

