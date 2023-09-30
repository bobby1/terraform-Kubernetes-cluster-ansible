###======================================================================================
### Copyright (c) 2023, Bobby Wen, All Rights Reserved 
### Use of this source code is governed by a MIT-style
### license that can be found at https://en.wikipedia.org/wiki/MIT_License.
### Project:		Showcase Demo
### Class:			Terraform AWS resource file
### Purpose:    resource file for main.tf to create AWS resources
### Usage:			terraform, used by terraform main.tf
### Pre-requisits:	AWS access configuration(https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html), 
###                 Terraform by HashiCorp (https://www.terraform.io/)
### Beware:     resource.tf file is used to pass resource information to main.tf.  
###             Depending on SDLC environmental setting, different attributes are passed to create the stack 
###
### Developer: 		Bobby Wen, bobby@wen.org
### Creation date:	20230929_1000
###======================================================================================
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  count             = length(var.availability_zone[var.region])
  availability_zone = var.availability_zone[var.region][count.index]
}

resource "aws_security_group" "allow_ssh" {
  description = "Allow ssh traffic"
  name        = "allow_ssh"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "Cidr Blocks and ports for Ingress security"
    cidr_blocks      = var.ingress_cidr_blocks[var.environment]
    from_port        = 22
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
  }

  egress {
    description      = "Cidr Blocks and ports for Egress security"
    cidr_blocks      = var.egress_cidr_blocks[var.environment]
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }
}

resource "aws_security_group" "allow_private_traffic" {
  description = "Allow private network traffic"
  name        = "allow_private_network_traffic"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Cidr Blocks and ports for Ingress security"
    cidr_blocks = var.ingress_cidr_blocks[var.environment]
    # from_port        = 443
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    # protocol         = "tcp"
    protocol        = "-1"
    security_groups = []
    self            = false
    # to_port          = 443
    to_port = 0
  }

  egress {
    description      = "Cidr Blocks and ports for Egress security"
    cidr_blocks      = var.egress_cidr_blocks[var.environment]
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("../test_rsa.pem")
    timeout     = "4m"
  }
}


