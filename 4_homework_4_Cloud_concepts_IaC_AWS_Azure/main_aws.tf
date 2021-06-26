### Initialize terraform for AWS provider ###

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

### Get default VPC ###

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

### Create default subnets ###

resource "aws_subnet" "default_subnet_1" {
  vpc_id            = aws_default_vpc.default.id
  cidr_block        = "172.31.20.0/24"
  availability_zone = "eu-central-1a"
}

resource "aws_subnet" "default_subnet_2" {
  vpc_id            = aws_default_vpc.default.id
  cidr_block        = "172.31.40.0/24"
  availability_zone = "eu-central-1b"
}

### Create instance 1 ###

resource "aws_instance" "vm_1" {
  ami                         = "ami-0bdb7f5a40ca10b7d"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.dobrozhan-sg.id]
  key_name                    = "dobrozhan-vm"
  subnet_id                   = aws_subnet.default_subnet_1.id
  associate_public_ip_address = true
  monitoring                  = true
  tags = {
    Name = "dobrozhan-vm-1"
  }
}

### Create instance 2 ###

resource "aws_instance" "vm_2" {
  ami                         = "ami-0bdb7f5a40ca10b7d"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.dobrozhan-sg.id]
  key_name                    = "dobrozhan-vm"
  subnet_id                   = aws_subnet.default_subnet_2.id
  associate_public_ip_address = true
  monitoring                  = true
  tags = {
    Name = "dobrozhan-vm-2"
  }
}

### Creare security group ###

resource "aws_security_group" "dobrozhan-sg" {
  name        = "dobrozhan security group"
  description = "security group"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "rdp"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http_rdp"
  }
}


###  Create network load balancer  ###

data "aws_subnet_ids" "sbs" {
  vpc_id = aws_default_vpc.default.id
}

###  lb ### 

resource "aws_lb" "network_lb" {
  name                             = "dobrozhan-lb"
  internal                         = false
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  subnets                          = data.aws_subnet_ids.sbs.ids

  tags = {
    Environment = "prod-dobrozhan"
  }
}

###  target group ### 

resource "aws_lb_target_group" "network_lb_tg" {
  name     = "dobrozhan-lb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_default_vpc.default.id
}

###  lb listener ### 

resource "aws_lb_listener" "network_lb_ls" {
  load_balancer_arn = aws_lb.network_lb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network_lb_tg.arn
  }
}

###  register instances ### 

resource "aws_lb_target_group_attachment" "network_lb_tg_attach_1" {
  target_group_arn = aws_lb_target_group.network_lb_tg.arn
  target_id        = aws_instance.vm_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "network_lb_tg_attach_2" {
  target_group_arn = aws_lb_target_group.network_lb_tg.arn
  target_id        = aws_instance.vm_2.id
  port             = 80
}
