# - - - networking/variables.tf - - - 
variable "vpc_cidr" {}
variable "public_cidrs" {}
variable "private_cidrs" {}
variable "private_sn_count" {}
variable "public_sn_count" {}
variable "max_subnets" {}
variable "access_ip" {}
variable "security_groups" {}
variable "db_subnet_group" {
  type = bool
}


