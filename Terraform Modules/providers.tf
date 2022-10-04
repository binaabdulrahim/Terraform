terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
