###======================================================================================
### Copyright (c) 2023, Bobby Wen, All Rights Reserved 
### Use of this source code is governed by a MIT-style
### license that can be found at https://en.wikipedia.org/wiki/MIT_License.
### Project:		Showcase Demo
### Class:			Terraform AWS output file
### Purpose:    Kubernetes cluster module creation
### Usage:			terraform, used by terraform main.tf
### Pre-requisits:	AWS access configuration(https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html), 
###                 Terraform by HashiCorp (https://www.terraform.io/)
### Beware:     modules.tf file is used to pass module setup to main.tf.  
###             Depending on SDLC environmental setting, different attributes are passed to create the stack 
###
### Developer: 		Bobby Wen, bobby@wen.org
### Creation date:	20230929_1001
###======================================================================================
module "ec2_instance" {
  ###   description            = "EC2 instance"
  source                      = "terraform-aws-modules/ec2-instance/aws"
  ami                         = var.aws_instance_id[var.region]
  associate_public_ip_address = true
  count                       = 2 ### two controllers are needed for HA
  instance_type               = var.instance_type[var.environment]
  key_name                    = var.key_name
  monitoring                  = true
  name                        = "controller-${count.index}"
  subnet_id                   = aws_default_subnet.default[count.index].id
  tags = {
    Terraform   = "true"
    project     = var.project_name
    environment = var.environment
    name        = var.instance_name
  }
  # vpc_security_group_ids = [aws_security_group.allow_etcd.id, aws_security_group.allow_ssh.id]
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}

module "ec2_workers" {
  ### description                = "EC2 instance of workers"
  source = "terraform-aws-modules/ec2-instance/aws"
  ami    = var.aws_instance_id[var.region]
  # associate_public_ip_address = true
  associate_public_ip_address = false
  count                       = var.instance_count[var.environment]
  instance_type               = var.instance_type[var.environment]
  key_name                    = var.key_name
  monitoring                  = true
  name                        = "worker-${count.index}"
  subnet_id                   = aws_default_subnet.default[count.index].id
  tags = {
    project     = var.project_name
    environment = var.environment
    name        = var.instance_name
  }
  # vpc_security_group_ids = [aws_security_group.allow_https.id, aws_security_group.allow_ssh.id]
  vpc_security_group_ids = [aws_security_group.allow_private_traffic.id]
}