    provider "aws" {
    region = var.region
    }

    resource "aws_key_pair" "deployer" {
    key_name   = "${var.env}-key"
    public_key = file(var.public_key_path)
    }

    resource "aws_security_group" "allow_ssh_http" {
    name        = "${var.env}-sg"
    description = "Allow SSH and HTTP"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 80
        to_port     = 80
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

    resource "aws_instance" "app" {
    ami           = "ami-08c40ec9ead489470"
    instance_type = "t3.micro"
    key_name      = aws_key_pair.deployer.key_name
    security_groups = [aws_security_group.allow_ssh_http.name]

    tags = {
        Name = "myapp-${var.env}"
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install -y apache2 git
                sudo systemctl start apache2
                sudo systemctl enable apache2
                echo "Hello from ${var.env}" > /var/www/html/index.html
                EOF
    }