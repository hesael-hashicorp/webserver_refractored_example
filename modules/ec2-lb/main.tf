variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public Subnet IDs"
  type        = list(string)
}

variable "private_subnet_id" {
  description = "Private Subnet ID"
  type        = string
}

variable "ec2_security_group" {
  description = "Security group for EC2"
  type        = string
}

variable "lb_security_group" {
  description = "Security group for Load Balancer"
  type        = string
}


resource "aws_instance" "web_server" {
  ami                    = "ami-09d95fab7fff3776c"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.ec2_security_group]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1 -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "WebServer"
  }
}


resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group]
  subnets            = var.public_subnet_ids
}


resource "aws_lb_target_group" "web_tg" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}


resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}


resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

output "lb_dns_name" {
  value = aws_lb.web_lb.dns_name
}
