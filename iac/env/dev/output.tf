###======================================================================================
### Copyright (c) 2023, Bobby Wen, All Rights Reserved 
### Use of this source code is governed by a MIT-style
### license that can be found at https://en.wikipedia.org/wiki/MIT_License.
### Project:		Showcase Demo
### Class:			Terraform AWS output file
### Purpose:    Ouput information collected from Terraform creation of servers instances 
### Usage:			terraform, used by terraform main.tf
### Pre-requisits:	AWS access configuration(https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html), 
###                 Terraform by HashiCorp (https://www.terraform.io/)
### Beware:     output.tf file is gather information from Terraform creation of services and servers
###             Depending on SDLC environmental setting, different attributes are passed to create the stack 
###
### Developer: 		Bobby Wen, bobby@wen.org
### Creation date:	20230929_0957
###======================================================================================
################################################################################
# controller
################################################################################
output "controller_public_dns_name" {
  description = "Public DNS name of the EC2 instance"
  #   value       = module.aws_instance.ec2_instance[*].public_dns
  value = module.ec2_instance[*].public_dns
}

output "controller_public_ip" {
  description = "Public IP address of the EC2 instance"
  #   value       = module.aws_instance.ec2_instance[*].public_ip
  value = module.ec2_instance[*].public_ip
}

output "controller_private_dns_name" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_instance[*].private_dns
}

output "controller_private_ip" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_instance[*].private_ip
}

################################################################################
# worker
################################################################################
output "ec2_workers_public_dns_name" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_workers[*].public_dns
}

output "ec2_workers_public_ip" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_workers[*].public_ip
}

output "ec2_workers_private_dns_name" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_workers[*].private_dns
}
output "ec2_workers_private_ip" {
  description = "Public DNS name of the EC2 instance"
  value       = module.ec2_workers[*].private_ip
}
