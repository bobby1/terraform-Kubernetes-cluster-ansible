###======================================================================================
### Copyright (c) 2023, Bobby Wen, All Rights Reserved 
### Use of this source code is governed by a MIT-style
### license that can be found at https://en.wikipedia.org/wiki/MIT_License.
### Project:		Showcase Demo
### Class:			Terraform AWS variable file
### Purpose:    Variables file Terraform script to create servers instances based on environment
### Usage:			terraform, used by terraform main.tf
### Pre-requisits:	AWS access configuration(https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html), 
###                 Terraform by HashiCorp (https://www.terraform.io/)
### Beware:     Variables.tf file is used to pass environment variable to main.tf.  
###             Depending on SDLC environmental setting, different attributes are passed to create the stack 
###
### Developer: 		Bobby Wen, bobby@wen.org
### Creation date:	20230929_0959
###======================================================================================
variable "environment" {
  description = "SDLC Infrastructure environment: THIS SETS THE DEPLOYMENT ENVIRONMENT"
  ###  options are ["dev", "stg", "prd"]  ### DEBUG
  type    = string
  default = "dev"
}

variable "project_name" {
  description = "product or project name"
  type        = string
  default     = "AWS_K8_cluster_demo"
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

################################################################################
# Instance configuration
################################################################################

variable "availability_zone" {
  description = "aws availability zones"
  type        = map(list(string))
  default = {
    us-east-1 = ["us-east-1a", "us-east-1b", "us-east-1c"]
    us-east-2 = ["us-east-2a", "us-east-2b", "us-east-2c"]
    us-west-1 = ["us-west-1a", "us-west-1c"]
    us-west-2 = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
  }
}

variable "aws_instance_id" {
  description = "AWS machine Image ID for deployment"
  type        = map(string)
  default = {
    us-east-1 = "ami-0261755bbcb8c4a84"
    us-east-2 = "ami-0430580de6244e02e"
    us-west-1 = "ami-04d1dcfb793f6fa37"
    us-west-2 = "ami-0c65adc9a5c1b5d7c"
  }
}

variable "instance_count" {
  description = "Number of instances to provision."
  type        = map(number)
  default = {
    dev = 2
    stg = 4
    prd = 6
  }
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "K8_cluster"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = map(string)
  default = {
    # dev = "t2.micro"  ### DEBUG  t2.micro is too small for k8s
    dev = "t2.medium"
    stg = "t2.medium"
    prd = "t2.large"
  }
}

variable "key_name" {
  description = "preconfigured key name"
  type        = string
  default     = "aws_key"
}

################################################################################
# network security
################################################################################
variable "ingress_cidr_blocks" {
  description = "CIDR blocks to allow in the security group"
  type        = map(list(string))
  default = {
    ### IP for individual developer's remote address, 67.174.209.57/32 is an access IP address  ### DEBUG
    ### 172.31.0.0/16 is aws local network   ### DEBUG
    ### 10.32.0.0/24 is k8s cluster network   ### DEBUG
    dev = ["98.207.22.120/32", "67.174.209.57/32", "172.31.0.0/16", "10.32.0.0/24", ]
    ### example IPs for a company's testing evironement  ### DEBUG
    stg = ["52.250.42.0/24", "172.31.0.0/16", "127.0.0.1/32", ]
    prd = ["0.0.0.0/0", ]
  }
}

variable "egress_cidr_blocks" {
  description = "CIDR blocks to allow in the security group"
  type        = map(list(string))
  default = {
    dev = ["0.0.0.0/0", ]
    stg = ["0.0.0.0/0", ]
    prd = ["0.0.0.0/0", ]
  }
}
