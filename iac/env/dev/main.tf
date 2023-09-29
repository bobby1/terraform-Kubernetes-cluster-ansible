###======================================================================================
### Copyright (c) 2023, Bobby Wen, All Rights Reserved 
### Use of this source code is governed by a MIT-style
### license that can be found at https://en.wikipedia.org/wiki/MIT_License.
### Project:		Showcase Demo
### Class:			Terraform AWS IaC file
### Purpose:    Terraform script to create kubernetes cluster on AWS
### Usage:			terraform (init|plan|apply|destroy)
### Pre-requisits:	AWS access configuration(https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html), 
###                 Terraform by HashiCorp (https://www.terraform.io/)
### Beware:     main.tf setups the environment and calls modules to create the stack
###             Depending on SDLC environmental setting, different attributes are passed to create the stack 
###
### Developer: 	Bobby Wen, bobby@wen.org
### Creation date:	20230929_0955
###======================================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  ### backend S3 bucket terraform state if one is available
  #   backend "s3" {
  #   }
}

provider "aws" {
  region = var.aws_region
}
