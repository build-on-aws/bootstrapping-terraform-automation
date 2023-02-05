# Bucket used to store our state file
resource "aws_s3_bucket" "state_file" {
  bucket = var.state_file_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

# Enabling bucket versioning to keep backup copies of the state file
resource "aws_s3_bucket_versioning" "state_file" {
  bucket = aws_s3_bucket.state_file.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Table used to store the lock to prevent parallel runs causing issues
resource "aws_dynamodb_table" "state_file_lock" {
  name           = var.state_file_lock_table_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

## (Optional) KMS Key and alias to use instead of default `alias/s3` one.
# resource "aws_kms_key" "terraform" {
#   description = "Key used for Terraform state files."
# }

# resource "aws_kms_alias" "terraform" {
#   name          = "alias/terraform"
#   target_key_id = aws_kms_key.terraform.key_id
# }