# Configuring the AWS provider
provider "aws" {
  region = var.aws_region
}

# Used to retrieve the AWS Account Id
data "aws_caller_identity" "current" {}
