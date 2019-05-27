# this file defines the details for the aws cloud provider

# Define cloud provider and its configurations
provider "aws" {
  #access key and secret key provided in credentials file located in ~/.aws/  #access_key = "${var.aws_access_key}"  #secret_key = "${var.aws_secret_key}"

  profile = "${var.aws_provider_profile}"
  region  = "${var.aws_provider_region}"
}
