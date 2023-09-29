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
  count             = length(var.avz[var.aws_region])
  availability_zone = var.avz[var.aws_region][count.index]
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

  ingress {
    description      = "Cidr Blocks and ports for Ingress security"
    cidr_blocks      = var.ingress_cidr_blocks[var.environment]
    from_port        = 443
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 443
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

resource "aws_security_group" "allow_etcd" {
  name        = "allow_etcd"
  description = "Allow service traffic on port 2379 and 2380"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Port 2379"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = aws_default_subnet.default.*.cidr_block
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = var.aws_key_name
  public_key = var.aws_public_key
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("../test_rsa.pem")
    timeout     = "4m"
  }
}

# resource "local_file" "inventory" {
#   content = templatefile(
#     # "${path.module}/templates/inventory.tftpl",
#     "../../templates/inventory.tftpl",
#     {
#       #   controller-0-public-ip   = module.ec2_instance[0].public_ip,
#       #   controller-0-public-ip   = module.ec2_instance[0].public_ip,
#       #   controller-0-private-ip  = module.ec2_instance[0].private_ip,
#       #   controller-0-private-dns = module.ec2_instance[0].private_dns,
#       #   controller-1-public-ip   = module.ec2_instance[1].public_ip,
#       #   controller-1-private-ip  = module.ec2_instance[1].private_ip,
#       #   controller-1-private-dns = module.ec2_instance[1].private_dns,

#       #   controller-0-public-ip   = aws_instance.ec2_instance[0].public_ip,
#       #   controller-0-public-ip   = aws_instance.ec2_instance[0].public_ip,
#       #   controller-0-private-ip  = aws_instance.ec2_instance[0].private_ip,
#       #   controller-0-private-dns = aws_instance.ec2_instance[0].private_dns,
#       #   controller-1-public-ip   = aws_instance.ec2_instance[1].public_ip,
#       #   controller-1-private-ip  = aws_instance.ec2_instance[1].private_ip,
#       #   controller-1-private-dns = aws_instance.ec2_instance[1].private_dns,

#       controller-0-public-ip   = module.aws_instance.ec2_instance[0].public_ip,
#       controller-0-public-ip   = module.aws_instance.ec2_instance[0].private_ip,
#       controller-0-private-dns = module.aws_instance.ec2_instance[0].private_dns,
#       controller-1-public-ip   = module.aws_instance.ec2_instance[1].public_ip,
#       controller-1-private-ip  = module.aws_instance.ec2_instance[1].private_ip,
#       controller-1-private-dns = module.aws_instance.ec2_instance[1].private_dns,


#       worker-0-public-ip   = module.ec2_workers[0].public_ip,
#       worker-0-private-ip  = module.ec2_workers[0].private_ip,
#       worker-0-private-dns = module.ec2_workers[0].private_dns,
#       worker-1-public-ip   = module.ec2_workers[1].public_ip,
#       worker-1-private-ip  = module.ec2_workers[1].private_ip,
#       worker-1-private-dns = module.ec2_workers[1].private_dns,
#       ssh-private-key      = file("../test_rsa.pem")
#     }
#   )
#   filename = "${path.module}/../ansible/inventory"
# }