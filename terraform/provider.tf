terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50.0"
    }
  }


  backend "s3" {
    bucket               = "bucket-sonalashr"
    key                  = "static-site/terraform.tfstate"
    region               = "us-east-1"
    dynamodb_table       = "bucket-sonalashr-lock"
    workspace_key_prefix = "env"
    encrypt              = true
  }
}

provider "aws" {
  region = var.aws_region
}