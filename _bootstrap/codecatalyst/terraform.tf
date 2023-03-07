# Commented out on purpose as you need to set up the required AWS resources before
# you can store the state file.

# terraform {
#   backend "s3" {
#     bucket         = "tf-state-files"
#     key            = "terraform-bootstrap-state-file/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "TerraformMainStateLock"
#     kms_key_id     = "alias/s3" # Optionally change this to the custom KMS alias you created - "alias/terraform"
#   }

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.33"
#     }
#   }

#   required_version = "= 1.3.7"
# }