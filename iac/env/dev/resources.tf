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
data "aws_regions" "current" {}

# data "aws_availability_zone" "availabile" {
#   # # all_availability_zones = true
#   # state = "availabile"
#   # # id    = data.aws_regions.current
#   # # id = var.region

#   # filter {
#   #   name = "opt-in-status"
#   #   # values = ["not-opted-in", "opted-in"]
#   #   # values = ["opted-in"]
#   #   values = ["opt-in-not-required"]
#   # }
# }

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default" {
  count             = length(var.availability_zone[var.region])
  availability_zone = var.availability_zone[var.region][count.index]
  # count             = length(data.aws_availability_zone.availabile)
  # availability_zone = data.aws_availability_zone.availabile[count.index]
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = var.public_key
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("../../test_rsa.pem")
    timeout     = "4m"
  }
}

resource "aws_security_group" "allow_ssh" {
  description = "Allow ssh traffic"
  name        = "allow_ssh"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "Cidr Blocks and ports for Ingress security"
    cidr_blocks = var.ingress_cidr_blocks[var.environment]
    # from_port        = 22
    from_port        = 0 ### DEBUG  ### Open all ports to test K8 cluster
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    # protocol         = "tcp"
    protocol        = -1
    security_groups = []
    self            = false
    # to_port          = 22
    to_port = 0 ### DEBUG  ### Open all ports to test K8 cluster
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
    description      = "Cidr Blocks and ports for Ingress security"
    cidr_blocks      = var.ingress_cidr_blocks[var.environment]
    from_port        = 0
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "-1"
    security_groups  = []
    self             = false
    to_port          = 0
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

################################################################################
# ansible configuration
################################################################################
resource "local_file" "inventory" {
  content = templatefile(
    "${path.module}./../templates/inventory.tftpl",
    {
      controller-0-public-ip   = module.ec2_instance[0].public_ip,
      controller-0-public-dns  = module.ec2_instance[0].public_dns,
      controller-0-private-ip  = module.ec2_instance[0].private_ip,
      controller-0-private-dns = module.ec2_instance[0].private_dns,

      # controller-1-public-ip   = module.ec2_instance[1].public_ip,
      # controller-1-public-dns  = module.ec2_instance[1].public_dns,
      # controller-1-private-ip  = module.ec2_instance[1].private_ip,
      # controller-1-private-dns = module.ec2_instance[1].private_dns,

      worker-0-public-ip   = module.ec2_workers[0].public_ip,
      worker-0-private-ip  = module.ec2_workers[0].private_ip,
      worker-0-public-dns  = module.ec2_workers[0].public_dns,
      worker-0-private-dns = module.ec2_workers[0].private_dns,

      worker-1-public-ip   = module.ec2_workers[1].public_ip,
      worker-1-public-dns  = module.ec2_workers[1].public_dns,
      worker-1-private-ip  = module.ec2_workers[1].private_ip,
      worker-1-private-dns = module.ec2_workers[1].private_dns,

      ssh-private-key = file("~/.ssh/id_rsa")
    }
  )
  filename = "${path.module}/../../../ansible/aws_k8s_hosts"
}
