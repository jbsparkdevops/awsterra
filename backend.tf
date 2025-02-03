# Create S3 Bucket for Terraform State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "bharghav-terraform-state"

  versioning {
    enabled = true  # Enable versioning to track state changes
  }

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
  }

  tags = {
    Name = "Terraform State Bucket"
  }
}

# Enable Server-Side Encryption for S3 Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
