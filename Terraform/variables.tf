variable "aws_provider_region" {
  type    = "string"
  default = "ca-central-1"
}

variable "default_availability_zone" {
  type    = "string"
  default = "ca-central-1a"
}

variable "aws_provider_profile" {
  type = "string"

  # located in .aws/credentials
  default = "test_aws_infrastructure"
}

variable "public_cidr_block" {
  type    = "string"
  default = "0.0.0.0/0"
}

variable "vpc_cidr_block" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "vpc_tenancy" {
  type    = "string"
  default = "default"
}

variable "subnet_public_cidr" {
  type    = "string"
  default = "10.0.0.0/24"
}

variable "subnet_private_cidr" {
  type    = "string"
  default = "10.0.1.0/24"
}

variable "subnet_address_bits" {
  default = "8"
}

variable "subnet_public_count" {
  default = "1"
}

variable "subnet_public_offset" {
  default = "0"
}

variable "subnet_private_count" {
  default = "1"
}

variable "subnet_private_offset" {
  default = "0"
}

variable "keypair_name_ec2" {
  type    = "string"
  default = "test_instance_zaheen_keypair"
}

variable "public_key_path_ec2" {
  type    = "string"
  default = "~/.ssh/test_instance.pub"
}

variable "ami_image_ubuntu_18" {
  type    = "string"
  default = "ami-0427e8367e3770df1" //Ubuntu 18.04
}

variable "instance_type_t2micro" {
  type    = "string"
  default = "t2.micro"
}

data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}
